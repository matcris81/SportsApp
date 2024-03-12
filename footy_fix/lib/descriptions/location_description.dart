import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/screens/feature_manager_screens/event_adder.dart';
import 'package:footy_fix/screens/upcoming_games_screen.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/notifications_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io' show Platform;
import 'dart:convert';

class LocationDescription extends StatefulWidget {
  final int locationID;
  final bool? justCreated;

  const LocationDescription(
      {Key? key, required this.locationID, this.justCreated})
      : super(key: key);

  @override
  _LocationDescriptionState createState() => _LocationDescriptionState();
}

class _LocationDescriptionState extends State<LocationDescription> {
  bool isHeartFilled = false;
  String? locationName;
  bool organizer = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    getNextUpcomingGame();
    getVenueData();
  }

  Future<void> getVenueData() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/venues/${widget.locationID}',
        token);

    var locationDetails = json.decode(response.body);
    String? creatorId = locationDetails['creatorId'];
    print('creatorId: $creatorId');

    String userID = await PreferencesService().getUserId() ?? '';

    setState(() {
      locationName = locationDetails['venueName'];

      if (creatorId == userID) {
        setState(() {
          organizer = true;
        });
      }
    });
  }

  void checkIfLiked() async {
    String userID = await PreferencesService().getUserId() ?? '';
    bool liked = false;

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$userID/likes-venue/${widget.locationID}',
        token);

    if (response.body == "true") {
      liked = true;
    }

    setState(() {
      isHeartFilled = liked;
    });
  }

  void toggleLike() async {
    setState(() {
      isHeartFilled = !isHeartFilled;
    });

    bool revertChange = false;

    try {
      String userID = await PreferencesService().getUserId() ?? '';
      var token =
          await DatabaseServices().authenticateAndGetToken('admin', 'admin');
      var body = {
        "id": userID,
        "venues": [
          {"id": widget.locationID}
        ]
      };

      if (isHeartFilled) {
        await DatabaseServices().patchData(
            '${DatabaseServices().backendUrl}/api/players/$userID',
            token,
            body);
        await FirebaseAPI().subscribeToTopic('Venue${widget.locationID}');
      } else {
        await DatabaseServices().patchData(
            '${DatabaseServices().backendUrl}/api/players/remove/$userID',
            token,
            body);
        await FirebaseAPI().unsubscribeFromTopic('Venue${widget.locationID}');
      }
    } catch (error) {
      revertChange = true;
    }

    if (revertChange) {
      setState(() {
        isHeartFilled = !isHeartFilled;
        // Show an error message if needed
      });
    }
  }

  Future<Map<String, dynamic>> getNextUpcomingGame() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/earliest-by-venue?venueId=${widget.locationID}',
        token);

    if (response.statusCode == 404) {
      // throw Exception('No games');
      return {};
    }

    Map<String, dynamic> earliestGame = json.decode(response.body);

    // Check if the games list is empty
    if (earliestGame.isEmpty) {
      return {};
    }

    return earliestGame;
  }

  Future<Map<String, dynamic>> getLocationDetails() async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/venues/${widget.locationID}',
        token);

    var locationDetails = json.decode(result.body);

    return locationDetails;
  }

  Widget currentImage = Image.asset(
    'assets/albany.png',
    fit: BoxFit.fitWidth,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        body: FutureBuilder<Map<String, dynamic>>(
            future: getLocationDetails(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              var venueRow = snapshot.data!;
              var venueAddress = venueRow['address'];
              var venueDescription = venueRow['description'];
              print('venueRow: $venueRow');
              var imageId = venueRow['imageId'];
              imageId ??= -1;
              print('organizer: $organizer');

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: 200.0,
                    floating: false,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (organizer) _pickImage();
                            },
                            child: Container(
                              width: double.infinity,
                              child: FutureBuilder<Uint8List>(
                                future: fetchVenueImage(imageId),
                                builder: (BuildContext context,
                                    AsyncSnapshot<Uint8List> snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Image.asset('assets/albany.png',
                                        fit: BoxFit.fitWidth);
                                  } else if (snapshot.hasData) {
                                    return Image.memory(snapshot.data!,
                                        fit: BoxFit.fitWidth);
                                  } else {
                                    return Image.asset('assets/albany.png',
                                        fit: BoxFit.fitWidth);
                                  }
                                },
                              ),
                            ),
                          ),
                          if (organizer)
                            const Positioned(
                              bottom: 20,
                              right: 20,
                              child: Icon(Icons.edit, color: Colors.white),
                            ),
                        ],
                      ),
                    ),
                    leading: IconButton(
                        icon: const CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(Icons.arrow_back, color: Colors.black),
                        ),
                        onPressed: () {
                          if (widget.justCreated != null &&
                              widget.justCreated!) {
                            context.go('/');
                          } else {
                            context.pop();
                          }
                        }),
                    actions: <Widget>[
                      IconButton(
                        icon: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Icon(
                            isHeartFilled
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: isHeartFilled ? Colors.red : Colors.black,
                          ),
                        ),
                        onPressed: () {
                          toggleLike();
                        },
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  locationName ?? 'Loading location name...',
                                  style: const TextStyle(
                                    fontSize: 24.0,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  Share.share(
                                      'Check out this venue: $locationName at https://kaido.tk/venue/${widget.locationID}');
                                },
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _launchMaps(context, venueAddress);
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.grey,
                                  size: 25.0,
                                ),
                                const SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    venueAddress,
                                    style: const TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.normal,
                                      fontFamily: 'Roboto',
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        const Padding(
                          padding: EdgeInsets.only(
                              left: 30.0, top: 20.0, right: 4.0, bottom: 4.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Next Game',
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                          future: getNextUpcomingGame(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (!snapshot.hasData || snapshot.data!.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(20),
                                margin: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      spreadRadius: 5,
                                      blurRadius: 7,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  "No upcoming games",
                                  style: TextStyle(fontSize: 18),
                                ),
                              );
                            }

                            var gameRow = snapshot.data!;

                            // Extract the game details from gameRow
                            var gameId = gameRow['id'];

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Container(
                                height: 310,
                                child: GameTile(
                                  gameID: gameId,
                                  locationID: widget.locationID,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: organizer
                              ? Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.go(
                                              '/venue/${widget.locationID}/${widget.justCreated}/upcomingGames');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text(
                                          'See Upcoming Games',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          context.push(
                                              '/addEvent/true/${widget.locationID}');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          side: const BorderSide(
                                              color: Colors.black),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        child: const Text('Add Game'),
                                      ),
                                    ),
                                  ],
                                )
                              : ElevatedButton(
                                  onPressed: () {
                                    context.go(
                                        '/venue/${widget.locationID}/${widget.justCreated}/upcomingGames');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    minimumSize:
                                        const Size(double.infinity, 40),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 13.0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'See Upcoming Games',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                        ),
                        const SizedBox(height: 20.0),
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Text(
                            "About the venue",
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, bottom: 50.0),
                          child: Text(
                            venueDescription,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }

  Future<Uint8List> fetchVenueImage(int imageId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var imageResponse = await DatabaseServices().getData(
      '${DatabaseServices().backendUrl}/api/images/$imageId',
      token,
    );

    var imageUrl = json.decode(imageResponse.body)['imageData'];

    Uint8List image = base64Decode(imageUrl);

    return image;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();

      String base64Image = base64Encode(imageBytes);

      Map<String, dynamic> imageData = {
        'imageData': base64Image,
      };

      String token =
          await DatabaseServices().authenticateAndGetToken('admin', 'admin');

      try {
        var response = await DatabaseServices().postData(
          '${DatabaseServices().backendUrl}/api/images',
          token,
          imageData,
        );

        var imageResponse = json.decode(response.body);

        var imageID = imageResponse['imageId'];

        var response2 = await DatabaseServices().patchData(
            '${DatabaseServices().backendUrl}/api/venues/${widget.locationID}',
            token, {
          'id': widget.locationID,
          'imageId': imageID,
        });

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Image uploaded successfully: ${response.body}');
        } else {
          print('Failed to upload image: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
  }

  void _showActionSheet(BuildContext context, String location) {
    final String encodedLocation = Uri.encodeComponent(location);
    final String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$encodedLocation";
    final String appleMapsUrl = "https://maps.apple.com/?q=$encodedLocation";

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text('Open in Maps'),
          message: const Text('Select the maps app to use:'),
          actions: <CupertinoActionSheetAction>[
            CupertinoActionSheetAction(
              child: const Text('Apple Maps'),
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunch(appleMapsUrl)) {
                  await launch(appleMapsUrl);
                } else {
                  // Handle the error or inform the user they can't open the map
                }
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Google Maps'),
              onPressed: () async {
                Navigator.pop(context);
                if (await canLaunch(googleMapsUrl)) {
                  await launch(googleMapsUrl);
                } else {
                  // Handle the error or inform the user they can't open the map
                }
              },
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  Future<void> _launchMaps(BuildContext context, String location) async {
    if (Platform.isAndroid) {
      await _launchURL(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    } else if (Platform.isIOS) {
      _showActionSheet(context, location);
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // Handle the error or inform the user they can't open the URL
    }
  }
}
