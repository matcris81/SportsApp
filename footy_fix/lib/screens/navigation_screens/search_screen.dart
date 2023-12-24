import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/components/venues_tile.dart';

class SearchScreen extends StatefulWidget {
  // Constructor to accept a string
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Position? currentPosition = GeolocatorService().currentPosition;
  double distance = 0;
  late Future<Map<String, Map<String, dynamic>>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems(currentPosition!);
  }

  Future<Map<String, Map<String, dynamic>>> _loadItems(
      Position currentPosition) async {
    Map<String, Map<String, dynamic>> venues = {};

    try {
      var result = await PostgresService()
          .retrieveRows('venues', 'venue_id, address, name');

      if (result is List) {
        for (var venue in result) {
          if (venue is List && venue.length >= 3) {
            String venueID = venue[0]?.toString() ?? 'Unknown ID';
            String address = venue[1] as String? ?? 'Unknown Address';
            String venueName = venue[2] as String? ?? 'Unknown Name';

            // get address coordinates
            Map<double, double>? coordinates =
                await GeolocatorService().getCoordinatesFromAddress(address);

            if (coordinates != null) {
              distance = GeolocatorService().calculateDistance(
                currentPosition.latitude,
                currentPosition.longitude,
                coordinates.keys.first,
                coordinates.values.first,
              );

              distance /= 1000; // Convert to km if necessary
              // Handle the distance value as needed
            }

            venues[venueID] = {'name': venueName, 'distance': distance};
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return venues;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Search',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading:
            false, // This line removes the default back button
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Align title to the left
        children: [
          Expanded(
              // Use Expanded to fill the remaining space with the FutureBuilder
              child: FutureBuilder<Map<String, Map<String, dynamic>>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    String id = snapshot.data!.keys.elementAt(index);
                    String venueName = snapshot.data![id]!['name'];
                    double distance = snapshot.data![id]!['distance'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: LocationTile(
                        locationName: venueName,
                        distance: distance,
                        opacity: 0.4,
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                            builder: (context) {
                              return LocationDescription(
                                locationName: venueName,
                                locationID: id,
                              );
                            },
                          ));
                        },
                        // Other parameters
                      ),
                    );
                  },
                );
              } else {
                return const Center(child: Text('No data found'));
              }
            },
          )),
        ],
      ),
    );
  }
}
