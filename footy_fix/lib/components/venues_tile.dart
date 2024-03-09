import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:footy_fix/services/database_services.dart';

class LocationTile extends StatelessWidget {
  final String locationName;
  final double distance;
  final Function()? onTap;
  final int rating;
  final double opacity;
  final bool showDistance;
  final bool showRating;
  final int imageId;

  LocationTile({
    required this.locationName,
    this.rating = 5,
    this.distance = 0,
    required this.onTap,
    this.showDistance = true,
    this.showRating = true,
    required this.opacity,
    required this.imageId,
  });

  @override
  Widget build(BuildContext context) {
    // String imagePath = 'assets/$locationName.jpg';
    // String fallbackImagePath = 'assets/standInVenueImage.jpg';

    // Future<bool> _checkImageExists(String path) async {
    //   try {
    //     await rootBundle.load(path);
    //     return true;
    //   } catch (_) {
    //     return false;
    //   }
    // }

    Future<Uint8List> fetchVenueImageData(int imageId) async {
      if (imageId == -1) {
        ByteData bytes = await rootBundle.load('assets/standInVenueImage.jpg');
        return bytes.buffer.asUint8List();
      } else {
        var token =
            await DatabaseServices().authenticateAndGetToken('admin', 'admin');
        var imageResponse = await DatabaseServices().getData(
          '${DatabaseServices().backendUrl}/api/images/$imageId',
          token,
        );
        var imageData = jsonDecode(imageResponse.body);
        if (imageData['imageData'] != null) {
          String base64String = imageData['imageData'];
          Uint8List imageBytes = base64Decode(base64String);
          return imageBytes;
        } else {
          ByteData bytes =
              await rootBundle.load('assets/standInVenueImage.jpg');
          return bytes.buffer.asUint8List();
        }
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
              FutureBuilder<Uint8List>(
                future: fetchVenueImageData(imageId),
                builder:
                    (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                  return Stack(
                    children: <Widget>[
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData)
                        Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        )
                      else
                        Image.asset(
                          'assets/standInVenueImage.jpg',
                          fit: BoxFit.cover,
                          height: 200,
                          width: double.infinity,
                        ),
                      // Semi-transparent overlay
                      Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(
                              opacity), // Adjust the opacity as needed
                        ),
                      ),
                    ],
                  );
                },
              ),
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
                      maxLines: 1,
                    ),
                    if (showDistance)
                      Text(
                        '${distance.toStringAsFixed(1)} km away',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.white70,
                        ),
                      ),
                    // if (showRating) // Conditionally display rating
                    //   Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: List.generate(5, (index) {
                    //       return Icon(
                    //         index < rating ? Icons.star : Icons.star_border,
                    //         color: Colors.white,
                    //         size: 20.0,
                    //       );
                    //     }),
                    //   ),
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
