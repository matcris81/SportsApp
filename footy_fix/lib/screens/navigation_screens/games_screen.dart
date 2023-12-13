import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
// Add any other necessary imports (e.g., services, models)

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Games',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // This line removes the default back button
      ),
      backgroundColor: Colors.grey[200], // Set the background color to grey
      body: RefreshIndicator(
        onRefresh: () async {
          var userID = await PreferencesService().getUserId();
          var preferences =
              await DatabaseServices().retrieveFromDatabase('users/$userID');

          if (preferences != null) {
            print(preferences);
          } else {
            print('No data found');
          }
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
