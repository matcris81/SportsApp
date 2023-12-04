import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/sharedPreferences_service.dart';
// Add any other necessary imports (e.g., services, models)

class GamesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50), // Adjust as needed
          child: Container(
            padding: const EdgeInsets.only(bottom: 8), // Adjust as needed
            alignment: Alignment.bottomCenter,
            child: const Text(
              'Games',
              style: TextStyle(
                fontSize: 16, // Smaller font size
                fontWeight:
                    FontWeight.w500, // Medium weight - you can adjust as needed
                color: Colors.black, // Text color - change if needed
              ),
            ),
          ),
        ),
      ),
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
