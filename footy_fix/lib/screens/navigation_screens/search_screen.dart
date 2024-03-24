import 'package:flutter/material.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/components/venues_tile.dart';
import 'package:footy_fix/services/database_services.dart';
import 'dart:convert';

import 'package:go_router/go_router.dart';

class SearchScreen extends StatefulWidget {
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
      // String token =
      //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

      var result = await DatabaseServices()
          .getData('${DatabaseServices().backendUrl}/api/venues');

      List<dynamic> venueList = json.decode(result.body);

      for (var venue in venueList) {
        int id = venue['id'];
        String venueName = venue['venueName'];
        String address = venue['address'];
        int? imageId = venue['imageId'];

        imageId ??= -1;

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
        }

        Map<String, dynamic> details = {
          'name': venueName,
          'distance': distance,
          'imageId': imageId,
        };

        venues[id.toString()] = details;
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
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
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
                    int imageId = snapshot.data![id]!['imageId'];

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      child: LocationTile(
                        locationName: venueName,
                        distance: distance,
                        opacity: 0.4,
                        imageId: imageId,
                        onTap: () {
                          context.go('/venue/$id/false');
                        },
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
