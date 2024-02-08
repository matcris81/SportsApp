import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:footy_fix/services/notifications_services.dart';

class LocationDescription extends StatefulWidget {
  final String locationName;
  final int locationID;

  // Constructor to accept a string
  const LocationDescription(
      {Key? key, required this.locationName, required this.locationID})
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
    getNextUpcomingGame();
  }

  void checkIfLiked() async {
    String userID = await PreferencesService().getUserId() ?? '';
    bool liked = false;

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$userID/likes-venue/${widget.locationID}',
        token);

    if (response.body == "true") {
      liked = true;
    }

    setState(() {
      isHeartFilled = liked;
    });
  }

  void toggleLike() async {
    String userID = await PreferencesService().getUserId() ?? '';
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var body = {
      "id": userID,
      "venues": [
        {
          "id": widget.locationID,
        }
      ]
    };

    String url = '${DatabaseServices().backendUrl}/api/players/$userID';
    // update user preferences and notifications if liked
    if (isHeartFilled) {
      // remove venue from liked venues
      await DatabaseServices().patchData(
          '${DatabaseServices().backendUrl}/api/players/remove/$userID',
          token,
          body);

      await FirebaseAPI().unsubscribeFromTopic('Venue${widget.locationID}');
    } else {
      // add venue to liked venues
      await DatabaseServices().patchData(url, token, body);
      await FirebaseAPI().subscribeToTopic('Venue${widget.locationID}');
    }

    setState(() {
      isHeartFilled = !isHeartFilled;
    });
  }

  Future<Map<String, dynamic>> getNextUpcomingGame() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/earliest-by-venue?venueId=${widget.locationID}',
        token);

    if (response.statusCode == 404) {
      // throw Exception('No games');
      return {};
    }

    Map<String, dynamic> earliestGame = json.decode(response.body);

    // Check if the games list is empty
    if (earliestGame.isEmpty) {
      return {}; // Or handle this case as per your application's logic
    }

    return earliestGame; // Return the earliest game
  }

  Future<Map<String, dynamic>> getLocationDetails() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/venues/${widget.locationID}',
        token);

    var locationDetails = json.decode(result.body);

    return locationDetails;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: FutureBuilder<Map<String, dynamic>>(
            future: getLocationDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Assuming that each row is a list of fields, and the first row is the venue
              var venueRow = snapshot.data!;
              print('description: ${snapshot.data}');
              // Extracting fields from the row
              var venueAddress = venueRow['address'];
              var venueDescription = 'description';

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
                              InkWell(
                                  onTap: () {
                                    _launchMaps(context, venueAddress);
                                  },
                                  child: Row(
                                    children: <Widget>[
                                      const Icon(
                                        Icons.location_on, // Location icon
                                        color: Colors.grey, // Icon color
                                        size: 20.0, // Icon size
                                      ),
                                      const SizedBox(
                                          width:
                                              8.0), // Spacing between icon and text
                                      Flexible(
                                        // Wrap Text in Flexible
                                        child: Text(
                                          venueAddress, // Place's address
                                          style: const TextStyle(
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.normal,
                                            fontFamily: 'Roboto',
                                          ),
                                          overflow: TextOverflow
                                              .ellipsis, // Add this line to handle overflow
                                          softWrap:
                                              true, // Allow text to wrap onto the next line
                                        ),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                        ),
                        // ),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 4.0, bottom: 4.0),
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
                        // Inside your build method
                        FutureBuilder<Map<String, dynamic>>(
                          future: getNextUpcomingGame(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            // print('snapshot.data: ${snapshot.data}');

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
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
                              );
                            }

                            // var gameRow = snapshot.data!.first;
                            var gameRow = snapshot.data!;

                            // Extract the game details from gameRow
                            var gameId = gameRow['id'];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0), // Add horizontal padding
                              child: Container(
                                height: 310, // Adjust the height as necessary
                                child: GameTile(
                                  gameID: gameId,
                                  locationID: widget.locationID,
                                ),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20.0), // Increase horizontal padding
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) {
                                  return UpcomingGamesList(
                                    locationName: widget.locationName,
                                    venueID: widget.locationID,
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
                                    15), // Less rounded corners
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
                            venueDescription, // Description text
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
