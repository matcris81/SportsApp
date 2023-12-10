import 'package:flutter/material.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';

class LocationDescription extends StatefulWidget {
  final String locationName;

  // Constructor to accept a string
  const LocationDescription({Key? key, required this.locationName})
      : super(key: key);

  @override
  _LocationDescriptionState createState() => _LocationDescriptionState();
}

class _LocationDescriptionState extends State<LocationDescription> {
  bool isHeartFilled = false; // Tracks if heart is filled or not

  DateTime? parseDateString(String dateString) {
    try {
      var parts = dateString.split(' ');
      return DateTime(
          int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
    } catch (e) {
      // Handle or log parse error if necessary
      return null;
    }
  }

  String findNextUpcomingGame(Map<dynamic, dynamic> games) {
    DateTime now = DateTime.now();
    DateTime? closestDate;
    String closestGameKey = '';
    games.forEach((key, value) {
      DateTime? gameDate = parseDateString(key);
      if (gameDate != null && gameDate.isAfter(now)) {
        // Compare only if closestDate is non-null and ensure closestDate itself is not null in the comparison
        if (closestDate == null || gameDate.isBefore(closestDate!)) {
          closestDate = gameDate;
          closestGameKey = key;
        }
      }
    });

    return closestGameKey;
  }

  Map<String, dynamic>? findEarliestGameTime(
      Map<dynamic, dynamic> games, String date) {
    var gamesForDate = games[date];
    DateTime? earliestTime;
    Map<String, dynamic>? earliestGameInfo;

    print(date);
    if (gamesForDate is Map) {
      gamesForDate.forEach((gameID, gameDetails) {
        if (gameDetails is Map && gameDetails['Time'] is String) {
          var timeString = gameDetails['Time'];
          // Assuming the time is in HH:MM format, adjust the format if necessary
          var gameDateTime = DateFormat('HH:mm').parse(timeString, true);

          // Set the date part to be the same for all game times to compare only the time part
          gameDateTime =
              DateTime(2000, 1, 1, gameDateTime.hour, gameDateTime.minute);

          if (earliestTime == null || gameDateTime.isBefore(earliestTime!)) {
            earliestTime = gameDateTime;
            earliestGameInfo = {'gameID': gameID, 'details': gameDetails};
          }
        }
      });
    }
    return earliestGameInfo;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<Object?>(
            future: DatabaseServices()
                .retrieveMultiple('Location Details/${widget.locationName}'),
            builder: (context, snapshot) {
              print("snappie: ${snapshot.data}");
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              }
              List<String> games = [];
              List<String> upcomingGames = [];
              Map gamesMap = {};

              String date = '';
              Map? nextGame;
              Map? nextGameDetails;
              bool hasGames = false;

              if (snapshot.data is Map) {
                Map<Object?, Object?> dataMap =
                    snapshot.data as Map<Object?, Object?>;
                hasGames = dataMap.containsKey('Games') &&
                    dataMap['Games'] is Map &&
                    (dataMap['Games'] as Map).isNotEmpty;

                if (dataMap.containsKey('Games') && dataMap['Games'] is Map) {
                  gamesMap = dataMap['Games'] as Map;
                  gamesMap.forEach((key, value) {
                    // Assuming both key and value are strings or can be converted to strings
                    String gameInfo = "$key: $value";
                    upcomingGames.add(gameInfo);
                  });
                }

                games = dataMap.values.whereType<String>().toList();
                // print(gamesMap);
                // find next upcoming game
                date = findNextUpcomingGame(gamesMap);
                nextGame = findEarliestGameTime(gamesMap, date);
                nextGameDetails = nextGame?['details'];
              } else {
                // Handle the case where data is not a map
                return const Center(
                    child: Text('Data is not in the expected format'));
              }
              print(nextGame);

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Image.asset(
                        'assets/albany.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    leading: IconButton(
                      icon: const CircleAvatar(
                        backgroundColor:
                            Colors.white, // Background color of the circle
                        child: Icon(Icons.arrow_back,
                            color: Colors.black), // Black arrow icon
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: <Widget>[
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor:
                              Colors.white, // Background color of the circle
                          child: Icon(
                            isHeartFilled
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isHeartFilled
                                ? Colors.red
                                : Colors.black, // Black heart icon
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            isHeartFilled = !isHeartFilled; // Toggle the state
                          });
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Next Game', // Your title text here
                            style: TextStyle(
                              fontSize: 24.0, // Adjust the font size as needed
                              fontWeight: FontWeight
                                  .bold, // Adjust the font weight as needed
                            ),
                          ),
                        ),
                        hasGames
                            ? Expanded(
                                flex:
                                    0, // Reduced flex to make the game info box smaller
                                child: GameTile(
                                  location: widget.locationName,
                                  date: date,
                                  gameID: nextGame!['gameID']?.toString() ?? '',
                                  time: nextGameDetails!['Time']?.toString() ??
                                      '',
                                  size:
                                      nextGameDetails['Size']?.toString() ?? '',
                                  price: nextGameDetails['Price']?.toDouble() ??
                                      0.0,
                                  playersJoined:
                                      nextGameDetails['Players joined']
                                              ?.toString() ??
                                          '',
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => GameDescription(
                                          location: widget.locationName,
                                          gameID:
                                              nextGame!['gameID']?.toString() ??
                                                  '',
                                          date: date,
                                          time: nextGameDetails!['Time']
                                                  ?.toString() ??
                                              '',
                                          size: nextGameDetails['Size']
                                                  ?.toString() ??
                                              '',
                                          price:
                                              (nextGameDetails['Price'] is num)
                                                  ? nextGameDetails['Price']
                                                      .toDouble()
                                                  : 0.0,
                                          playersJoined:
                                              nextGameDetails['Players joined']
                                                      ?.toString() ??
                                                  '',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "No upcoming games",
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(
                              1.0), // Reduced padding to bring elements closer
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return UpcomingGamesList(
                                    games: gamesMap,
                                    locationName: widget.locationName,
                                  );
                                }),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors
                                  .black, // Set the button's background color
                              minimumSize: const Size(
                                  300, 50), // Button takes full width available
                            ),
                            child: const Text(
                              'See Upcoming Games',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return ListTile(
                          title: Text(games[index]),
                        );
                      },
                      childCount: games.length,
                    ),
                  ),
                ],
              );
            }));
  }
}
