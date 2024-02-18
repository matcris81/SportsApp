import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/screens/navigation_screens/home_screen.dart';
import 'firebase_options.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:footy_fix/services/notifications_services.dart';
import 'package:go_router/go_router.dart';
import 'package:footy_fix/router.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  // await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAPI().initNotifications();

  await FirebaseAPI().listenForNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Run the app
  runApp(MyApp());
}

void onDidReceiveLocalNotification(
    int id, String? x, String? y, String? z) async {
  print('onDidReceiveLocalNotification');
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => AuthPage(),
        '/home': (context) => HomeScreen(),
        // '/game': (context) => GameDescription(),
      },
    );
  }
}
