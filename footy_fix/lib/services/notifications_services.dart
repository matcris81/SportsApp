import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseAPI {
  // create instance of firebase messaging
  final _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

  Future<void> initNotifications() async {
    NotificationSettings settings =
        await _firebaseMessaging.requestPermission();

    print('settings.authorizationStatus: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

      final fCMToken = await _firebaseMessaging.getToken();
      print('FCM Token: $fCMToken');

      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
      } else if (Platform.isAndroid) {}
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {}

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {}

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to $topic');
    } catch (e) {
      print('Failed to subscribe to $topic: $e');
      throw e;
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from $topic');
    } catch (e) {
      print('Failed to unsubscribe from $topic: $e');
      throw e;
    }
  }

  Future<void> listenForNotifications() async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Got a message whilst in the foreground!');
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
        showNotification(message.notification!);
      }
    });
  }

  Future<void> showNotification(RemoteNotification remoteNotification) async {
    Future<void> showNotification(RemoteNotification notification) async {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'channel_id', // Replace with your channel ID
        'channel_name', // Replace with your channel name
        channelDescription: 'Your channel description',
        importance: Importance.max,
        priority: Priority.high,
        visibility:
            NotificationVisibility.public, // Ensures visibility on lock screen
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await flutterLocalNotificationsPlugin?.show(
        0, // Notification ID
        notification.title,
        notification.body,
        notificationDetails,
        payload: 'Notification Payload', // You can pass payload data here
      );
    }
  }
}
