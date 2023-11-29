import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/geolocator_services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:footy_fix/location_item.dart';

class MyListItem extends StatelessWidget {
  // final LocationItem item;
  final String locationName;
  final Position currentPosition;
  final Function()? onTap;

  // MyListItem({required this.item, required this.currentPosition});
  MyListItem(
      {required this.locationName,
      required this.currentPosition,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Object?>(
      future: DatabaseServices()
          .retrieveFromDatabase('Location Details/$locationName/Address'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        var address = snapshot.data;
        String addressString = address.toString();
        return FutureBuilder<Map<double, double>?>(
          future: GeolocatorService().getCoordinatesFromAddress(addressString),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return ListTile(
              title: Text(locationName), // Replace with actual title
              subtitle: Text(
                  'Distance: ${GeolocatorService().calculateDistance(currentPosition.latitude, currentPosition.longitude, snapshot.data!.keys.first, snapshot.data!.values.first)} km'),
              onTap: onTap,
            );
          },
        );
      },
    );
  }
}
