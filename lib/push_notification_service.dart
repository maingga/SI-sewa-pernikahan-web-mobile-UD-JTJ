import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';

class PushNotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request for permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined permission');
    }

    // Configure local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        // Handle when notification is tapped
        if (notificationResponse.payload != null) {
          debugPrint('Notification payload: ${notificationResponse.payload}');
        }
      },
    );

    // Handle incoming messages in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Received message in the foreground: $message');
      _showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title ?? '',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data['id'], // Example of passing data with the notification
    );
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('Handling background message: $message');
  }

  void showSuccessNotification() {
    _flutterLocalNotificationsPlugin.show(
      0,
      'Pembayaran Berhasil',
      'Terima kasih telah berbelanja!',
      NotificationDetails(
        android: const AndroidNotificationDetails(
          'success channel id',
          'success channel name',
          channelDescription: 'success channel description',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        ),
      ),
      payload: 'success_notification', // Example payload if needed
    );
  }
}
