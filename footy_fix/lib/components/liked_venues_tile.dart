import 'package:flutter/material.dart';

class LocationTile extends StatelessWidget {
  final String locationName;
  final int rating; // Rating parameter

  LocationTile(
      {required this.locationName, this.rating = 5}); // Default rating is 5

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Width of the card
      child: Card(
        elevation: 4,
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment
              .bottomLeft, // Align text to the bottom left of the image
          children: <Widget>[
            // Background image covering the whole card
            Ink.image(
              image: AssetImage('assets/AlbanyFootyFix.jpg'),
              fit: BoxFit.cover,
              height: 150, // Adjusted height for the image
              width: 300,
            ),
            // Text and rating overlay
            Positioned(
              left: 8.0,
              bottom: 8.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Location name
                  Text(
                    locationName,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // White text color for better visibility
                      shadows: <Shadow>[
                        Shadow(
                          offset: Offset(1.0, 1.0),
                          blurRadius: 3.0,
                          color: Color.fromARGB(
                              255, 0, 0, 0), // Text shadow for readability
                        ),
                      ],
                    ),
                  ),
                  // Star rating
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.white,
                        size: 20.0,
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
