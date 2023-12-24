import 'package:flutter/material.dart';
import 'package:footy_fix/screens/profile_screens/account_screen.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('More Info',
              style: TextStyle(color: Colors.black, fontSize: 20)),
          centerTitle: true,
          automaticallyImplyLeading:
              false, // This line removes the default back button
        ),
        body: ListView(
          children: <Widget>[
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
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('About'),
                onTap: () {}),
            ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () async {
                  await AuthService().signOut();

                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                }),
            ListTile(
                leading: const Icon(Icons.delete_forever_sharp),
                title: const Text('Delete account'),
                onTap: () {}),
          ],
        ),
      ),
    );
  }
}
