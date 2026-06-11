import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/api_constants.dart';
import 'secure_storage_service.dart';
import '../di/service_locator.dart';
import '../../features/notification/data/models/notification_model.dart';
import '../../features/notification/presentation/providers/notification_provider.dart';


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _ordersChannel =
      AndroidNotificationChannel(
    'orders',
    'Order Notifications',
    description: 'Notifications for new orders and order updates',
    importance: Importance.high,
  );

  static Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_ordersChannel);

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
    await _requestPermission();

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    _messaging.onTokenRefresh.listen((token) => _saveTokenToBackend(token));
  }

  static Future<void> registerDeviceToken() async {
    try {
      await _requestPermission();
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        await _saveTokenToBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to register FCM token: $e');
      }
    }
  }

  static Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> _saveTokenToBackend(String fcmToken) async {
    final authToken = await SecureStorageService.readToken();
    if (authToken == null || authToken.isEmpty) {
      return;
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/user/fcm-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'fcmToken': fcmToken}),
    );

    if (kDebugMode && response.statusCode >= 400) {
      print('Failed to save FCM token: ${response.statusCode} ${response.body}');
    }
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) {
      return;
    }

    try {
      final dataId = message.data['id'];
      final id = dataId != null ? (int.tryParse(dataId) ?? DateTime.now().millisecondsSinceEpoch) : DateTime.now().millisecondsSinceEpoch;
      
      final model = NotificationModel(
        id: id,
        userId: 0,
        title: notification.title ?? '',
        message: notification.body ?? '',
        type: message.data['type'] ?? 'SYSTEM',
        priority: message.data['priority'] ?? 'MEDIUM',
        isRead: false,
        actionUrl: message.data['actionUrl'],
        createdAt: DateTime.now(),
      );

      sl<NotificationProvider>().addNotification(model);
    } catch (e) {
      if (kDebugMode) {
        print('Error parsing real-time notification in service: $e');
      }
    }

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannel.id,
          _ordersChannel.name,
          channelDescription: _ordersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            htmlFormatBigText: true,
            contentTitle: notification.title,
            htmlFormatContentTitle: true,
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  static Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannel.id,
          _ordersChannel.name,
          channelDescription: _ordersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(
            body,
            contentTitle: title,
          ),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: payload != null ? jsonEncode(payload) : null,
    );
  }

  static Future<void> checkAndShowPendingNotifications() async {
    try {
      final authToken = await SecureStorageService.readToken();
      if (authToken == null || authToken.isEmpty) {
        return;
      }

      final provider = sl<NotificationProvider>();
      await provider.fetchNotifications();
      final unreadNotifications = provider.notifications.where((n) => !n.isRead).toList();

      if (unreadNotifications.isEmpty) return;

      final prefs = await SharedPreferences.getInstance();
      final shownIdsStrList = prefs.getStringList('shown_notification_ids') ?? [];
      final shownIds = shownIdsStrList.map((e) => int.tryParse(e)).whereType<int>().toSet();

      bool updated = false;
      for (final n in unreadNotifications) {
        if (!shownIds.contains(n.id)) {
          await showLocalNotification(
            id: n.id,
            title: n.title,
            body: n.message,
            payload: {
              'type': n.type,
              'id': n.id.toString(),
              'actionUrl': n.actionUrl,
            },
          );
          shownIds.add(n.id);
          updated = true;
        }
      }

      if (updated) {
        await prefs.setStringList(
          'shown_notification_ids',
          shownIds.map((e) => e.toString()).toList(),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking and showing pending notifications: $e');
      }
    }
  }
}
