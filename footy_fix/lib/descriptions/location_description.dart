import 'package:flutter/material.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
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
  String locationID = '';

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    getLocationID();
  }

  void getLocationID() async {
    Object? locations = await DatabaseServices().retrieveLocal('Locations');

    if (locations is Map) {
      locations.forEach((key, value) {
        if (value == widget.locationName) {
          locationID = key;
        }
      });
    } else if (locations is String) {
      if (locations == widget.locationName) {
        locationID = locations;
      }
    }
  }

  void checkIfLiked() async {
    String userID = await PreferencesService().getUserId() ?? '';
    bool liked = false;
    Object? received = await DatabaseServices()
        .retrieveLocal('User Preferences/$userID/Liked Venues');

    if (received is Map) {
      received.forEach((key, value) {
        if (value == widget.locationName) {
          liked = true;
        }
      });
    } else if (received is String) {
      if (received == widget.locationName) {
        liked = true;
      }
    }

    setState(() {
      isHeartFilled = liked;
    });
  }

  void toggleLike() async {
    String userID = await PreferencesService().getUserId() ?? '';

    if (isHeartFilled) {
      Object? received = await DatabaseServices().retrieveLocal('Locations');
      DatabaseServices().removeFromDatabase(
          'User Preferences/$userID/Liked Venues/$locationID');
    } else {
      DatabaseServices().addToDataBase(
          'User Preferences/$userID/Liked Venues/$locationID',
          widget.locationName);
    }

    setState(() {
      isHeartFilled = !isHeartFilled;
    });
  }

  DateTime? parseDateTime(String date, String time) {
    try {
      return DateFormat('dd MM yyyy HH:mm').parse('$date $time', true);
    } catch (e) {
      // Handle or log parse error if necessary
      return null;
    }
  }

  Map<dynamic, dynamic> sortAndCreateSortedGamesMap(
      Map<dynamic, dynamic> games) {
    DateTime now = DateTime.now();
    var sortedGames = Map.fromEntries(games.entries.where((entry) {
      var gameDetails = entry.value;
      DateTime? gameDateTime = gameDetails is Map
          ? parseDateTime(gameDetails['Date'], gameDetails['Time'])
          : null;
      return gameDateTime != null && gameDateTime.isAfter(now);
    }).toList()
      ..sort((a, b) {
        var gameADateTime = a.value is Map
            ? parseDateTime(a.value['Date'], a.value['Time'])
            : null;
        var gameBDateTime = b.value is Map
            ? parseDateTime(b.value['Date'], b.value['Time'])
            : null;

        if (gameADateTime != null && gameBDateTime != null) {
          return gameADateTime.compareTo(gameBDateTime);
        } else if (gameADateTime != null) {
          return -1;
        } else if (gameBDateTime != null) {
          return 1;
        } else {
          return 0;
        }
      }));
    return sortedGames;
  }

  MapEntry<dynamic, dynamic>? getNextUpcomingGame(
      Map<dynamic, dynamic> sortedGamesMap) {
    return sortedGamesMap.entries.isNotEmpty
        ? sortedGamesMap.entries.first
        : null;
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
                // Replace this line with a CircularProgressIndicator
                return const Center(child: CircularProgressIndicator());
              }
              List<String> games = [];
              Map gamesMap = {};
              Map<dynamic, dynamic> sortedGamesMap = {};
              Map<Object?, Object?> dataMap = {};

              var nextGameID;
              var nextGameDetails;
              bool hasGames = false;

              if (snapshot.data is Map) {
                dataMap = snapshot.data as Map<Object?, Object?>;

                hasGames = dataMap.containsKey('Games') &&
                    dataMap['Games'] is Map &&
                    (dataMap['Games'] as Map).isNotEmpty;

                if (dataMap.containsKey('Games') && dataMap['Games'] is Map) {
                  gamesMap = dataMap['Games'] as Map;

                  sortedGamesMap = sortAndCreateSortedGamesMap(gamesMap);

                  if (sortedGamesMap.isNotEmpty) {
                    MapEntry<dynamic, dynamic>? nextGameEntry =
                        getNextUpcomingGame(sortedGamesMap);

                    if (sortedGamesMap.isNotEmpty) {
                      // Use nextGameDetails to display the next upcoming game
                      nextGameID = nextGameEntry!.key;
                      nextGameDetails = nextGameEntry.value;
                    }
                    print('nextGameID: $nextGameID');
                    print(
                        'nextGameDetails.runtimeType: ${nextGameDetails.runtimeType}');
                  }
                }
                print(dataMap);
              } else {
                // Handle the case where data is not a map
                return const Center(
                    child: Text('Data is not in the expected format'));
              }
              //extract address and description from games
              var address = dataMap['Address'].toString();
              var description = dataMap['Description'].toString();

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
                                    date:
                                        nextGameDetails!['Date']?.toString() ??
                                            '',
                                    gameID:
                                        nextGameDetails['gameID']?.toString() ??
                                            '',
                                    time: nextGameDetails['Time']?.toString() ??
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
                                            gameID: nextGameDetails!['gameID']
                                                    ?.toString() ??
                                                '',
                                            date: nextGameDetails['gameID']
                                                    ?.toString() ??
                                                '',
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
                                    games: sortedGamesMap,
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
