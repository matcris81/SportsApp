import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_fix/screens/home.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Stack(
        children: [
          Scaffold(
            backgroundColor:
                Colors.transparent, // Makes Scaffold background transparent
            body: Login(),
          ),
        ],
      ),
    );
  }
}

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: screenSize.height,
            ),
            child: IntrinsicHeight(
              child: Stack(
                children: <Widget>[
                  // Background image
                  Container(
                    width: screenSize.width, // Set width to screen width
                    height: screenSize.height, // Set height to screen height
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image:
                            AssetImage('assets/sewi.jpeg'), // Your asset path
                        fit: BoxFit
                            .cover, // Ensures the image covers the whole screen
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 350.0,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width: 3.0), // White border
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width:
                                          3.0), // White border for enabled state
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width:
                                          3.0), // White border for focused state
                                ),
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // White label text
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: 350.0,
                            child: TextFormField(
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white), // White border
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width:
                                          3.0), // White border for enabled state
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white,
                                      width:
                                          3.0), // White border for focused state
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold), // White label text
                              ),
                            ),
                          ),
                          const SizedBox(height: 40.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeScreen()),
                                  );
                                },
                                child: const Text('Login'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // ... your button action
                                },
                                child: const Text('Register'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 100.0),
                          const Text(
                            "Or sign in with",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              InkWell(
                                onTap: () async {
                                  try {
                                    final credential = await SignInWithApple
                                        .getAppleIDCredential(
                                      scopes: [
                                        AppleIDAuthorizationScopes.email,
                                        AppleIDAuthorizationScopes.fullName,
                                      ],
                                    );

                                    // Use credential to sign in to your app's backend
                                    // final signInWithAppleResult =
                                    //     await myBackendSignInFunction(
                                    //         credential);

                                    // Handle the result
                                    // if (signInWithAppleResult) {
                                    //   print(
                                    //       'Signed in with Apple successfully!');
                                    // } else {
                                    //   print('Failed to sign in with Apple.');
                                    // }
                                  } catch (error) {
                                    // Handle the error
                                    print('Sign in with Apple failed: $error');
                                  }
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/apple.png',
                                      width: 40.0,
                                      height: 40.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  AuthService().signInWithGoogle();
                                },
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/google.png',
                                      width: 56.0,
                                      height: 56.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {},
                                child: Container(
                                  width: 56.0,
                                  height: 56.0,
                                  decoration: const BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Image.asset(
                                      'assets/icons/facebook.png',
                                      width: 56.0,
                                      height: 56.0,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
