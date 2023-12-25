import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GeolocatorService _geolocatorService = GeolocatorService();
  final PreferencesService _sharedPreferencesService =
      PreferencesService(); // Instance of your shared preferences service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            return user == null
                ? const LoginPage()
                : _handleAuthenticatedUser(user);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _handleAuthenticatedUser(User user) {
    print('User Identification: (${user.uid}');
    // save user id
    _saveUserID(user.uid);
    // Update location
    _updateUserLocation();

    // Start location updates
    _geolocatorService.startPeriodicLocationUpdates(const Duration(minutes: 5));

    _checkForUser(user.uid);

    // Navigate to NavBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const NavBar()),
      );
    });

    return const Center(child: CircularProgressIndicator());
  }

  void _checkForUser(String userID) async {
    var user = await PostgresService().retrieve(
        "SELECT EXISTS (SELECT 1 FROM users WHERE user_id = '$userID') AS user_exists");

    print('user: $user');
    // if (user[0][0] == false) {

    // }
  }

  void _updateUserLocation() {
    _geolocatorService.determinePosition().then((position) {
      // Handle the position update logic
    }).catchError((error) {
      // Handle errors appropriately
    });
  }

  void _saveUserID(String userID) async {
    await _sharedPreferencesService
        .saveUserId(userID); // Call your method to save the userID
  }

  @override
  void dispose() {
    _geolocatorService.stopPeriodicLocationUpdates();
    super.dispose();
  }
}
