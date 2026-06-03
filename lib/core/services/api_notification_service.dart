import 'package:flutter/foundation.dart';
import '../../features/notification/data/models/notification_model.dart';
import '../network/api_result.dart';
import 'api_service.dart';

class ApiNotificationService {
  final ApiService _apiService;

  ApiNotificationService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  Future<ApiResult<List<NotificationModel>>> getUserNotifications() async {
    try {
      final response = await _apiService.get('/notifications');
      if (response['success'] == true && response['data'] != null) {
        final List list = response['data'] as List;
        final notifications = list
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return ApiResult.success(data: notifications);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to fetch notifications');
      }
    } catch (e) {
      if (kDebugMode) print('Error fetching notifications: $e');
      return ApiResult.failure('Error fetching notifications: $e');
    }
  }

  Future<ApiResult<NotificationModel>> markAsRead(int id) async {
    try {
      final response = await _apiService.patch('/notifications/$id/read', {});
      if (response['success'] == true && response['data'] != null) {
        final notification = NotificationModel.fromJson(response['data'] as Map<String, dynamic>);
        return ApiResult.success(data: notification);
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to mark notification as read');
      }
    } catch (e) {
      if (kDebugMode) print('Error marking notification read: $e');
      return ApiResult.failure('Error marking notification read: $e');
    }
  }

  Future<ApiResult<void>> markAllAsRead() async {
    try {
      final response = await _apiService.patch('/notifications/read-all', {});
      if (response['success'] == true) {
        return ApiResult.success();
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to mark all as read');
      }
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications read: $e');
      return ApiResult.failure('Error marking all notifications read: $e');
    }
  }

  Future<ApiResult<void>> deleteNotification(int id) async {
    try {
      final response = await _apiService.delete('/notifications/$id');
      if (response['success'] == true) {
        return ApiResult.success();
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to delete notification');
      }
    } catch (e) {
      if (kDebugMode) print('Error deleting notification: $e');
      return ApiResult.failure('Error deleting notification: $e');
    }
  }

  Future<ApiResult<void>> clearAllNotifications() async {
    try {
      final response = await _apiService.delete('/notifications');
      if (response['success'] == true) {
        return ApiResult.success();
      } else {
        return ApiResult.failure(
            response['message'] as String? ?? 'Failed to clear notifications');
      }
    } catch (e) {
      if (kDebugMode) print('Error clearing notifications: $e');
      return ApiResult.failure('Error clearing notifications: $e');
    }
  }
}
