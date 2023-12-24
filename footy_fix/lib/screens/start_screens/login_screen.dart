import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:footy_fix/components/my_button.dart';
import 'package:footy_fix/components/my_textfield.dart';
import 'package:footy_fix/components/square_tile.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/screens/start_screens/register.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void navigateToRegisterPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  // sign user in method
  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    // try sign in
    try {
      var credential = await AuthService().signInWithEmailPassword(
          emailController.text, passwordController.text);

      if (!mounted) return;

      // pop the loading circle
      Navigator.pop(context);
      // navigate to home
      if (credential != null) {
        var uid = credential.user!.uid;

        await PreferencesService().saveUserId(uid);

        addUserifDoesntExist(uid, emailController.text);

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NavBar()),
        );
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      // WRONG EMAIL
      if (e.code == 'user-not-found') {
        // show error to user
        wrongEmailMessage();
      }

      // WRONG PASSWORD
      else if (e.code == 'wrong-password') {
        // show error to user
        wrongPasswordMessage();
      }
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
    var result = await PostgresService().retrieve(
        "SELECT EXISTS (SELECT 1 FROM users WHERE user_id = '$userID') AS user_exists");

    var existance = result[0][0];

    if (existance == true) {
      print('user: $userID');
    } else {
      var userMap = {
        'user_id': userID,
        'email': email,
      };

      await PostgresService().insert('users', userMap);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              // logo
              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              // welcome back, you've been missed!
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

              // forgot password?
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color: Colors.grey[600]),
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

              // google + apple sign in buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // google button
                  SquareTile(
                      onTap: () async {
                        var credential = await AuthService().signInWithGoogle();

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
                        var credential = await AuthService().signInWithApple();

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

                  SquareTile(
                      onTap: () async {
                        var credential =
                            await AuthService().signInWithFacebook();

                        // Check if the widget is still in the widget tree
                        if (!mounted) return;

                        if (credential != null) {
                          var uid = credential.user!.uid;
                          await PreferencesService().saveUserId(uid);

                          var email = credential.user!.email;

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
                      imagePath: 'assets/icons/facebook.png'),
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
    );
  }
}
