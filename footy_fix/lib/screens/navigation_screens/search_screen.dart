import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/components/my_list_item.dart';

class SearchScreen extends StatefulWidget {
  // Constructor to accept a string
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Position? currentPosition = GeolocatorService().currentPosition;

  Future<List<MyListItem>>? _itemsFuture;

  @override
  void initState() {
    super.initState();
    _itemsFuture = _loadItems(currentPosition!);
  }

  Future<List<MyListItem>> _loadItems(Position currentPosition) async {
    Object? locationNames =
        await DatabaseServices().retrieveMultiple('Locations');

    List<String> locationNamesList = [];
// Check if locationNames is a list
    if (locationNames is List) {
      // Convert each item in the list to a string
      locationNamesList = locationNames.map((item) => item.toString()).toList();
    } else {
      // Handle the case where locationNames is not a list
      print('locationNames is not a list');
    }
    List<MyListItem> items = [];

    for (String locationName in locationNamesList) {
      if (locationName != null) {
        // Fetch address from the database
        var address = await DatabaseServices()
            .retrieveFromDatabase('Location Details/$locationName/Address');
        String addressString = address.toString();

        // Get coordinates from the address
        Map<double, double>? coordinates =
            await GeolocatorService().getCoordinatesFromAddress(addressString);

        // Calculate distance
        double distance = GeolocatorService().calculateDistance(
          currentPosition.latitude,
          currentPosition.longitude,
          coordinates!.keys.first,
          coordinates.values.first,
        );

        // Create a MyListItem with all necessary data
        items.add(MyListItem(
          locationName: locationName,
          distance: distance, // Pass the calculated distance
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
        ));
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        // ... other AppBar properties
      ),
      body: FutureBuilder<List<MyListItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while data is being fetched
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle any errors here
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // Data is ready, build the ListView
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return snapshot.data![index];
              },
            );
          } else {
            // Handle the case where there's no data
            return Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
