import 'package:flutter/material.dart';
import 'package:footy_fix/mongo/mongodb.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:footy_fix/screens/start_screens/auth_page.dart';
import 'package:footy_fix/services/geolocator_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await MongoDatabse.connect();
  GeolocatorService().determinePosition().then((_) {
    runApp(const MyApp());
  });
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
