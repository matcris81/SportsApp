import 'package:flutter/material.dart';
import 'package:footy_fix/mongo/mongodb.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:footy_fix/components/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firebase Database persistence
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // Initialize Mongo Database
  await MongoDatabse.connect();

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: NavBar(), // Wrap HomeScreen with NavBar
      ),
    );
  }
}
