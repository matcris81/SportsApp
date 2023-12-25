import 'package:flutter/material.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
// Add any other necessary imports (e.g., services, models)

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // This line removes the default back button
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white, // Background color of the circle
            child:
                Icon(Icons.arrow_back, color: Colors.black), // Black arrow icon
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[200], // Set the background color to grey
      body: RefreshIndicator(
        onRefresh: () async {
          var userID = await PreferencesService().getUserId();
        },
        child: ListView(
          padding: const EdgeInsets.only(top: 20),
          children: const <Widget>[
            Center(child: Text('Games Page')),
          ],
        ),
      ),
    );
  }
}
