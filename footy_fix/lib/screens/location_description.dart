import 'package:flutter/material.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:footy_fix/services/database_service.dart';

class LocationDescription extends StatefulWidget {
  final String locationName;

  // Constructor to accept a string
  const LocationDescription({Key? key, required this.locationName})
      : super(key: key);

  @override
  _LocationDescriptionState createState() => _LocationDescriptionState();
}

class _LocationDescriptionState extends State<LocationDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.locationName,
            style: const TextStyle(
              fontSize: 16, // Smaller font size
              fontWeight:
                  FontWeight.w500, // Medium weight - you can adjust as needed
              color: Colors.black, // Text color - change if needed
            ),
          ),
        ),
        body: FutureBuilder<Object?>(
            future: DatabaseServices()
                .retrieveMultiple('Location Details/${widget.locationName}'),
            builder: (context, snapshot) {
              // print(snapshot.data);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              // print(snapshot.data);
              if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              }
              // print(snapshot.data);
              List<String> games = [];
              List<String> upcomingGames = [];
              Map gamesMap = {};
              if (snapshot.data is Map) {
                Map<Object?, Object?> dataMap =
                    snapshot.data as Map<Object?, Object?>;
                print(snapshot.data);
                if (dataMap.containsKey('Games') && dataMap['Games'] is Map) {
                  gamesMap = dataMap['Games'] as Map;
                  gamesMap.forEach((key, value) {
                    // Assuming both key and value are strings or can be converted to strings
                    String gameInfo = "$key: $value";
                    upcomingGames.add(gameInfo);
                  });
                }

                games = dataMap.values.whereType<String>().toList();
                print("Keys: ${dataMap.values.toList()}");
              } else {
                // Handle the case where data is not a map
                return const Center(
                    child: Text('Data is not in the expected format'));
              }

              return Column(
                children: [
                  const SizedBox(height: 150),
                  Expanded(
                    flex: 0, // Reduced flex to make the game info box smaller
                    child: Center(
                      child: SizedBox(
                        width: 300, // Set your desired width
                        height: 100, // Set your desired height
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey
                                .withOpacity(0.2), // Semi-opaque grey
                            borderRadius:
                                BorderRadius.circular(10), // Rounded corners
                          ),
                          child: Center(
                            child: Text('Game Information Here'),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.all(
                        1.0), // Reduced padding to bring elements closer
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) {
                            return UpcomingGamesList(
                              games: gamesMap,
                              locationName: widget.locationName,
                            );
                          }),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.black, // Set the button's background color
                        minimumSize: const Size(
                            300, 50), // Button takes full width available
                      ),
                      child: const Text(
                        'See Upcoming Games',
                        style: TextStyle(
                            color: Colors.white), // Set text color to white
                      ),
                    ),
                  ),
                  const SizedBox(
                      height: 40), // Additional space between button and list
                  Expanded(
                    flex: 3, // Adjust flex to control size of the ListView
                    child: ListView.builder(
                      itemCount: games.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(games[index]),
                        );
                      },
                    ),
                  ),
                ],
              );
            }));
  }
}
