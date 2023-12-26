import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:footy_fix/screens/payment_screen.dart';

class GameDescription extends StatefulWidget {
  final int locationID;
  final int gameID;
  final int sportID;

  const GameDescription({
    Key? key,
    this.locationID = 0,
    required this.gameID,
    this.sportID = 0,
  }) : super(key: key);

  @override
  _GameDescriptionState createState() => _GameDescriptionState();
}

class _GameDescriptionState extends State<GameDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
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
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<Map<dynamic, dynamic>>(
                    future:
                        getGameInfo(), // The async getAddress function is called here
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          var gameDetails = snapshot.data;
                          print(gameDetails);

                          var venueName = gameDetails!['venueName'];
                          var address = gameDetails['address'];
                          var description = gameDetails['description'];
                          var size = gameDetails['size'];
                          var playersJoined = gameDetails['currentPlayers'];
                          var price = gameDetails['price'];
                          var time = gameDetails['time'];
                          var date = gameDetails['date'];

                          var dayName = DateFormat('EEEE').format(date);
                          var dayNumber = DateFormat('d').format(date);
                          var monthName = DateFormat('MMMM').format(date);

                          return Card(
                            margin: const EdgeInsets.all(16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Text(
                                      venueName, // Assuming 'locationName' is a String containing the game's location name
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24,
                                          ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.date_range),
                                    title: Text(
                                        'Date: $dayName, $dayNumber $monthName'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.access_time),
                                    title:
                                        Text('Time: ${time.substring(0, 5)}'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.group),
                                    title: Text(
                                        'Players Joined: $playersJoined/$size'),
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.attach_money),
                                    title: Text(
                                        'Price: \$${price.toStringAsFixed(2)}'),
                                  ),
                                  const Divider(),
                                  ListTile(
                                    leading: const Icon(Icons.location_on),
                                    title: Text(
                                      address, // Display the address here
                                      style: const TextStyle(
                                        fontSize:
                                            14, // Reduce the font size as needed
                                        overflow: TextOverflow
                                            .ellipsis, // Add this to prevent text overflow
                                      ),
                                      maxLines:
                                          1, // Ensure the address is on a single line
                                    ),
                                    subtitle: const Text(
                                        'Click for map'), // Optional: if you want to add functionality to navigate to a map view
                                    onTap: () {
                                      _launchMaps(context, address);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        }
                      }
                      // By default, show a loading spinner while the Future is incomplete
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
              ],
            ),
          ),
          buildJoinButton(context),
        ],
      ),
    );
  }

  Widget buildJoinButton(BuildContext context) {
    return FutureBuilder<Object?>(
      future: PostgresService().retrieve(
          "SELECT current_players, game_date, price FROM games WHERE game_id = ${widget.gameID}"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while waiting
        }

        var paymentDetails = snapshot.data as List<dynamic>;

        var joined = paymentDetails.first[0] as int;
        var date = paymentDetails.first[1] as DateTime;
        var price = paymentDetails.first[2] as double;

        bool isFull = joined >= 10;
        return Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: ElevatedButton(
            onPressed: isFull
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                                gameID: widget.gameID,
                                date: date.toString(),
                                price: price,
                              )),
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isFull ? Colors.grey : Colors.black, // Greyed out if full
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
                side: const BorderSide(color: Colors.white, width: 2),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: Text(
              isFull ? 'Join (Full)' : 'Join',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        );
      },
    );
  }

  Future<Map<dynamic, dynamic>> getGameInfo() async {
    Map gameInfo = {};
    String query =
        "SELECT game_id, venue_id, sport_id, game_date, start_time::text, "
        "description, max_players, current_players, price FROM games WHERE game_id = ${widget.gameID}";

    var gameDetails = await PostgresService().retrieve(query);

    var venueInfo = await getVenueInfo(gameDetails.first[1] as int);

    gameInfo = formatGameInfo(gameDetails.first, venueInfo.first);

    return gameInfo;
  }

  Future<List<dynamic>> getVenueInfo(int venueID) async {
    String query = "SELECT name, address FROM venues WHERE venue_id = $venueID";

    var venueInfo = await PostgresService().retrieve(query);

    return venueInfo;
  }

  Map<dynamic, dynamic> formatGameInfo(
      List<dynamic> gameDetails, List<dynamic> venueInfo) {
    Map gameInfo = {};

    gameInfo['gameID'] = gameDetails[0];
    gameInfo['venueName'] = venueInfo[0];
    gameInfo['address'] = venueInfo[1];
    gameInfo['description'] = gameDetails[5];
    gameInfo['size'] = gameDetails[6];
    gameInfo['currentPlayers'] = gameDetails[7];
    gameInfo['price'] = gameDetails[8];
    gameInfo['date'] = gameDetails[3];
    gameInfo['time'] = gameDetails[4];

    return gameInfo;
  }

  void _showActionSheet(BuildContext context, String location) {
    final String encodedLocation = Uri.encodeComponent(location);
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedLocation";
    final String appleMapsUrl = "https://maps.apple.com/?q=$encodedLocation";

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Open in Maps'),
          message: const Text('Select the maps app to use:'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Apple Maps'),
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunch(appleMapsUrl)) {
                  await launch(appleMapsUrl);
                } else {
                  // Handle the error or inform the user they can't open the map
                }
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Google Maps'),
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunch(googleMapsUrl)) {
                  await launch(googleMapsUrl);
                } else {
                  // Handle the error or inform the user they can't open the map
                }
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _launchMaps(BuildContext context, String location) async {
    if (Platform.isAndroid) {
      // Directly launch Google Maps for Android devices
      await _launchURL(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    } else if (Platform.isIOS) {
      // Show the Cupertino action sheet for iOS devices
      _showActionSheet(context, location);
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error or inform the user they can't open the URL
    }
  }
}
