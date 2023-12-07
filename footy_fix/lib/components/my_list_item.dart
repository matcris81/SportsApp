import 'package:flutter/material.dart';

class MyListItem extends StatelessWidget {
  final String locationName;
  final double distance;
  final Function()? onTap;

  MyListItem({required this.locationName, required this.distance, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Color of the line
            width: 1.0, // Thickness of the line
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          locationName,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Distance: $distance km'),
        onTap: onTap,
      ),
    );
  }
}
