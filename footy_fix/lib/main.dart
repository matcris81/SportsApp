import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_fix/mongodb.dart';
import 'package:footy_fix/screens/home.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:footy_fix/screens/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabse.connect();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}
