import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable Firebase Database persistence NOT NEEDED ANYMORE
  FirebaseDatabase.instance.setPersistenceEnabled(true);

  // initialize connection with postgres
  await PostgresService().initDatabase();

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
        body: AuthPage(), // Wrap HomeScreen with NavBar
      ),
    );
  }
}
