import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/components/navigation.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            // User is logged in
            if (snapshot.hasData) {
              // Determine and update the user's position
              GeolocatorService().determinePosition().then((position) {
                // If you need to do something with the position, do it here
                // For example, save it to a user profile in a database
              }).catchError((error) {
                // Handle the error of location retrieval if necessary
              });

              // Start location updates
              GeolocatorService()
                  .startPeriodicLocationUpdates(const Duration(minutes: 5));
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) => const NavBar()), // Navigate to NavBar
              );
            }
            // User is NOT logged in
            else {
              // Stop location updates
              GeolocatorService().stopPeriodicLocationUpdates();
              return const LoginPage(); // Your login page
            }
          }

          // While waiting for the authentication state, show a progress indicator
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
