import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/services/database_services.dart';
import 'dart:convert';

class GameTile extends StatelessWidget {
  final int locationID;
  final int gameID;

  const GameTile({Key? key, required this.gameID, this.locationID = 0})
      : super(key: key);

  Future<Map<String, dynamic>> fetchGameDetails(int gameId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/games/$gameId', token);

    var playerCountResponse = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/$gameId/players-count',
        token);

    var playerCount = json.decode(playerCountResponse.body);

    Map<String, dynamic> gameDetails = json.decode(result.body);

    if (gameDetails.isNotEmpty) {
      gameDetails['playerCount'] = playerCount;

      return gameDetails;
    }
    return {};
  }

  Future<bool> hasPlayerJoined(String gameID) async {
    var userID = await PreferencesService().getUserId();

    return false;
  }

  void tileTap(BuildContext context, bool userAlreadyJoined) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GameDescription(
                  gameID: gameID,
                  // locationID: locationID,
                  // userAlreadyJoined: userAlreadyJoined,
                )));
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
        var dateString = gameDetails['gameDate'] as String;
        DateTime dateTime = DateTime.parse(dateString);
        var dayOfWeek = DateFormat('EEEE').format(dateTime);
        var abbreviatedDayName = dayOfWeek.substring(0, 3).toUpperCase();
        var abbreviatedMonthName =
            DateFormat('MMM').format(dateTime).toUpperCase();
        var time = DateFormat('HH:mm:ss').format(dateTime);
        var playersJoined = gameDetails['playerCount'];
        print('playersJoined: $playersJoined');
        var size = gameDetails['size'];
        var price = gameDetails['price'];

        return FutureBuilder<bool>(
            future: hasPlayerJoined(gameID.toString()),
            builder: (context, hasJoinedSnapshot) {
              if (hasJoinedSnapshot.connectionState ==
                  ConnectionState.waiting) {
                return CircularProgressIndicator();
              }

              if (hasJoinedSnapshot.hasError) {
                return Text('Error: ${hasJoinedSnapshot.error}');
              }

              bool hasJoined = hasJoinedSnapshot.data ?? false;

              return GestureDetector(
                onTap: () => tileTap(context, hasJoined),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
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
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      );
                                    },
                                  )
                                : const Text(
                                    "Unkown Venue",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              '$abbreviatedDayName, $abbreviatedMonthName ${dateTime.day} • ${time.substring(0, 5)}',
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
                              horizontal: 40, vertical: 0),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor:
                                  hasJoined ? Colors.grey : Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: hasJoined
                                ? null
                                : () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PaymentScreen(
                                                  gameID: gameID,
                                                )));
                                  },
                            child: Text(hasJoined
                                ? 'Joined'
                                : 'Join for \$${price.toStringAsFixed(2)}'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
      },
    );
  }

  Future<String> fetchVenueName(int venueId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/venues/$venueId', token);

    Map<String, dynamic> resultJson = jsonDecode(result.body);

    String venueName = resultJson['venueName'];

    return venueName;
  }
}
