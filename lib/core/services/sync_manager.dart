import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'api_service.dart';

class SyncRequest {
  final String id;
  final String endpoint;
  final String method; // 'POST', 'PUT', 'DELETE'
  final Map<String, dynamic>? payload;
  final int retryCount;
  final String status; // 'pending', 'failed'
  final DateTime createdAt;

  SyncRequest({
    required this.id,
    required this.endpoint,
    required this.method,
    this.payload,
    this.retryCount = 0,
    this.status = 'pending',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'retryCount': retryCount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SyncRequest.fromJson(Map<String, dynamic> json) {
    return SyncRequest(
      id: json['id'],
      endpoint: json['endpoint'],
      method: json['method'],
      payload: json['payload'],
      retryCount: json['retryCount'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class SyncManager extends ChangeNotifier with WidgetsBindingObserver {
  static const String _boxName = 'sync_queue';
  final ApiService _apiService = ApiService();
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  SyncManager() {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (kDebugMode) print('App resumed: Triggering SyncManager');
      processQueue();
    }
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    processQueue();
  }

  /// Queues an offline request to be processed eventually
  Future<void> queueRequest({
    required String endpoint,
    required String method,
    Map<String, dynamic>? payload,
  }) async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      final req = SyncRequest(
        id: 'sync_${DateTime.now().millisecondsSinceEpoch}_${endpoint.hashCode}',
        endpoint: endpoint,
        method: method.toUpperCase(),
        payload: payload,
        createdAt: DateTime.now(),
      );

      // Save instantly to Hive Box
      await box.put(req.id, jsonEncode(req.toJson()));
      
      // Attempt to process queue immediately
      processQueue();
    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) print('Error queuing sync request: $e');
      }
    }
  }

  /// Iterates through the pending request queue sequentially
  Future<void> processQueue() async {
    if (_isProcessing) return;

    // SMART TRIGGER: Check WiFi connectivity first
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (!connectivityResult.contains(ConnectivityResult.wifi) && !connectivityResult.contains(ConnectivityResult.mobile)) {
        if (kDebugMode) print('Sync paused: No active network connection.');
        return;
      }
    } catch (e) {
      if (kDebugMode) print('Connectivity check failed: $e');
    }

    try {
      final box = await Hive.openBox<String>(_boxName);
      if (box.isEmpty) return;

      _isProcessing = true;
      notifyListeners();

      // Retrieve all requests and sort by createdAt to maintain precise sequence
      final requests = <SyncRequest>[];
      for (final key in box.keys) {
        final itemStr = box.get(key);
        if (itemStr != null) {
           requests.add(SyncRequest.fromJson(jsonDecode(itemStr)));
        }
      }
      
      requests.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (var req in requests) {
        if (req.retryCount > 10) {
           // Skip dead-letter queue items (e.g. permanently malformed requests)
           // Optionally, delete them to free up space: await box.delete(req.id);
           continue; 
        }

        bool success = false;
        try {
          // Playback the network call via ApiService wrapper
          if (req.method == 'POST') {
             await _apiService.post(req.endpoint, req.payload ?? {});
          } else if (req.method == 'PUT') {
             await _apiService.put(req.endpoint, req.payload ?? {});
          } else if (req.method == 'DELETE') {
             await _apiService.delete(req.endpoint);
          }
          success = true;
        } catch (e) {
          // Network failed (ApiService throws Exceptions)
          success = false;
        }

        if (success) {
          // Remote server accepted our request. Remove from local persistent queue.
          await box.delete(req.id);
          if (kDebugMode) {
            if (kDebugMode) print('Successfully synced: ${req.endpoint}');
          }
        } else {
          // Increment retry count and mark failed
          final updatedReq = SyncRequest(
            id: req.id,
            endpoint: req.endpoint,
            method: req.method,
            payload: req.payload,
            retryCount: req.retryCount + 1,
            status: 'failed',
            createdAt: req.createdAt,
          );
          await box.put(req.id, jsonEncode(updatedReq.toJson()));
          
          if (kDebugMode) {
            if (kDebugMode) print('Sync failed, paused queue: ${req.endpoint}');
          }
          // Break the sequence - we pause queue processing to prevent cascading sequence errors
          break;
        }
      }

    } catch (e) {
      if (kDebugMode) {
        if (kDebugMode) print('Error processing sync queue: $e');
      }
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
