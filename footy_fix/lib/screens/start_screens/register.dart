import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footy_fix/components/my_textfield.dart';
import 'package:footy_fix/components/register_button.dart';
import 'package:footy_fix/components/square_tile.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/services/database_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void registerUser() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      UserCredential userCredential = await AuthService()
          .registerWithEmailPassword(
              emailController.text, passwordController.text);

      String userID = userCredential.user!.uid;

      addPlayer(userID, emailController.text);

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      print('Error during registration: ${e.message}');
    }
  }

  void addPlayer(String userID, String? email) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var userMap = {
      "id": userID,
      "email": email,
      "username": email,
      "password": "password",
    };

    var result = await DatabaseServices().postData(
        '${DatabaseServices().backendUrl}/api/players', token, userMap);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        //title: Text('Register'),
        backgroundColor: Colors.grey[300], // Adjust the color as needed
        elevation: 0, // Remove shadow if desired
      ),
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 25),

                MyTextField(
                  controller: firstNameController,
                  hintText: 'First Name',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                MyTextField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // Register button
                RegButton(
                  onTap: registerUser,
                ),

                const SizedBox(height: 25),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // Google, Apple, Facebook sign-in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                        onTap: () => AuthService().signInWithGoogle(),
                        imagePath: 'assets/icons/google.png'),
                    const SizedBox(width: 25),
                    SquareTile(
                        onTap: () => AuthService().signInWithApple(),
                        imagePath: 'assets/icons/apple.png'),
                    const SizedBox(width: 25),
                    // SquareTile(
                    //     onTap: () => AuthService().signInWithFacebook(),
                    //     imagePath: 'assets/icons/facebook.png'),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
