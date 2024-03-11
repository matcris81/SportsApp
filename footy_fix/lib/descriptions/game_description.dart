import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/screens/feature_manager_screens/event_adder.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:footy_fix/screens/checkout_screen.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:share_plus/share_plus.dart';

class GameDescription extends StatefulWidget {
  final int gameID;
  final String? previousScreen;

  const GameDescription({
    Key? key,
    required this.gameID,
    this.previousScreen,
  }) : super(key: key);

  @override
  _GameDescriptionState createState() => _GameDescriptionState();
}

class _GameDescriptionState extends State<GameDescription> {
  String? userID;
  double price = 0.0;
  bool isFull = false;
  int size = 0;
  int numberOfPlayers = 0;
  String time = '';
  var dayName;
  var dayNumber;
  var monthName;
  bool isLoading = true;
  String address = '';
  String? description;
  var venueName;
  List<String> imageUrls = [];
  List<dynamic> players = [];
  static const String defaultImageUrl =
      'https://example.com/default-avatar.jpg';
  String? organizer;
  bool userAlreadyJoined = false;
  String? sport;
  int? organizerImageID;
  int fakePlayers = 0;

  @override
  void initState() {
    super.initState();
    _fetchGameInfo();
  }

  Future<void> _fetchGameInfo() async {
    try {
      Map<dynamic, dynamic> gameInfo = await getGameInfo();

      sport = await getSport(gameInfo['sportId']);

      var id = await PreferencesService().getUserId();

      players = await getPlayers();
      numberOfPlayers = players.length;

      checkIfUserAlreadyJoined(players, id!);

      print('gameInfo: $gameInfo');

      setState(() {
        userID = id;
        venueName = gameInfo['venueName'];
        address = gameInfo['address'];
        description = gameInfo['description'];
        size = gameInfo['size'];
        price = gameInfo['price'];
        var date = gameInfo['gameDate'];
        organizer = gameInfo['organizer_username'];
        organizerImageID = gameInfo['organizer_image_id'];
        fakePlayers = gameInfo['fakePlayers'];

        DateTime parsedDate = DateTime.parse(date);
        time = DateFormat('HH:mm:ss').format(parsedDate);
        dayName = DateFormat('EEEE').format(parsedDate);
        dayNumber = DateFormat('d').format(parsedDate);
        monthName = DateFormat('MMMM').format(parsedDate);

        players = players;

        isFull = numberOfPlayers >= size;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching game info: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[300],
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 150.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background:
                      Image.asset('assets/football.jpg', fit: BoxFit.cover),
                ),
                leading: IconButton(
                  icon: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "${(size / 2).floor()} v ${(size / 2).floor()} $sport",
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 10),
                          organizerImageID != null
                              ? FutureBuilder<String?>(
                                  future: fetchImageData(
                                      organizerImageID.toString()),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<String?> snapshot) {
                                    if (snapshot.connectionState ==
                                            ConnectionState.done &&
                                        snapshot.hasData) {
                                      Map<String, dynamic> imageData =
                                          jsonDecode(snapshot.data!);
                                      Uint8List imageBytes =
                                          base64Decode(imageData['imageData']);

                                      return CircleAvatar(
                                        backgroundImage:
                                            MemoryImage(imageBytes),
                                        radius: 20.0,
                                      );
                                    } else {
                                      return const CircleAvatar(
                                        backgroundColor: Colors.grey,
                                        radius: 20.0,
                                      );
                                    }
                                  },
                                )
                              : const CircleAvatar(
                                  // This is the fallback if the organizerImageID is null
                                  backgroundColor: Colors.grey,
                                  radius: 20.0,
                                  child:
                                      Icon(Icons.person, color: Colors.white),
                                ),
                          SizedBox(width: 10), // Adjust spacing as needed
                          Text(
                            ' Hosted by $organizer',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'About the game',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description ?? 'No description available',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Details',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.people, // Replace with your time icon
                            size: 16, // Adjust the size as needed
                            color: Colors.black, // Adjust the color as needed
                          ),
                          const SizedBox(width: 10),
                          numberOfPlayers < fakePlayers
                              ? Text(
                                  '$fakePlayers/$size spots left',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : Text(
                                  '$numberOfPlayers/$size spots left',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.calendar_today, // Replace with your date icon
                            size: 16, // Adjust the size as needed
                            color: Colors.black, // Adjust the color as needed
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '$dayName, $dayNumber $monthName',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.access_time,
                            size: 16, // Adjust the size as needed
                            color: Colors.black, // Adjust the color as needed
                          ),
                          const SizedBox(width: 10),
                          Text(
                            time.length >= 5 ? time.substring(0, 5) : time,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16, // Adjust the size as needed
                            color: Colors.black, // Adjust the color as needed
                          ),
                          const SizedBox(width: 10),
                          Text(
                            venueName ?? 'Venue name not available',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Players',
                        style: TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: [
                              if (players.isNotEmpty)
                                _buildPlayerIconsRow()
                              else
                                const Text(
                                  'Be the firs to join',
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontStyle: FontStyle.italic),
                                ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          children: <Widget>[
                            const Icon(Icons.directions,
                                size: 30.0, color: Colors.white), // White icon
                            const SizedBox(width: 10),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  _launchMaps(context, address);
                                },
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      'Get directions',
                                      style: TextStyle(
                                        color: Colors.white, // White text
                                        fontSize: 14.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: _buildBotttomNavigationBar(),
    );
  }

  Widget _buildPlayerIconsRow() {
    int maxIconsToShow = 10;
    double overlap = 20.0;

    // Start with an empty list of icon widgets
    List<Widget> iconWidgets = [];

    // Ensure the total number of player icons (real + fake) doesn't exceed maxIconsToShow
    int realPlayersToShow = min(numberOfPlayers, maxIconsToShow);
    int fakePlayersToShow = maxIconsToShow - realPlayersToShow;

    // Add icons for real players
    for (int i = 0; i < realPlayersToShow; i++) {
      Widget iconWidget;
      if (players[i]['playerImage'] != null) {
        iconWidget = _buildPlayerIcon(players[i], i * (40.0 - overlap));
      } else {
        // If a real player doesn't have an image, use the default icon
        iconWidget = _buildDefaultPlayerIcon(i * (40.0 - overlap));
      }
      iconWidgets.add(iconWidget);
    }

    // Fill the remaining slots with fake player icons
    for (int i = 0; i < fakePlayersToShow; i++) {
      Widget iconWidget =
          _buildFakePlayerIcon((realPlayersToShow + i) * (40.0 - overlap));
      iconWidgets.add(iconWidget);
    }

    double stackWidth = iconWidgets.length * (40.0 - overlap) + overlap;

    return SizedBox(
      height: 40.0,
      width: stackWidth,
      child: Stack(
        children: iconWidgets,
      ),
    );
  }

  Widget _buildPlayerIcon(dynamic player, double leftPosition) {
    // Build the player icon with an image
    return Positioned(
      left: leftPosition,
      child: FutureBuilder<String?>(
        future: fetchImageData(player['playerImage']['id'].toString()),
        builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            Map<String, dynamic> playerImageDetails =
                jsonDecode(snapshot.data!);
            Uint8List imageBytes =
                base64Decode(playerImageDetails['imageData']);
            return CircleAvatar(
              backgroundImage: MemoryImage(imageBytes),
              radius: 20.0,
            );
          } else {
            return const CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20.0,
              child: Icon(Icons.person, color: Colors.white),
            );
          }
        },
      ),
    );
  }

  Widget _buildDefaultPlayerIcon(double leftPosition) {
    // Build a default icon for fake players or real players without an image
    return Positioned(
      left: leftPosition,
      child: const CircleAvatar(
        backgroundColor: Colors.grey, // You can customize the color
        radius: 20.0,
        child: Icon(Icons.person, color: Colors.white),
      ),
    );
  }

// Method to build a fake player icon widget
  Widget _buildFakePlayerIcon(double leftPosition) {
    return Positioned(
      left: leftPosition,
      child: CircleAvatar(
        backgroundColor: Colors.blueGrey, // Differentiate fake players
        radius: 20.0,
        child: Icon(Icons.person_outline, color: Colors.white),
      ),
    );
  }

  Future<String?> fetchImageData(String playerImageId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    try {
      var response = await DatabaseServices().getData(
          '${DatabaseServices().backendUrl}/api/player-images/$playerImageId',
          token);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Failed to load image data');
        return null;
      }
    } catch (exception) {
      print('Exception fetching image data: $exception');
      return null;
    }
  }

  Widget _buildBotttomNavigationBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              // Define the action to take when the button is pressed
            },
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            heroTag: 'messageFAB', // Unique tag for this FAB
            child: const Icon(Icons.message, color: Colors.black),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () async {
              await Share.share(
                  'Check out this game on FootyFix: https://kaido.tk/game/${widget.gameID}');
            },
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
              side: const BorderSide(color: Colors.white, width: 2),
            ),
            heroTag: 'shareFAB', // Unique tag for this FAB
            child: const Icon(Icons.ios_share, color: Colors.black),
          ),
          const SizedBox(width: 10),
          Container(
            width: 200, // Set a specific width for the button
            child: ElevatedButton(
              onPressed: isLoading || isFull || userAlreadyJoined
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CheckoutScreen(
                            gameID: widget.gameID,
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLoading || isFull ? Colors.grey : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                userAlreadyJoined
                    ? 'Joined'
                    : (isLoading
                        ? 'Loading...'
                        : (isFull
                            ? 'Join (Full)'
                            : 'Join for \$${price.toStringAsFixed(2)}')),
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getSport(int sportId) async {
    String? sport;

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/sports/$sportId', token);

    Map<String, dynamic> sports = jsonDecode(response.body);

    sport = sports['sportName'];

    return sport;
  }

  void checkIfUserAlreadyJoined(List<dynamic> players, String userID) {
    for (int i = 0; i < players.length; i++) {
      if (players[i]['id'] == userID) {
        setState(() {
          userAlreadyJoined = true;
        });
      }
    }
    print('userAlreadyJoined: $userAlreadyJoined');
  }

  Future<List<dynamic>> getPlayers() async {
    List<dynamic> players = [];

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}/get-players',
        token);

    players = jsonDecode(result.body);

    return players;
  }

  Future<Map<String, dynamic>> getOrganizerInfo(String organizerID) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/players/$organizerID', token);

    print('organizerID: ${result.body}');

    return jsonDecode(result.body);
  }

  Future<Map<dynamic, dynamic>> getGameInfo() async {
    Map gameInfo = {};

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}', token);

    Map<String, dynamic> gameDetails = jsonDecode(result.body);

    Map<String, dynamic> venueInfo = await getVenueInfo(gameDetails['venueId']);

    Map<String, dynamic> organizerInfo =
        await getOrganizerInfo(gameDetails['organizer']['id']);

    gameInfo.addAll(venueInfo);
    // gameDetails has to be second because it retrieves the players joined for the game (venue would return the players that have liked the venue)
    gameInfo.addAll(gameDetails);
    gameInfo['organizer_username'] = organizerInfo['username'];
    gameInfo['organizer_image_id'] = organizerInfo['playerImage'] != null
        ? organizerInfo['playerImage']['id']
        : null;

    return gameInfo;
  }

  Future<Map<String, dynamic>> getVenueInfo(int venueID) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/venues/$venueID', token);

    Map<String, dynamic> venueInfo = jsonDecode(result.body);

    return venueInfo;
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
      // Directly launch Google Maps for Android devices
      await _launchURL(
          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(location)}');
    } else if (Platform.isIOS) {
      // Show the Cupertino action sheet for iOS devices
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
