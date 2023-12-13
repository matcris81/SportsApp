import 'package:flutter/material.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/descriptions/game_description.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> venuesList = [];
  List<Widget> gamesList = [];

  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
    _loadPreferences();
  }

  List<Widget> createGameTiles(Map data) {
    List<Widget> gameTiles = [];

    data.forEach((location, games) {
      if (games is Map) {
        games.forEach((gameID, gameDetails) {
          if (gameDetails is Map) {
            // Extract game details
            String size = gameDetails['Size'].toString();
            String time = gameDetails['Time'];
            String playersJoined = gameDetails['Players joined'].toString();
            double price =
                double.tryParse(gameDetails['Price'].toString()) ?? 0.0;

            // Assuming date needs to be passed, but it's not available in data. Using current date.
            String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

            // Create a GameTile
            Widget gameTile = GameTile(
              location: location,
              date: date, // Placeholder date
              gameID: gameID,
              time: time,
              playersJoined: playersJoined,
              price: price,
              size: size,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => GameDescription(
                            location: location,
                            gameID: gameID,
                            date: date,
                            time: time,
                            playersJoined: playersJoined,
                            price: price,
                            size: size)));
              },
            );

            gameTiles.add(gameTile);
          }
        });
      }
    });

    return gameTiles;
  }

  void populateLists(dynamic data) {
    if (data is Map) {
      var likedVenuesMap = data['Liked Venues'];
      var joinedGamesMap = data['Games joined'];

      List<String> venueNames = [];
      List<Widget> gameNames = [];

      if (likedVenuesMap is Map) {
        venueNames = likedVenuesMap.values.map((v) => v.toString()).toList();
      } else {
        print('Liked Venues is not a map');
      }

      if (joinedGamesMap is Map) {
        gameNames = createGameTiles(joinedGamesMap);
      } else {
        print('Games joined is not a map');
      }

      setState(() {
        venuesList = venueNames;
        gamesList = gameNames;
      });
    } else {
      print('Data is not a map');
    }
  }

  Future<void> _loadPreferences() async {
    String userID = await PreferencesService().getUserId() ?? '';

    var data =
        await DatabaseServices().retrieveLocal('User Preferences/$userID/');

    if (data is Map) {
      populateLists(data);
    } else {
      print('Data is not a map');
    }
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
            // Add your onTap functionality here
            print('Profile icon tapped');
          },
        ),

        // Add bell icon on the right
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            iconSize: 25,
            onPressed: () {
              // Add your onTap functionality here
              print('Bell icon tapped');
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
                  // do something
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  minimumSize: const Size(double.infinity, 36),
                ),
                child: const Text('Find a Game'),
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
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: venuesList.length,
                itemBuilder: (context, index) {
                  return InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LocationDescription(
                                      locationName: venuesList[index],
                                    )));
                      },
                      child: Container(
                        width: 200,
                        child: Card(
                          child: Column(
                            children: [
                              Text(venuesList[index]),
                            ],
                          ),
                        ),
                      ));
                },
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Your upcoming games',
                style: TextStyle(
                  fontSize: 20, // Adjust the font size as needed
                  fontWeight: FontWeight.bold, // Makes the text bold
                  color: Colors.black, // Set the color of the text
                ),
              ),
            ),
            Container(
              height: 200, // Set the height of the container
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: gamesList.length,
                itemBuilder: (context, index) {
                  return Container(
                    width:
                        300, // Define a fixed width for each game tile if necessary
                    margin: const EdgeInsets.all(
                        8), // Add some margin around the card
                    child: AspectRatio(
                      aspectRatio:
                          4 / 3, // Example aspect ratio, adjust as needed
                      child: gamesList[index], // Your GameTile widget
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
