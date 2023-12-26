import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/screens/payment_screen.dart';

class GameTile extends StatelessWidget {
  final int locationID;
  final int gameID;
  final Function()? onTap;

  const GameTile(
      {Key? key, required this.gameID, this.locationID = 0, this.onTap})
      : super(key: key);

  Future<Map<String, dynamic>> fetchGameDetails(int gameId) async {
    // Placeholder for database call
    // Replace with your actual database service call to fetch game details
    var gameDetails = await PostgresService().retrieve(
        "SELECT game_id, venue_id, sport_id, game_date, start_time::text, description, max_players, current_players, price FROM games "
        "WHERE game_id = $gameId");

    if (gameDetails.isNotEmpty) {
      var row = gameDetails.first;
      return {
        'venue_id': row[1],
        'game_date': row[3] as DateTime,
        'time': row[4],
        'description': row[5],
        'max_players': row[6].toString(),
        'current_players': row[7].toString(),
        'price': row[8],
        // Add other game fields as required
      };
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchGameDetails(gameID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Game details not found');
        }

        var gameDetails = snapshot.data!;
        var date = gameDetails['game_date'] as DateTime;
        var dayOfWeek = DateFormat('EEEE').format(date);
        var abbreviatedDayName = dayOfWeek.substring(0, 3).toUpperCase();
        var abbreviatedMonthName = DateFormat('MMM').format(date).toUpperCase();
        var time = gameDetails['time'] as String;
        var playersJoined = int.parse(gameDetails['current_players'] as String);
        var size = int.parse(gameDetails['max_players'] as String);
        var price = gameDetails['price'];

        return GestureDetector(
          onTap: onTap,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize
                  .min, // Add this to make the card wrap content height
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.asset(
                        'assets/football.jpg',
                        fit: BoxFit.cover,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    Positioned(
                      top: 65, // Adjust the position as needed
                      right: 8, // Adjust the position as needed
                      child: Container(
                        padding: const EdgeInsets.all(
                            6), // Padding inside the container for the icon
                        decoration: BoxDecoration(
                          color: Colors.black
                              .withOpacity(0.5), // Semi-transparent black
                          borderRadius: BorderRadius.circular(
                              4), // Slightly rounded corners for the square
                        ),
                        child: const Icon(
                          Icons
                              .sports_soccer, // Use the appropriate Icons value
                          size: 16, // Size of the icon
                          color: Colors.white, // Color of the icon
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      locationID != 0
                          ? FutureBuilder<String>(
                              future: fetchVenueName(locationID),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text('Loading...');
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                String venueName =
                                    snapshot.data ?? 'Unknown Venue';
                                return Text(
                                  venueName.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                  overflow:
                                      TextOverflow.ellipsis, // Add this line
                                  maxLines: 1, // Ensure it's only one line
                                );
                              },
                            )
                          : const Text(
                              "Unkown Venue",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              overflow: TextOverflow.ellipsis, // Add this line
                              maxLines: 1, // Ensure it's only one line
                            ),
                      const SizedBox(height: 4),
                      Text(
                        '$abbreviatedDayName, $abbreviatedMonthName ${date.day} • ${time.substring(0, 5)}',
                        style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      const SizedBox(height: 4),
                      const Divider(),
                      Text(
                        '$playersJoined/$size spots left',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical:
                            0), // Increase horizontal padding to make the button narrower
                    child: TextButton(
                      style: TextButton.styleFrom(
                        primary: Colors.white,
                        minimumSize: const Size.fromHeight(
                            50), // Keeps the button height
                        backgroundColor: Colors.black, // Button color
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(30), // Very rounded edges
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                      gameID: gameID,
                                      price: price,
                                      date: date.toString(),
                                    )));
                      }, // Use the onTap passed to the widget
                      child: Text(
                          'Join for \$${price.toStringAsFixed(2)}'), // Formats the price with 2 decimal places
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> fetchVenueName(int venueId) async {
    var venueName = await PostgresService()
        .retrieve("SELECT name FROM venues WHERE venue_id = $venueId");

    return venueName[0][0].toString();
  }
}
