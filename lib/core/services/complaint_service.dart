import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import '../constants/app_config.dart';
import 'auth_service.dart';

class ComplaintService extends ChangeNotifier {
  static const String _boxName = 'complaints_box';
  final AuthService _authService;
  bool _isSyncing = false;
  
  List<Map<String, dynamic>> _complaints = [];
  List<Map<String, dynamic>> get complaints => _complaints;
  bool get isSyncing => _isSyncing;

  ComplaintService(this._authService) {
    _init();
  }

  Future<void> _init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
    _loadComplaints();
    // Attempt background sync
    syncComplaints();
  }

  void _loadComplaints() {
    try {
      if (!Hive.isBoxOpen(_boxName)) return;
      final box = Hive.box<String>(_boxName);
      _complaints = box.values.map((item) => jsonDecode(item) as Map<String, dynamic>).toList();
      // Sort descending by timestamp
      _complaints.sort((a, b) {
        final tA = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime.now();
        final tB = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime.now();
        return tB.compareTo(tA);
      });
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load complaints: $e');
      }
    }
  }

  /// Saves complaint to Hive instantly and queues background sync
  Future<void> submitComplaint(Map<String, dynamic> data) async {
    try {
      final box = await Hive.openBox<String>(_boxName);
      
      final complaintId = 'complaint_${DateTime.now().millisecondsSinceEpoch}';
      final complaintData = {
        'id': complaintId,
        'status': 'pending', // pending, synced
        'timestamp': DateTime.now().toIso8601String(),
        ...data, // includes category, description, etc.
      };

      // Save to Hive instantly (Local DB is PRIMARY)
      await box.put(complaintId, jsonEncode(complaintData));
      
      // Update UI instantly
      _loadComplaints();
      
      // Queue background sync (Eventually consistent)
      syncComplaints();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to save complaint locally: $e');
      }
    }
  }

  /// Sends completely offline pending complaints to remote API
  Future<void> syncComplaints() async {
    if (_isSyncing) return;

    try {
      final box = await Hive.openBox<String>(_boxName);
      if (box.isEmpty) return;

      _isSyncing = true;
      notifyListeners();

      // Find all pending complaints
      final pendingKeys = <String>[];
      final pendingLogs = <Map<String, dynamic>>[];
      
      for (final key in box.keys) {
        final itemString = box.get(key);
        if (itemString == null) continue;
        
        final item = jsonDecode(itemString) as Map<String, dynamic>;
        if (item['status'] == 'pending') {
          pendingKeys.add(key.toString());
          // Just push the local complaint object
          pendingLogs.add(item);
        }
      }

      if (pendingLogs.isEmpty) {
        _isSyncing = false;
        notifyListeners();
        return;
      }

      final token = await _authService.getToken();
      
      // Use the dedicated complaints API endpoint instead of generic logs
      final url = Uri.parse('${AppConfig.apiBaseUrl}/complaints');
      
      // We process them one by one if they are pending (simple naive sync for now)
      // Since it's a POST to /api/complaints we need to send the correct payload
      bool allSynced = true;

      for (var i = 0; i < pendingKeys.length; i++) {
        final item = pendingLogs[i];
        final key = pendingKeys[i];
        
        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'category': item['category'],
            'description': item['description'],
          }),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          // Mark as synced locally
          final box = Hive.box<String>(_boxName);
          final itemString = box.get(key);
          if (itemString != null) {
            final savedItem = jsonDecode(itemString) as Map<String, dynamic>;
            savedItem['status'] = 'synced'; 
            await box.put(key, jsonEncode(savedItem));
          }
        } else {
          allSynced = false;
        }
      }

      if (allSynced) {
        _loadComplaints();
        if (kDebugMode) {
          print('Synced ${pendingLogs.length} complaints to backend');
        }
      }
    } catch (e) {
      // It's expected to fail if network is down
      if (kDebugMode) {
        print('Network unavailable. Complaint queued for future sync: $e');
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
