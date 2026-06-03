import 'package:flutter/foundation.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/services/api_notification_service.dart';
import '../../data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiNotificationService _apiService;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  NotificationProvider({required ApiNotificationService apiService})
      : _apiService = apiService;

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _apiService.getUserNotifications();

    _isLoading = false;
    if (result.isSuccess && result.data != null) {
      _notifications = result.data!;
    } else {
      _error = result.message;
    }
    notifyListeners();
  }

  Future<void> markAsRead(int id) async {
    // Optimistic Update
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final original = _notifications[index];
      _notifications[index] = original.copyWith(isRead: true);
      notifyListeners();

      final result = await _apiService.markAsRead(id);
      if (result.isFailure) {
        // Rollback on failure
        _notifications[index] = original;
        notifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount == 0) return;

    // Optimistic Update
    final originalList = List<NotificationModel>.from(_notifications);
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    notifyListeners();

    final result = await _apiService.markAllAsRead();
    if (result.isFailure) {
      // Rollback on failure
      _notifications = originalList;
      notifyListeners();
    }
  }

  Future<void> deleteNotification(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final original = _notifications[index];
      // Optimistic Update
      _notifications.removeAt(index);
      notifyListeners();

      final result = await _apiService.deleteNotification(id);
      if (result.isFailure) {
        // Rollback on failure
        _notifications.insert(index, original);
        notifyListeners();
      }
    }
  }

  Future<void> clearAllNotifications() async {
    if (_notifications.isEmpty) return;

    // Optimistic Update
    final originalList = List<NotificationModel>.from(_notifications);
    _notifications = [];
    notifyListeners();

    final result = await _apiService.clearAllNotifications();
    if (result.isFailure) {
      // Rollback on failure
      _notifications = originalList;
      notifyListeners();
    }
  }

  /// Inserts a notification at the top of the list in real-time
  void addNotification(NotificationModel notification) {
    // Avoid duplicates
    if (_notifications.any((n) => n.id == notification.id)) return;
    
    _notifications.insert(0, notification);
    notifyListeners();
  }
}
