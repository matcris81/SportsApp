import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/services/database_services.dart';

class GameDescription extends StatefulWidget {
  final int locationID;
  final int gameID;
  final int sportID;
  final bool userAlreadyJoined;

  const GameDescription({
    Key? key,
    required this.locationID,
    required this.gameID,
    this.sportID = 0,
    this.userAlreadyJoined = false,
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
                        print('snapshot.data: ${snapshot.data}}');
                        if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          var gameDetails = snapshot.data;
                          print(
                              'widget.userAlreadyJoined: ${widget.userAlreadyJoined}');

                          var venueName = gameDetails!['venueName'];
                          var address = gameDetails['address'];
                          print('gameDetails');
                          var description = gameDetails['description'];
                          var size = gameDetails['size'];
                          // var playersJoined = gameDetails['currentPlayers'];
                          var price = gameDetails['price'];
                          // var time = gameDetails['time'];
                          var date = gameDetails['gameDate'];

                          DateTime parsedDate = DateTime.parse(date);
                          String time =
                              DateFormat('HH:mm:ss').format(parsedDate);
                          var dayName = DateFormat('EEEE').format(parsedDate);
                          var dayNumber = DateFormat('d').format(parsedDate);
                          var monthName = DateFormat('MMMM').format(parsedDate);

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
                                    title: Text('Players Joined: 0/$size'),
                                    // 'Players Joined: $playersJoined/$size'),
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
          // buildJoinButton(context),
        ],
      ),
    );
  }

  // Widget buildJoinButton(BuildContext context) {
  //   return FutureBuilder<Object?>(
  //     future: PostgresService().retrieve(
  //         "SELECT current_players, game_date, price FROM games WHERE game_id = ${widget.gameID}"),
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const CircularProgressIndicator(); // Show loading indicator while waiting
  //       }

  //       var paymentDetails = snapshot.data as List<dynamic>;

  //       var joined = paymentDetails.first[0] as int;
  //       var date = paymentDetails.first[1] as DateTime;
  //       var price = paymentDetails.first[2] as double;

  //       bool isFull = joined >= 10;
  //       return Container(
  //         padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
  //         child: ElevatedButton(
  //           onPressed: isFull || widget.userAlreadyJoined
  //               ? null
  //               : () {
  //                   Navigator.push(
  //                     context,
  //                     MaterialPageRoute(
  //                         builder: (context) => PaymentScreen(
  //                               gameID: widget.gameID,
  //                               date: date.toString(),
  //                               price: price,
  //                             )),
  //                   );
  //                 },
  //           style: ElevatedButton.styleFrom(
  //             backgroundColor:
  //                 isFull ? Colors.grey : Colors.black, // Greyed out if full
  //             padding: const EdgeInsets.symmetric(vertical: 12.0),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(8.0),
  //               side: const BorderSide(color: Colors.white, width: 2),
  //             ),
  //             minimumSize: const Size(double.infinity, 50),
  //           ),
  //           child: Text(
  //             widget.userAlreadyJoined
  //                 ? 'Joined'
  //                 : (isFull ? 'Join (Full)' : 'Join'),
  //             style: const TextStyle(color: Colors.white, fontSize: 18),
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<Map<dynamic, dynamic>> getGameInfo() async {
    Map gameInfo = {};

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}', token);

    Map<String, dynamic> gameDetails = jsonDecode(result.body);
    print('gameDetails[venueId]: ${gameDetails}');

    Map<String, dynamic> venueInfo = await getVenueInfo(gameDetails['venueId']);

    gameInfo.addAll(gameDetails);
    gameInfo.addAll(venueInfo);

    return gameInfo;
  }

  Future<Map<String, dynamic>> getVenueInfo(int venueID) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/venues/$venueID', token);

    Map<String, dynamic> venueInfo = jsonDecode(result.body);

    return venueInfo;
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
