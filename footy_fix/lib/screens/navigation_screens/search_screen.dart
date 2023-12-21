import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
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
  Future<List<String>>? _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems(currentPosition!);
  }

  Future<List<String>>? _loadItems(Position currentPosition) async {
    List<String> locationNamesList = [];

    try {
      Object? locationNames =
          await DatabaseServices().retrieveMultiple('Venues');

      if (locationNames is Map) {
        for (var id in locationNames.keys) {
          var venueDetails = locationNames[id];
          if (venueDetails is Map) {
            for (var venueName in venueDetails.keys) {
              // Assuming each venue has an 'Address' field
              var address = venueDetails[venueName]['Address'];
              String addressString = address.toString();

              Map<double, double>? coordinates = await GeolocatorService()
                  .getCoordinatesFromAddress(addressString);

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

              // Add the venue name to the list
              locationNamesList.add(venueName);
            }
          }
        }
      } else {
        print('locationNames is not a Map');
      }
    } catch (e) {
      print(e);
    }

    return locationNamesList;
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
            child: FutureBuilder<List<String>>(
              future: _itemsFuture,
              builder: (context, snapshot) {
                // Your existing FutureBuilder code
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data != null) {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      String locationName = snapshot.data![index];
                      return Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5), // Increase space between items
                        child: LocationTile(
                          locationName: locationName,
                          distance:
                              distance, // Set actual distance if available
                          opacity: 0.4,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LocationDescription(
                                  locationName: locationName,
                                ),
                              ),
                            );
                          },
                          // Add other relevant parameters
                        ),
                      );
                    },
                  );
                } else {
                  return const Center(child: Text('No data found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
