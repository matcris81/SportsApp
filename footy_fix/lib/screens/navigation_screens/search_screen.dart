import 'package:flutter/material.dart';
import 'package:footy_fix/screens/location_description.dart';
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
  Position? _currentPosition;
  final GeolocatorService _geolocatorService = GeolocatorService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
  }

  void _fetchCurrentLocation() async {
    try {
      Position position = await GeolocatorService().determinePosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      // Handle the exception
      print("Error fetching location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // Adjust as needed
            child: Container(
              padding: const EdgeInsets.only(bottom: 8), // Adjust as needed
              alignment: Alignment.bottomCenter,
              child: Text(
                'Location',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        body: FutureBuilder<Object?>(
            future: DatabaseServices().retrieveMultiple('Locations'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              }
              List<String> values = [];
              if (snapshot.hasData && snapshot.data is List) {
                List rawDataList = snapshot.data as List;

                for (var item in rawDataList) {
                  if (item != null && item is String) {
                    values.add(item);
                  }
                }
              }
              List<String> games = values;
              return ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  return MyListItem(
                    locationName: games[index],
                    currentPosition: _currentPosition!,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LocationDescription(
                            locationName: games[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }));
  }
}
