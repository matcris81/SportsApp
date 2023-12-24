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
  final String location;
  final DateTime date;
  final int gameID;
  final String time;
  final String playersJoined;
  final double price;
  final String size;
  final int sportID;

  const GameDescription({
    Key? key,
    this.locationID = 0,
    this.location = '',
    this.sportID = 0,
    required this.gameID,
    required this.date,
    required this.time,
    required this.playersJoined,
    required this.price,
    required this.size,
  }) : super(key: key);

  @override
  _GameDescriptionState createState() => _GameDescriptionState();
}

class _GameDescriptionState extends State<GameDescription> {
  @override
  Widget build(BuildContext context) {
    String dayName = DateFormat('EEEE').format(widget.date).substring(0, 3);
    String monthName = DateFormat('MMMM').format(widget.date);
    int dayNumber = widget.date.day;

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
                  child:
                      buildGameInfoBox(context, dayName, monthName, dayNumber),
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
          "SELECT current_players FROM games WHERE game_id = your_game_id"),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(); // Show loading indicator while waiting
        }
        int joined = 0;
        try {
          // Attempt to cast or convert the data to an integer
          joined = int.parse(snapshot.data.toString());
        } catch (e) {
          print('Error converting snapshot data to int: $e');
          // Handle or report error as appropriate
        }

        bool isFull = joined >= 10;
        return Container(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
          child: ElevatedButton(
            onPressed: isFull
                ? null
                // : () async {
                : () {
                    // await DatabaseServices().incrementValue(
                    //     'Location Details/$location/Games/$date/$gameID/',
                    //     'Players joined');

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PaymentScreen(
                                gameID: widget.gameID.toString(),
                                date: widget.date.toString(),
                                price: widget.price,
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

  Widget buildGameInfoBox(
      BuildContext context, String dayName, String monthName, int dayNumber) {
    // Use a FutureBuilder to wait for the address Future to complete
    return FutureBuilder<List<dynamic>>(
      future: getAddress(), // The async getAddress function is called here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            var gameDetails = snapshot.data!.first;
            print(gameDetails);

            var gameID = gameDetails[0];
            var venueName = gameDetails[1];
            var address = gameDetails[2];
            var description = gameDetails[3];

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
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                      title: Text('Date: $dayName, $dayNumber $monthName'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.access_time),
                      title: Text('Time: ${widget.time}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.group),
                      title: Text(
                          'Players Joined: ${widget.playersJoined}/${widget.size}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.attach_money),
                      title:
                          Text('Price: \$${widget.price.toStringAsFixed(2)}'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.location_on),
                      title: Text(
                        address, // Display the address here
                        style: const TextStyle(
                          fontSize: 14, // Reduce the font size as needed
                          overflow: TextOverflow
                              .ellipsis, // Add this to prevent text overflow
                        ),
                        maxLines: 1, // Ensure the address is on a single line
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
    );
  }

  Future<List<dynamic>> getAddress() async {
    String query = "";
    if (widget.locationID != 0) {
      query = "SELECT * FROM venues WHERE venue_id = ${widget.locationID}";
    } else if (widget.location != "") {
      query = "SELECT * FROM venues WHERE name = '${widget.location}'";
    }
    var address = await PostgresService().retrieve(query);

    return address;
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
