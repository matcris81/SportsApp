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
  double price = 0.0;
  bool isFull = false;
  int size = 0;
  int numberOfPlayers = 0;
  String time = '';
  var dayName;
  var dayNumber;
  var monthName;
  bool isLoading = true; // Added isLoading flag
  String address = '';

  @override
  void initState() {
    super.initState();
    // Fetch game info when the screen initializes
    _fetchGameInfo();
  }

  // Function to fetch game info
  Future<void> _fetchGameInfo() async {
    try {
      Map<dynamic, dynamic> gameInfo = await getGameInfo();

      setState(() {
        var venueName = gameInfo['venueName'];
        address = gameInfo['address'];
        var description = gameInfo['description'];
        size = gameInfo['size'];
        numberOfPlayers = gameInfo['players'].length;
        price = gameInfo['price'];
        var date = gameInfo['gameDate'];

        DateTime parsedDate = DateTime.parse(date);
        time = DateFormat('HH:mm:ss').format(parsedDate);
        dayName = DateFormat('EEEE').format(parsedDate);
        dayNumber = DateFormat('d').format(parsedDate);
        monthName = DateFormat('MMMM').format(parsedDate);

        isFull = numberOfPlayers >= size;
        isLoading = false; // Set isLoading to false when data is fetched
      });
    } catch (error) {
      print('Error fetching game info: $error');
    }
  }

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
                  expandedHeight: 150.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/football.jpg',
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
                  child: isLoading
                      ? Center(child: CircularProgressIndicator())
                      : isFull
                          ? SizedBox.shrink()
                          : Column(
                              children: [
                                Card(
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "8v8 Football",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '$dayName, $dayNumber $monthName',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              height: 16,
                                              width:
                                                  1, // Width of the divider line
                                              color: Colors
                                                  .grey, // Color of the divider line
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            Text(
                                              time.substring(0, 5),
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            _buildButton(Icons.directions,
                                                "Get Directions", () {
                                              _launchMaps(context, address);
                                            }),
                                            _buildButton(Icons.share, "Share",
                                                () {
                                              print("share button pressed");
                                            }),
                                            _buildButton(
                                                Icons.help_outline, "Anything",
                                                () {
                                              print("anything button pressed");
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _buildInfoSection(
                                          "Spots Left",
                                          "${size - numberOfPlayers} / $size", // Calculate spots left
                                        ),
                                        _buildInfoSection("Game Length",
                                            "2 hours"), // Replace with actual game length
                                        _buildInfoSection("Sport",
                                            "Football"), // Replace with actual sport name
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  margin: const EdgeInsets.fromLTRB(0.0, 8.0,
                                      0.0, 0.0), // Adjust the horizontal margin
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "About the Game",
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Your game description goes here.", // Replace with your game description
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 30.0),
            child: ElevatedButton(
              onPressed: isLoading || isFull || widget.userAlreadyJoined
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                                  gameID: widget.gameID,
                                )),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoading || isFull
                    ? Colors.grey
                    : Colors.black, // Greyed out if full
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.userAlreadyJoined
                    ? 'Joined'
                    : (isLoading
                        ? 'Loading...'
                        : (isFull
                            ? 'Join (Full)'
                            : 'Join for \$${price.toStringAsFixed(2)}')),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4), // Add spacing between title and value
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue, // Text color set to blue
          ),
        ),
      ],
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        primary: Colors.blue, // Text and icon color
        padding: EdgeInsets.symmetric(vertical: 10), // Add padding
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content in the column
        children: <Widget>[
          Icon(icon, color: Colors.blue), // Icon color set to blue
          Text(
            label,
            style: TextStyle(
              fontSize: 14, // Text style
              color: Colors.blue, // Text color set to blue
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<dynamic, dynamic>> getGameInfo() async {
    Map gameInfo = {};

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}', token);

    Map<String, dynamic> gameDetails = jsonDecode(result.body);

    Map<String, dynamic> venueInfo = await getVenueInfo(gameDetails['venueId']);

    gameInfo.addAll(venueInfo);
    // gameDetails has to be second because it retrieves the players joined for the game (venue would return the players that have liked the venue)
    gameInfo.addAll(gameDetails);

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
