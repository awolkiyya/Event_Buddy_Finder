import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

typedef TokenCallback = Future<void> Function(String token);
typedef NotificationTapCallback = void Function(String? route, BuildContext context);

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidNotificationChannel _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel', // same as manifest meta-data
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  final bool enableDebugLogging;
  final TokenCallback? onTokenRefreshCallback;
  final NotificationTapCallback? onNotificationTapCallback;

  PushNotificationService({
    this.enableDebugLogging = false,
    this.onTokenRefreshCallback,
    this.onNotificationTapCallback,
  });

  Future<void> initialize(BuildContext context) async {
    if (enableDebugLogging) {
      debugPrint("🔔 Initializing PushNotificationService...");
    }

    // Request permission (iOS)
    if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (enableDebugLogging) {
        debugPrint('iOS permission granted: ${settings.authorizationStatus}');
      }
    }

    // Setup local notifications channel for Android
    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // Initialize local notifications WITHOUT onDidReceiveLocalNotification (deprecated)
    final initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );

    await _localNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (enableDebugLogging) {
          debugPrint("Notification tapped with payload: ${details.payload}");
        }
        onNotificationTapCallback?.call(details.payload, context);
      },
    );

    // Background message handler must be registered globally
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      if (enableDebugLogging) {
        debugPrint("Foreground message received: ${message.messageId}");
      }
      _showLocalNotification(message);
    });

    // App opened from background (notification tapped)
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (enableDebugLogging) {
        debugPrint("Notification caused app to open from background: ${message.data}");
      }
      onNotificationTapCallback?.call(message.data['route'], context);
    });

    // App opened from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (enableDebugLogging) {
        debugPrint("App opened from terminated state via notification: ${initialMessage.data}");
      }
      onNotificationTapCallback?.call(initialMessage.data['route'], context);
    }

    // Token refresh listener
    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (enableDebugLogging) {
        debugPrint("FCM Token refreshed: $newToken");
      }
      if (onTokenRefreshCallback != null) {
        await onTokenRefreshCallback!(newToken);
      }
    });

    // Get initial token
    final token = await _firebaseMessaging.getToken();
    if (enableDebugLogging) {
      debugPrint("FCM Token: $token");
    }
    if (token != null && onTokenRefreshCallback != null) {
      await onTokenRefreshCallback!(token);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    final androidDetails = AndroidNotificationDetails(
      _androidChannel.id,
      _androidChannel.name,
      channelDescription: _androidChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      platformDetails,
      payload: message.data['route'],
    );
  }
}

/// Must be a top-level function for background handling
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔕 Background message received: ${message.messageId}");
}
