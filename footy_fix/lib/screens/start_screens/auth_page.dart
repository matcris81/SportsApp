import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GeolocatorService _geolocatorService = GeolocatorService();
  final PreferencesService _sharedPreferencesService = PreferencesService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            print('User: $user');
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
    // save user id
    _saveUserID(user.uid);
    // Update location
    _updateUserLocation();

    _geolocatorService.startPeriodicLocationUpdates(const Duration(minutes: 5));

    _updateSharedPreferencesInBackground(user.uid);

    // Navigate to NavBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const NavBar()),
      );
    });

    return const Center(child: CircularProgressIndicator());
  }

  void _updateSharedPreferencesInBackground(String userId) async {
    try {
      var gamesResponse = await DatabaseServices().getData(
          '${DatabaseServices().backendUrl}/api/games/by-user/$userId');
      var gamesJson = jsonDecode(gamesResponse.body);

      if (gamesJson is List) {
        List<int> gameIdList =
            gamesJson.map<int>((game) => game['id'] as int).toList();
        await PreferencesService().saveList(gameIdList, 'gamesJoined');
      }

      var venueResponse = await DatabaseServices().getData(
          '${DatabaseServices().backendUrl}/api/players/$userId/venues');
      var venueJson = jsonDecode(venueResponse.body);

      if (venueJson is List) {
        List<int> venueIdList =
            venueJson.map<int>((venue) => venue['id'] as int).toList();
        await PreferencesService().saveList(venueIdList, 'likedVenues');
      }
    } catch (e) {
      // Handle any errors appropriately
    }
  }

  void _updateUserLocation() {
    _geolocatorService.determinePosition().then((position) {
      // Handle the position update logic
    }).catchError((error) {
      // Handle errors appropriately
    });
  }

  void _saveUserID(String userID) async {
    await _sharedPreferencesService.saveUserId(userID);
  }

  @override
  void dispose() {
    _geolocatorService.stopPeriodicLocationUpdates();
    super.dispose();
  }
}
