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

// ──────────────────────────────────────────────────────────────────────────────
// Top-level background handler — MUST be a top-level function (not a method).
// This runs in its own isolate when the app is killed/background.
// ──────────────────────────────────────────────────────────────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  // Create a local-notification plugin instance inside the isolate
  final FlutterLocalNotificationsPlugin localPlugin =
      FlutterLocalNotificationsPlugin();

  // Ensure the notification channel exists
  await localPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'orders',
          'Order Notifications',
          description: 'Notifications for new orders and order updates',
          importance: Importance.high,
        ),
      );

  const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
  const initSettings = InitializationSettings(
    android: androidInit,
    iOS: DarwinInitializationSettings(),
  );
  await localPlugin.initialize(settings: initSettings);

  // Show the notification locally so the user sees it even when the app is killed
  final notification = message.notification;
  final String title = notification?.title ?? message.data['title'] ?? 'RecyConnect';
  final String body = notification?.body ?? message.data['message'] ?? '';

  if (title.isNotEmpty || body.isNotEmpty) {
    await localPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'orders',
          'Order Notifications',
          channelDescription: 'Notifications for new orders and order updates',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          sound: RawResourceAndroidNotificationSound('notification'),
          playSound: true,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }
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
    // Register the background handler FIRST
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Create the notification channel
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

    await _localNotifications.initialize(
      settings: initSettings,
    );

    // Request permission early on (Android 13+ needs POST_NOTIFICATIONS runtime permission)
    await _requestPermission();

    // ── Foreground messages ──
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // ── Background tap (app was in background, user taps notification) ──
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // ── Terminated tap (app was killed, launched by tapping notification) ──
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // ── Token refresh ──
    _messaging.onTokenRefresh.listen((token) => _saveTokenToBackend(token));

    // ── Ensure foreground notifications are shown on iOS and Android ──
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
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
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (kDebugMode) {
      print('[FCM] Authorization status: ${settings.authorizationStatus}');
    }

    // Android 13+ runtime notification permission
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
      debugPrint('Failed to save FCM token: ${response.statusCode} ${response.body}');
    }
  }

  /// Handles a notification tap when the app is in background or was terminated
  static void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      print('[FCM] Notification tapped: ${message.data}');
    }
    // Optionally navigate to a specific screen based on message.data['type']
  }

  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    final String title = notification?.title ?? message.data['title'] ?? '';
    final String body = notification?.body ?? message.data['message'] ?? '';

    if (title.isEmpty && body.isEmpty) return;

    try {
      final dataId = message.data['id'];
      final id = dataId != null ? (int.tryParse(dataId) ?? DateTime.now().millisecondsSinceEpoch) : DateTime.now().millisecondsSinceEpoch;
      
      final model = NotificationModel(
        id: id,
        userId: 0,
        title: title,
        message: body,
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
      id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _ordersChannel.id,
          _ordersChannel.name,
          channelDescription: _ordersChannel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(
            body,
            htmlFormatBigText: true,
            contentTitle: title,
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
      id: id,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
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
