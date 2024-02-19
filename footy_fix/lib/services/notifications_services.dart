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

      // const AndroidInitializationSettings initializationSettingsAndroid =
      //     AndroidInitializationSettings('apple_logo.png');

      // final DarwinInitializationSettings initializationSettingsDarwin =
      //     DarwinInitializationSettings(
      //   onDidReceiveLocalNotification: onDidReceiveLocalNotification,
      //   requestAlertPermission: true,
      //   requestBadgePermission: true,
      //   requestSoundPermission: true,
      // );

      // final InitializationSettings initializationSettings =
      //     InitializationSettings(
      //   android: initializationSettingsAndroid,
      //   iOS: initializationSettingsDarwin,
      // );

      // await flutterLocalNotificationsPlugin!.initialize(
      //   initializationSettings,
      //   onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
      // );

      if (Platform.isIOS) {
        final apnsToken = await _firebaseMessaging.getAPNSToken();
      } else if (Platform.isAndroid) {
        // const AndroidNotificationDetails androidNotificationDetails =
        //     AndroidNotificationDetails('your channel id', 'your channel name',
        //         channelDescription: 'your channel description',
        //         importance: Importance.max,
        //         priority: Priority.high,
        //         ticker: 'ticker');
        // const NotificationDetails notificationDetails =
        //     NotificationDetails(android: androidNotificationDetails);
        // await flutterLocalNotificationsPlugin!.show(
        //     0, 'plain title', 'plain body', notificationDetails,
        //     payload: 'item x');
      }
    } else {
      print('User declined or has not accepted notification permissions');
    }
  }

  void onDidReceiveNotificationResponse(NotificationResponse response) {
    // Handle the notification response (e.g., navigate to a specific screen)
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    // Handle the notification here (e.g., show a dialog or a custom in-app notification)
  }

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

  // function to handle received messages
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
  // function to initialize foreground and background settings
}
