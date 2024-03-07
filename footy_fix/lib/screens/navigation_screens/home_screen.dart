import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footy_fix/components/venues_tile.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/screens/start_screens/login_screen.dart';
import 'package:footy_fix/services/auth_service.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/screens/profile_screen.dart';
import 'package:footy_fix/screens/notification_screen.dart';
import 'package:footy_fix/screens/feature_manager_screens/game_venue_manager.dart';
import 'package:footy_fix/services/database_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userID = '';
  double balance = 0.0;

  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
    _retrieveUserIdandBalance();
  }

  Future<void> getUserBalance(String id) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');
    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$id/balance', token);

    if (response.statusCode == 200) {
      print('balance: ${response.body}');
      var balanceJson = jsonDecode(response.body);
      double balance = balanceJson;

      setState(() {
        this.balance = balance;
      });
    } else if (response.body.isEmpty) {
      print('No balance');
    } else {
      throw Exception('Failed to load balance');
    }
  }

  Future<void> _retrieveUserIdandBalance() async {
    String? userId = await PreferencesService().getUserId();
    if (userId != null) {
      getUserBalance(userId);
      setState(() {
        userID = userId;
      });
    }
  }

  Future<List<Widget>> buildGameTiles() async {
    List<Map<String, dynamic>> games = await _loadGamesToList();

    if (games.isEmpty) {
      return []; // Return null if no games are found
    }

    return games.map((game) {
      return GameTile(
        locationID: game['venue_id'],
        gameID: game['game_id'],
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadGamesToList() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/by-user/$userID', token);

    if (response.statusCode == 404) {
      return []; // Return null if no games are found
    }

    List<dynamic> gamesData = json.decode(response.body);

    return gamesData.map<Map<String, dynamic>>((game) {
      return {'game_id': game['id'], 'venue_id': game['venueId']};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchLikedVenues() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$userID/venues', token);

    if (response.statusCode == 200) {
      List<dynamic> venuesData = json.decode(response.body);
      return venuesData.map<Map<String, dynamic>>((venue) => venue).toList();
    } else {
      throw Exception('Failed to load venues');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('FitFeat',
                style: TextStyle(color: Colors.black, fontSize: 20)),
            centerTitle: true,
            automaticallyImplyLeading: false,
            leadingWidth: 150,
            leading: InkWell(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ProfileScreen())),
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_circle, color: Colors.black, size: 30),
                    Flexible(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            '\$${balance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            // Continue with the rest of your Text widget properties
                          )),
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              IconButton(
                icon: const Icon(Icons.logout_outlined, color: Colors.black),
                iconSize: 30,
                onPressed: () async {
                  await AuthService().signOut();
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
              ),
            ],
          ),

          // Add bell icon on the right
          // actions: <Widget>[
          //   IconButton(
          //     icon: const Icon(Icons.notifications, color: Colors.black),
          //     iconSize: 30,
          //     onPressed: () {
          //       Navigator.push(
          //           context,
          //           MaterialPageRoute(
          //               builder: (context) => const NotificationScreen()));
          //     },
          //   ),
          // ],

          backgroundColor: Colors.grey[200],
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const GameVenueManager()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: const Size(double.infinity, 36),
                    ),
                    child: const Text('Create a game or venue'),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Liked Venues',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchLikedVenues(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      print('Error: ${snapshot.error}');
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No liked venues found'));
                    }

                    return Container(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var venue = snapshot.data![index];
                          int? imageId;

                          if (venue['imageId'] == null) {
                            print(venue['imageId']);
                            imageId = -1;
                          }

                          return LocationTile(
                            locationName: venue['venueName'],
                            showDistance: false,
                            showRating: false,
                            opacity: 0.4,
                            imageId: imageId!,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LocationDescription(
                                          locationID: venue['id'])));
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Your upcoming games',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                FutureBuilder<List<Widget>>(
                  future: buildGameTiles(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No upcoming games'));
                    }

                    return Container(
                      height: 310, // Adjusted height for the container
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: 300, // Width of each game tile
                            margin: const EdgeInsets.all(8),
                            child:
                                snapshot.data![index], // Each GameTile widget
                          );
                        },
                      ),
                    );
                  },
                )
              ],
            ),
          ),
        ));
  }
}
