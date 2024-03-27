import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footy_fix/components/my_button.dart';
import 'package:footy_fix/components/my_textfield.dart';
import 'package:footy_fix/components/square_tile.dart';
import 'package:footy_fix/screens/start_screens/forgot_password_screen.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/screens/start_screens/register.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  String errorMessage = '';

  void navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  // sign user in method
  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      var credential = await AuthService().signInWithEmailPassword(
          emailController.text, passwordController.text);

      // Check if the widget is still mounted before popping the dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (credential == null) {
        // Check if the widget is still mounted before calling setState
        if (!mounted) return;
        setState(() {
          errorMessage = "Login failed. Please check your email and password.";
        });
        return;
      }

      var uid = credential.user!.uid;
      await PreferencesService().saveUserId(uid);
      addUserifDoesntExist(uid, emailController.text);

      // Check again before navigating
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NavBar()),
      );
    } on FirebaseAuthException catch (e) {
      // Ensure the context is still valid before attempting to pop the dialog
      if (mounted) {
        Navigator.pop(context);
      }

      String newErrorMessage = "An error occurred. Please try again later.";
      if (e.code == 'user-not-found') {
        newErrorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        newErrorMessage = 'Wrong password provided.';
      }

      // Safeguard setState with mounted check
      if (!mounted) return;
      setState(() {
        errorMessage = newErrorMessage;
      });
    }
  }

  // wrong email message popup
  void wrongEmailMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Incorrect Email',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  // wrong password message popup
  void wrongPasswordMessage() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          backgroundColor: Colors.deepPurple,
          title: Center(
            child: Text(
              'Incorrect Password',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  void addUserifDoesntExist(String userID, String? email) async {
    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/players/$userID');

    if (response.statusCode == 404) {
      var userMap = {
        "id": userID,
        "email": email,
        "username": email,
        "password": "password",
        "isFake": false,
      };

      var result = await DatabaseServices()
          .postData('${DatabaseServices().backendUrl}/api/players', userMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          backgroundColor: Colors.grey[300],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),

                    const Icon(
                      Icons.lock,
                      size: 100,
                    ),

                    const SizedBox(height: 50),

                    Text(
                      'Welcome back you\'ve been missed!',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 25),

                    // email textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    // password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),
                    const SizedBox(height: 10),

                    if (errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          errorMessage,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),

                    // forgot password?
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ForgotPassword()),
                              );
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 25),

                    // sign in button
                    MyButton(
                      onTap: signUserIn,
                    ),

                    const SizedBox(height: 25),

                    // or continue with
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
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

                    // google + apple sign in buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // google button
                        SquareTile(
                            onTap: () async {
                              var credential =
                                  await AuthService().signInWithGoogle();

                              // Check if the widget is still in the widget tree
                              if (!mounted) return;

                              if (credential != null) {
                                var uid = credential.user!.uid;
                                var email = credential.user!.email;

                                await PreferencesService().saveUserId(uid);
                                addUserifDoesntExist(uid, email);

                                if (!mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const NavBar()),
                                );
                              } else {
                                // Handle the case where sign-in was not successful
                                // For example, show an error message
                              }
                            },
                            imagePath: 'assets/icons/google.png'),

                        const SizedBox(width: 25),

                        // apple button
                        SquareTile(
                            onTap: () async {
                              var credential =
                                  await AuthService().signInWithApple();

                              // Check if the widget is still in the widget tree
                              if (!mounted) return;

                              if (credential != null) {
                                var uid = credential.user!.uid;
                                var email = credential.user!.email;

                                await PreferencesService().saveUserId(uid);

                                addUserifDoesntExist(uid, email);

                                if (!mounted) return;

                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const NavBar()),
                                );
                              } else {
                                // Handle the case where sign-in was not successful
                                // For example, show an error message
                              }
                            },
                            imagePath: 'assets/icons/apple.png'),

                        const SizedBox(width: 25),

                        // SquareTile(
                        //     onTap: () async {
                        //       var credential =
                        //           await AuthService().signInWithFacebook();

                        //       // Check if the widget is still in the widget tree
                        //       if (!mounted) return;

                        //       if (credential != null) {
                        //         var uid = credential.user!.uid;
                        //         await PreferencesService().saveUserId(uid);

                        //         var email = credential.user!.email;

                        //         addUserifDoesntExist(uid, email);

                        //         if (!mounted) return;

                        //         Navigator.pushReplacement(
                        //           context,
                        //           MaterialPageRoute(
                        //               builder: (context) => const NavBar()),
                        //         );
                        //       } else {
                        //         // Handle the case where sign-in was not successful
                        //         // For example, show an error message
                        //       }
                        //     },
                        //     imagePath: 'assets/icons/facebook.png'),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // not a member? register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        /*
                  const Text(
                    'Register now',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  */
                        TextButton(
                          onPressed: navigateToRegisterPage, // Change this line
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
