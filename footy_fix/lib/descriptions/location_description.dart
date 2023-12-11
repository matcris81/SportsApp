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

  @override
  void initState() {
    super.initState();
    checkIfLiked();
  }

  void checkIfLiked() async {
    bool liked = false;
    Object? received = await DatabaseServices().retrieveMultiple('User Preferences/Liked Venues/');
    
    if(received is Map) {
      received.forEach((key, value) {
        if (value == widget.locationName) {
          liked = true;
        }
      });
    }

    setState(() {
      isHeartFilled = liked;
    });
  }

  void toggleLike() async {
    if (isHeartFilled) {
      Object? received = await DatabaseServices().retrieveMultiple('Locations');
      print(received);
      DatabaseServices().removeFromDatabase('User Preferences/Liked Venues/${widget.locationName}');
    } else {
      DatabaseServices().addToDataBase('User Preferences/Liked Venues/', widget.locationName);
    }

    setState(() {
      isHeartFilled = !isHeartFilled;
    });
  }

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
        backgroundColor: Colors.grey[300],
        body: FutureBuilder<Object?>(
            future: DatabaseServices()
                .retrieveMultiple('Location Details/${widget.locationName}'),
            builder: (context, snapshot) {
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

                // find next upcoming game
                date = findNextUpcomingGame(gamesMap);
                nextGame = findEarliestGameTime(gamesMap, date);
                nextGameDetails = nextGame?['details'];
              } else {
                // Handle the case where data is not a map
                return const Center(
                    child: Text('Data is not in the expected format'));
              }
              //extract address and description from games
              var address = games[0];
              var description = games[1];

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    // Your existing SliverAppBar properties
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
                          toggleLike();
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                widget.locationName, // Place's name
                                style: const TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 8.0),
                              const Divider(), // Divider line
                              const SizedBox(height: 8.0),
                              Row(
                                children: <Widget>[
                                  const Icon(
                                    Icons.location_on, // Location icon
                                    color: Colors.grey, // Icon color
                                    size: 20.0, // Icon size
                                  ),
                                  const SizedBox(
                                      width:
                                          8.0), // Spacing between icon and text
                                  Text(
                                    address, // Place's address
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // ),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 4.0, right: 4.0, bottom: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Next Game', // Your title text here
                              style: TextStyle(
                                fontSize:
                                    15.0, // Adjust the font size as needed
                                fontWeight: FontWeight
                                    .bold, // Adjust the font weight as needed
                              ),
                            ),
                          ),
                        ),
                        hasGames
                            ? Expanded(
                                flex:
                                    0, // Reduced flex to make the game info box smaller
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          16.0), // Add horizontal padding
                                  child: GameTile(
                                    location: widget.locationName,
                                    date: date,
                                    gameID:
                                        nextGame!['gameID']?.toString() ?? '',
                                    time:
                                        nextGameDetails!['Time']?.toString() ??
                                            '',
                                    size: nextGameDetails['Size']?.toString() ??
                                        '',
                                    price:
                                        nextGameDetails['Price']?.toDouble() ??
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
                                            gameID: nextGame!['gameID']
                                                    ?.toString() ??
                                                '',
                                            date: date,
                                            time: nextGameDetails!['Time']
                                                    ?.toString() ??
                                                '',
                                            size: nextGameDetails['Size']
                                                    ?.toString() ??
                                                '',
                                            price: (nextGameDetails['Price']
                                                    is num)
                                                ? nextGameDetails['Price']
                                                    .toDouble()
                                                : 0.0,
                                            playersJoined: nextGameDetails[
                                                        'Players joined']
                                                    ?.toString() ??
                                                '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ))
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
                                      offset: const Offset(0, 3),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0), // Increase horizontal padding
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
                              backgroundColor: Colors
                                  .black, // Set the button's background color
                              minimumSize: const Size(double.infinity,
                                  50), // Button width will be the width of the parent minus padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    5), // Less rounded corners
                              ),
                            ),
                            child: const Text(
                              'See Upcoming Games',
                              style: TextStyle(
                                  color:
                                      Colors.white), // Set text color to white
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            "About the venue", // Title text
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 16.0),
                          child: Text(
                            description, // Description text
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}
