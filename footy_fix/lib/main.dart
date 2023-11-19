import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_fix/screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              '/Users/matcris/workspace/Footy_Fix/FootyFIxApp/footy_fix/pitch.jpeg', // Replace with your image asset path
              fit: BoxFit.cover, // Ensures the image covers the whole screen
            ),
          ),
          // Scaffold with transparent AppBar
          const Scaffold(
            backgroundColor:
                Colors.transparent, // Makes Scaffold background transparent
            // appBar: AppBar(
            //   backgroundColor: Colors.transparent, // Makes AppBar transparent
            //   elevation: 0, // Removes shadow from AppBar
            //   title: const Text('Football Fix Login'),
            // ),
            body: const Login(),
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
                            AssetImage('assets/pitch.jpeg'), // Your asset path
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
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white), // White border
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .white), // White border for enabled state
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .white), // White border for focused state
                                ),
                                labelText: 'Username',
                                labelStyle: TextStyle(
                                    color: Colors.white), // White label text
                              ),
                            ),
                          ),
                          const SizedBox(height: 20.0),
                          SizedBox(
                            width: 350.0,
                            child: TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white), // White border
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .white), // White border for enabled state
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors
                                          .white), // White border for focused state
                                ),
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: Colors.white), // White label text
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
