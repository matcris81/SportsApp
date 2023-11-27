import 'package:flutter/material.dart';
import 'package:footy_fix/components/square_tile.dart';
import 'package:footy_fix/screens/login_page.dart';
import 'package:footy_fix/components/my_textfield.dart';
import 'package:footy_fix/services/database_service.dart';

class FilterScreen extends StatefulWidget {
  const FilterScreen({Key? key}) : super(key: key);

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  final filter = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
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

                const SizedBox(height: 25),

                MyTextField(
                  controller: filter,
                  obscureText: false,
                  hintText: 'Email',
                ),

                const SizedBox(height: 25),

                ElevatedButton(
                  onPressed: () async {
                    await DatabaseServices().addFilter('filter', filter.text);
                  },
                  child: const Text('Add'),
                ),

                const SizedBox(height: 10),

                const SizedBox(height: 25),

                const SizedBox(height: 25),

                // Google, Apple, Facebook sign-in buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SquareTile(
                        onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginPage()),
                            ),
                        imagePath: 'assets/icons/google.png'),
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
