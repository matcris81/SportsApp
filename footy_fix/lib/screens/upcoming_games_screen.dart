import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/screens/game_description.dart';
import 'package:intl/intl.dart';

class UpcomingGamesList extends StatelessWidget {
  final Map<dynamic, dynamic> games;
  final String locationName;

  // Constructor to accept a list of games
  const UpcomingGamesList(
      {Key? key, required this.locationName, required this.games})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$locationName Upcoming Games',
          style: const TextStyle(
            fontSize: 16, // Smaller font size
            fontWeight:
                FontWeight.w500, // Medium weight - you can adjust as needed
            color: Colors.black, // Text color - change if needed
          ),
          textAlign: TextAlign.center, // Center align text if needed
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(), // Navigate back
        ),
      ),
      body: Container(
        color: Colors.white, // Change the background color
        child: ListView.builder(
          itemCount: games.length,
          itemBuilder: (context, index) {
            var date = games.keys.elementAt(index);
            // DateTime dateTime = DateFormat('dd MM yyyy').parse(date);

            var gamesForDate = games[date];
            String gameID = gamesForDate.keys.first;
            var gameDetails = gamesForDate[gameID];

            return Card(
              child: GameTile(
                location: locationName,
                gameID: gameID,
                time: gameDetails['Time']?.toString() ??
                    '', // Use the correct key
                size: gameDetails['Size']?.toString() ??
                    '', // Use the correct key
                price: gameDetails['Price']?.toDouble() ?? '',
                playersJoined: gameDetails['Players joined']?.toString() ??
                    '', // Use the correct key
                onTap: () {
                  // Handle the game item tap, if necessary
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDescription(
                        location: locationName,
                        gameID: gameID,
                        date: date,
                        time: gameDetails['Time']?.toString() ?? '',
                        size: gameDetails['Size']?.toString() ?? '',
                        price: (gameDetails['Price'] is num)
                            ? gameDetails['Price'].toDouble()
                            : 0.0, // Safeguard for price
                        playersJoined:
                            gameDetails['Players joined']?.toString() ?? '',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
