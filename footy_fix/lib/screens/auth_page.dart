import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/screens/login_page.dart';
import 'package:footy_fix/screens/home.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return HomeScreen();
          }
          // user is NOT logged in
          else {
            return LoginPage();
          }
        },
      ),
    );
  }
}
