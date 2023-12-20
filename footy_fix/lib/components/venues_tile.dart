import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LocationTile extends StatelessWidget {
  final String locationName;
  final double distance;
  final Function()? onTap;
  final int rating;

  LocationTile({
    required this.locationName,
    this.rating = 5,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String imagePath = 'assets/$locationName.jpg';
    String fallbackImagePath = 'assets/standInVenueImage.jpg';

    Future<bool> _checkImageExists(String path) async {
      try {
        await rootBundle.load(path);
        return true; // Image exists
      } catch (_) {
        return false; // Image does not exist
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0.0),
      width: 300,
      height: 150,
      child: InkWell(
        onTap: onTap,
        child: Card(
          elevation: 4,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.bottomLeft,
            children: <Widget>[
              FutureBuilder<bool>(
                future: _checkImageExists(imagePath),
                builder: (context, snapshot) {
                  if (snapshot.data ?? false) {
                    return Stack(
                      children: <Widget>[
                        Image.asset(
                          snapshot.data ?? false
                              ? imagePath
                              : fallbackImagePath,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                        Container(
                          color: Colors.black
                              .withOpacity(0.3), // Adjust opacity as needed
                          height: 200,
                          width: double.infinity,
                        ),
                      ],
                    );
                  } else {
                    return Stack(
                      children: <Widget>[
                        Image.asset(
                          snapshot.data ?? false
                              ? imagePath
                              : fallbackImagePath,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                        Container(
                          color: Colors.black
                              .withOpacity(0.3), // Adjust opacity as needed
                          height: 200,
                          width: double.infinity,
                        ),
                      ],
                    );
                  }
                },
              ),
              // Text and rating overlay
              Positioned(
                left: 8.0,
                bottom: 8.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      locationName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${distance.toStringAsFixed(1)} km away', // Assuming distance is in kilometers
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.white70,
                      ),
                    ),
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
      ),
    );
  }
}
