import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/screens/checkout_screen.dart';
import 'package:footy_fix/services/database_services.dart';
import 'dart:convert';

class GameTile extends StatelessWidget {
  final int locationID;
  final int gameID;
  final bool payment;

  const GameTile(
      {Key? key,
      required this.gameID,
      this.locationID = 0,
      this.payment = false})
      : super(key: key);

  Future<Map<String, dynamic>> fetchGameDetails(int gameId) async {
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/games/$gameId');

    var playerCountResponse = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/$gameId/players-count');

    var playerCount = json.decode(playerCountResponse.body);
    print('playerCount: $playerCount');

    Map<String, dynamic> gameDetails = json.decode(result.body);

    if (gameDetails.isNotEmpty) {
      gameDetails['playerCount'] = playerCount;

      return gameDetails;
    }
    return {};
  }

  Future<bool> hasPlayerJoined(String gameID) async {
    var userID = await PreferencesService().getUserId();

    var gamesJoined = await PreferencesService().getIntList('gamesJoined');

    if (gamesJoined.contains(int.parse(gameID))) {
      return true;
    }
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');
    // var result = await DatabaseServices().getData(
    //     '${DatabaseServices().backendUrl}/api/games/$gameID/get-players',
    //     token);
    // List<dynamic> players = json.decode(result.body);

    // for (var player in players) {
    //   var playerId = player['id'];
    //   if (playerId == userID) {
    //     return true;
    //   }
    // }

    return false;
  }

  void tileTap(BuildContext context, bool userAlreadyJoined) {
    if (payment) {
      return;
    }
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => GameDescription(
                  gameID: gameID,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchGameDetails(gameID),
      builder: (context, snapshot) {
        Widget content;
        if (snapshot.connectionState == ConnectionState.waiting) {
          content = const SizedBox(
            height: 200,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
              height: 200, child: Center(child: Text('Loading...')));
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
        var fakePlayers = gameDetails['fakePlayers'];
        var size = gameDetails['size'];
        var price = gameDetails['price'];

        return FutureBuilder<bool>(
            future: hasPlayerJoined(gameID.toString()),
            builder: (context, hasJoinedSnapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                content = const SizedBox(
                  height: 200,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
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
                            top: 65,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Icon(
                                Icons.sports_soccer,
                                size: 16,
                                color: Colors.white,
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
                            if (!payment) const Divider(),
                            if (!payment)
                              Text(
                                playersJoined == size
                                    ? "Full"
                                    : "$playersJoined/$size have joined",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (!payment)
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
                                    hasJoined || playersJoined == size
                                        ? Colors.grey
                                        : Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              onPressed: hasJoined || playersJoined == size
                                  ? null
                                  : () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CheckoutScreen(
                                                    gameID: gameID,
                                                  )));
                                    },
                              child: Text(playersJoined == size
                                  ? 'Game Full'
                                  : hasJoined
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
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/venues/$venueId');

    Map<String, dynamic> resultJson = jsonDecode(result.body);

    String venueName = resultJson['venueName'];

    return venueName;
  }
}
