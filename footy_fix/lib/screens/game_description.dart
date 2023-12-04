import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:footy_fix/services/database_service.dart';

class GameDescription extends StatelessWidget {
  final String locationName;
  final DateTime date;
  final String time;
  final String playersJoined;
  final double price;
  final String size;

  const GameDescription({
    Key? key,
    required this.locationName,
    required this.date,
    required this.time,
    required this.playersJoined,
    required this.price,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String dayName = DateFormat('EEEE').format(date).substring(0, 3);
    String monthName = DateFormat('MMMM').format(date);
    int dayNumber = date.day;

    return Scaffold(
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
    return Container(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 24.0),
      child: ElevatedButton(
        onPressed: () {
          // Action when the button is pressed
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.black,
          padding: EdgeInsets.symmetric(vertical: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Colors.white, width: 2),
          ),
          minimumSize: Size(double.infinity, 50),
        ),
        child: Text(
          'Join',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }

  Widget buildGameInfoBox(
      BuildContext context, String dayName, String monthName, int dayNumber) {
    // Use a FutureBuilder to wait for the address Future to complete
    return FutureBuilder<Object?>(
      future: getAddress(), // The async getAddress function is called here
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            // Cast the data to String, or handle it accordingly if it's not a String
            final address = snapshot.data as String? ?? 'Address not available';

            return Card(
              margin: EdgeInsets.all(16.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        locationName, // Assuming 'locationName' is a String containing the game's location name
                        style: Theme.of(context).textTheme.headline6?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 8),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.date_range),
                      title: Text('Date: $dayName, $dayNumber $monthName'),
                    ),
                    ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Time: $time'),
                    ),
                    ListTile(
                      leading: Icon(Icons.group),
                      title: Text('Players Joined: $playersJoined/$size'),
                    ),
                    ListTile(
                      leading: Icon(Icons.attach_money),
                      title: Text('Price: \$${price.toStringAsFixed(2)}'),
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text(locationName), // Display the address here
                      subtitle: Text(
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
        return Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Object?> getAddress() {
    return DatabaseServices()
        .retrieveFromDatabase('Location Details/$locationName/Address');
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
            child: const Text('Cancel'),
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
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
