import 'package:flutter/material.dart';
import 'package:footy_fix/screens/account_screen.dart';
import 'package:footy_fix/screens/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onSignOut;

  ProfileScreen({Key? key, required this.onSignOut}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.only(top: 50), // Add padding at the top
          children: <Widget>[
            const ListTile(
              title: Center(
                // Wrap the Text widget with Center
                child: Text(
                  'name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Make text bold
                  ),
                  textAlign: TextAlign.center, // Center align the text
                ),
              ),
            ),
            ListTile(
                leading: const Icon(Icons.account_circle_outlined),
                title: const Text('Account'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const AccountScreen()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.photo_album),
                title: const Text('Wallet'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                  // );
                }),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                  // );
                }),
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => LoginPage()),
                  // );
                }),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sign out'),
              onTap: onSignOut,
            ),
            ListTile(
                leading: const Icon(Icons.delete_forever_sharp),
                title: const Text('Delete account'),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //       builder: (context) => const AccountScreen()),
                  // );
                }),
          ],
        ),
      ),
    );
  }
}
