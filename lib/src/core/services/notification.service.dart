import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:smart_reload_system/src/core/constants/constant.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;


@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Note: Firebase.initializeApp() must run here too, since this executes
  // in a separate background isolate that hasn't run your normal main().
  // Call it here if you see "no Firebase App has been created" errors:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('Background message received: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'default_channel',
    'Default Notifications',
    description: 'General app notifications',
    importance: Importance.max,
  );

  /// Called when the user taps a notification, in any app state
  /// (foreground, background, or terminated-then-launched).
  /// Wire this to your router in main.dart / injection_container.dart.
  void Function(RemoteMessage message)? onNotificationTap;

  Future<void> initialize() async {
    // 1. Request notification permission (iOS prompt + Android 13+ prompt).
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    debugPrint('Push permission status: ${settings.authorizationStatus}');

    // 2. Initialize the local notifications plugin (used to display
    //    foreground FCM messages, since FCM doesn't auto-show a system
    //    notification while the app is in the foreground).
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // already requested above via FCM
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        // Tap while app was in foreground/background but still alive.
        // We don't have the original RemoteMessage here, only the payload
        // string we stored ourselves — see showNotification() below.
        debugPrint('Local notification tapped, payload: ${response.payload}');
      },
    );

    // 3. Explicitly create the Android notification channel.
    //    Required on Android 8+ or notifications may not display at all.
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // 4. Register the background handler — must be called before any
    //    messages arrive, so do this early (main.dart, before runApp).
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // 5. Foreground messages — app is open and visible.
    //    FCM delivers the message but does NOT show a system notification
    //    automatically here, so we display it ourselves via local notifications.
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('Foreground message received: ${message.messageId}');
      _showLocalNotification(message);
    });

    // 6. Notification tapped while app was in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('Notification tapped from background: ${message.messageId}');
      onNotificationTap?.call(message);
    });

    // 7. App was fully terminated and launched BY tapping a notification.
    //    This only returns a non-null message on cold start via tap —
    //    check it once, after everything above is wired up.
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App launched from terminated via notification: ${initialMessage.messageId}');
      onNotificationTap?.call(initialMessage);
    }
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return; // data-only message, nothing to show

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.show(
      id: message.hashCode, // unique-ish id per message; swap for your own scheme if needed
      title: notification.title,
      body: notification.body,
      notificationDetails: details,
      payload: message.data['route'], // e.g. pass a route name from your backend payload
    );
  }

  /// Call this after login to get the device's FCM token — send it to your
  /// backend/Firestore so you can target this specific device later.
  Future<String?> getToken() => _firebaseMessaging.getToken();

  /// Call this if you want to react to the token changing (e.g. reinstall,
  /// token rotation) — re-send the new token to your backend.
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  static Future<void> sendPushMessage1(String token, String title, String body) async {
    final serviceAccount = jsonDecode(await rootBundle.loadString(serviceAccountURL));


    final accountCredentials = auth.ServiceAccountCredentials.fromJson(serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

    final url = Uri.parse('https://fcm.googleapis.com/v1/projects/smart-reload-system/messages:send');

    final response = await client.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "message": {
          "token": token,
          "notification": {"title": title, "body": body}
        }
      }),
    );
    debugPrint("Notification Response: ${response.statusCode}");
    client.close();
  }

  static Future<bool> sendPushMessage(String token, String title, String body, {String? route, Map<String, String>? data}) async {

    final serviceAccount = jsonDecode(await rootBundle.loadString(serviceAccountURL)) as Map<String, dynamic>;

    final projectId = serviceAccount['project_id'];
    const scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccount),
      scopes,
    );

    try {
      final response = await client.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/$projectId/messages:send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'message': {
            'token': token,
            'notification': {'title': title, 'body': body},
            'data': {
              ...?data,
              if (route != null) 'route': route,
            },
            'android': {
              'priority': 'HIGH',
              'notification': {'channel_id': 'default_channel'},
            },
          },
        }),
      );

      debugPrint('Notification response: ${response.statusCode} ${response.body}');
      return response.statusCode == 200;
    } finally {
      client.close();
    }
  }


}