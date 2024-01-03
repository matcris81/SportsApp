import 'package:flutter/material.dart';
import 'package:footy_fix/components/venues_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/screens/profile_screen.dart';
import 'package:footy_fix/screens/notification_screen.dart';
import 'package:footy_fix/screens/feature_manager_screens/game_venue_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userID = '';

  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
    _retrieveUserId();
  }

  Future<void> _retrieveUserId() async {
    String? fetchedUserId = await PreferencesService().getUserId();
    if (fetchedUserId != null) {
      setState(() {
        userID = fetchedUserId;
      });
    }
  }

  Future<List<Widget>> buildGameTiles() async {
    List<Map<String, dynamic>> games = await _loadGamesToList();

    return games.map((game) {
      return GameTile(
        locationID: game['venue_id'],
        gameID: game['game_id'],
      );
    }).toList();
  }

  Future<List<Map<String, dynamic>>> _loadGamesToList() async {
    List<List<dynamic>> games =
        await PostgresService().retrieve("SELECT g.game_id, g.venue_id "
            "FROM games g "
            "INNER JOIN user_game_participation ugp ON g.game_id = ugp.game_id "
            "WHERE ugp.user_id = '$userID'");

    return games.map((row) {
      return {'game_id': row[0], 'venue_id': row[1]};
    }).toList();
  }

  Future<List<int>> getLikedVenueID() async {
    List<List<dynamic>> results = await PostgresService().retrieve(
        "SELECT likeable_id FROM user_likes WHERE user_id = '$userID' AND likeable_type = 'venue'");

    return results.map((row) => row[0] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getVenueDetails(List<int> venueIds) async {
    // List<int> venueIds = await getLikedVenueID();

    // Convert the list of IDs to a comma-separated string
    String idsString = venueIds.join(', ');

    // Build the SQL query
    String query = 'SELECT * FROM venues WHERE venue_id IN ($idsString)';

    // Execute the query
    List<List<dynamic>> results = await PostgresService().retrieve(query);

    // Convert the results to a list of maps for easier usage
    return results.map((row) {
      return {
        'venue_id': row[0],
        'name': row[1],
        'address': row[2],
        'description': row[3],
        // Add other fields as needed
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('FitFeat',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // This line removes the default back button

        // Add profile icon on the left
        leading: IconButton(
          icon: const Icon(Icons.account_circle, color: Colors.black),
          iconSize: 25,
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()));
          },
        ),

        // Add bell icon on the right
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            iconSize: 25,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NotificationScreen()));
            },
          ),
        ],
      ),

      backgroundColor: Colors.grey[200], // Set the background color to grey
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .start, // Aligns children to the start of the column
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GameVenueManager()));
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
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
                  fontSize: 20, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Makes the text bold
                  color: Colors.black, // Set the color of the text
                ),
              ),
            ),
            FutureBuilder<List<int>>(
              future: getLikedVenueID(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No liked venues found'));
                }

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: getVenueDetails(snapshot.data!),
                  builder: (context, venueSnapshot) {
                    if (venueSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (venueSnapshot.hasError) {
                      return Center(
                          child: Text('Error: ${venueSnapshot.error}'));
                    }

                    if (!venueSnapshot.hasData || venueSnapshot.data!.isEmpty) {
                      return Center(child: Text('Venue details not found'));
                    }

                    return Container(
                      height: 150, // Adjust the height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: venueSnapshot.data!.length,
                        itemBuilder: (context, index) {
                          var venue = venueSnapshot.data![index];
                          return LocationTile(
                            locationName: venue['name'],
                            showDistance: false,
                            showRating: false,
                            opacity: 0.4,
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => LocationDescription(
                                          locationName: venue['name'],
                                          locationID: venue['venue_id'])));
                            },
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Your upcoming games', // NEED TO CHANGE THIS TO BE UPCOMING GAMES INSTEAD OF GAMES USERS HAVE JOINED
                style: TextStyle(
                  fontSize: 20, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Makes the text bold
                  color: Colors.black, // Set the color of the text
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
                  return const Center(child: Text('No games found'));
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
                        child: snapshot.data![index], // Each GameTile widget
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
