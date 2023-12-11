import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/location_description.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/components/my_list_item.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';

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
    List<MyListItem> items = [];
    List<String> locationNamesList = [];

    // Check if location data is stored in shared preferences
    items = await PreferencesService().loadLocationDataList(context);
    // Object? locationNames = await DatabaseServices().retrieveLocal('Locations');

    if (items.isEmpty) {
      // else fetch location names from the database
      Object? locationNames =
          await DatabaseServices().retrieveMultiple('Locations');
        
      print(locationNames);

      // Check if locationNames is a list
      if (locationNames is List) {
        locationNamesList =
            locationNames.map((item) => item.toString()).toList();
      } else {
        print('locationNames is not a list');
      }

      for (String locationName in locationNamesList) {
        // Fetch address from the database
        var address = await DatabaseServices()
            .retrieveLocal('Location Details/$locationName/Address');
        String addressString = address.toString();

        Map<double, double>? coordinates =
            await GeolocatorService().getCoordinatesFromAddress(addressString);

            print(coordinates);
        double distance = 0;
        if(coordinates != null) {
           distance = GeolocatorService().calculateDistance(
            currentPosition.latitude,
            currentPosition.longitude,
            coordinates!.keys.first,
            coordinates.values.first,
          );
        }
        print(coordinates);


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
      await PreferencesService().saveLocationDataList(items);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // This line removes the back button
        title: const Text("Search"),
      ),
      body: FutureBuilder<List<MyListItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show loading indicator while data is being fetched
            return const Center(child: CircularProgressIndicator());
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
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }
}
