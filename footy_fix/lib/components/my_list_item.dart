import 'package:flutter/material.dart';

class MyListItem extends StatelessWidget {
  final String locationName;
  final double distance;
  final Function()? onTap;

  MyListItem({required this.locationName, required this.distance, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(locationName),
      subtitle: Text('Distance: $distance km'),
      onTap: onTap,
    );
  }
}
