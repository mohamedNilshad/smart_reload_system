import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {

    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );


    debugPrint("Permission: ${settings.authorizationStatus}");

    // Initialize local notification

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settingsInit = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(settings: settingsInit);


    // Foreground notification

    FirebaseMessaging.onMessage.listen((RemoteMessage message){
      debugPrint("Foreground notification received");
      showNotification(message);
      },
    );


  }


  Future<void> showNotification(RemoteMessage message) async {

    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _localNotifications.show(
      id: 1,
      title: message.notification?.title,
      body: message.notification?.body,
      notificationDetails: details,
    );

  }

}