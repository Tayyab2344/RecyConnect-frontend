import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'auth_service.dart';

class ObservabilityService extends ChangeNotifier {
  static const String _logBoxName = 'offline_logs';
  final AuthService _authService;
  bool _isSyncing = false;

  ObservabilityService(this._authService) {
    _initHive();
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_logBoxName)) {
      await Hive.openBox<String>(_logBoxName);
    }
  }

  Future<void> logObservation({
    required String action,
    required String resourceType,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final box = await Hive.openBox<String>(_logBoxName);
      
      final logData = {
        'action': action,
        'resourceType': resourceType,
        'meta': {
          ...(meta ?? {}),
          'timestamp': DateTime.now().toIso8601String(),
          'platform': defaultTargetPlatform.toString(),
        }
      };

      // Store in Hive queue
      await box.add(jsonEncode(logData));
      
      // Attempt to sync immediately
      _syncLogs();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save log observation: $e');
      }
    }
  }

  Future<void> _syncLogs() async {
    if (_isSyncing) return;
    
    try {
      final box = await Hive.openBox<String>(_logBoxName);
      if (box.isEmpty) return;

      _isSyncing = true;
      notifyListeners();

      // Get all queued logs
      final logKeys = box.keys.toList();
      final logs = logKeys.map((key) => jsonDecode(box.get(key)!)).toList();

      // Get auth token
      final token = await _authService.getToken();

      final url = Uri.parse('${AppConfig.apiBaseUrl}/logs/client');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'logs': logs}),
      );

      if (response.statusCode == 200) {
        // Clear successfully synced logs
        await box.deleteAll(logKeys);
        if (kDebugMode) {
          print('Synced ${logs.length} logs to admin board');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to sync logs: $e. Will retry later.');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  // Called to manually trigger a sync (e.g. app resume or network restored)
  Future<void> forceSync() => _syncLogs();
}
