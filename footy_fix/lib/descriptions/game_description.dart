import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/components/expandable_text.dart';
import 'package:footy_fix/components/player_avatar.dart';
import 'package:footy_fix/screens/game_players_screen.dart';
import 'package:intl/intl.dart';
import 'package:line_icons/line_icons.dart';
import 'dart:io' show Platform;
import 'package:url_launcher/url_launcher.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/services/database_services.dart';

class GameDescription extends StatefulWidget {
  final int locationID;
  final int gameID;
  final int sportID;
  final bool userAlreadyJoined;

  const GameDescription({
    Key? key,
    required this.locationID,
    required this.gameID,
    this.sportID = 0,
    this.userAlreadyJoined = false,
  }) : super(key: key);

  @override
  _GameDescriptionState createState() => _GameDescriptionState();
}

class _GameDescriptionState extends State<GameDescription> {
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
  var description;
  var venueName;
  List<String> imageUrls = [];
  List<dynamic> players = [];
  static const String defaultImageUrl =
      'https://example.com/default-avatar.jpg';

  @override
  void initState() {
    super.initState();
    _fetchGameInfo();
  }

  Future<void> _fetchGameInfo() async {
    try {
      Map<dynamic, dynamic> gameInfo = await getGameInfo();

      setState(() {
        venueName = gameInfo['venueName'];
        address = gameInfo['address'];
        description = gameInfo['description'];
        size = gameInfo['size'];
        numberOfPlayers = gameInfo['players'].length;
        price = gameInfo['price'];
        var date = gameInfo['gameDate'];

        DateTime parsedDate = DateTime.parse(date);
        time = DateFormat('HH:mm:ss').format(parsedDate);
        dayName = DateFormat('EEEE').format(parsedDate);
        dayNumber = DateFormat('d').format(parsedDate);
        monthName = DateFormat('MMMM').format(parsedDate);

        players = gameInfo['players'];

        isFull = numberOfPlayers >= size;
        isLoading = false;
      });
    } catch (error) {
      print('Error fetching game info: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 150.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Image.asset(
                      'assets/football.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                  leading: IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.arrow_back, color: Colors.black),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                SliverToBoxAdapter(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : isFull
                          ? const SizedBox.shrink()
                          : Column(
                              children: [
                                Card(
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 8.0, 16.0, 8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "8v8 Football",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: <Widget>[
                                            Text(
                                              '$dayName, $dayNumber $monthName',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              height: 16,
                                              width: 1,
                                              color: Colors.grey,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                            ),
                                            Text(
                                              time.substring(0, 5),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            _buildButton(Icons.directions,
                                                "Get Directions", () {
                                              _launchMaps(context, address);
                                            }),
                                            _buildButton(
                                                Icons.ios_share, "Share", () {
                                              print("share button pressed");
                                            }),
                                            _buildButton(
                                                Icons.help_outline, "Anything",
                                                () {
                                              print("anything button pressed");
                                            }),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 0.0, horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        _buildInfoSection(
                                          "${size - numberOfPlayers}",
                                          title: "Spots Left",
                                        ),
                                        _buildInfoSection("2 hrs",
                                            icon: Icons.timer_sharp),
                                        _buildInfoSection("Football",
                                            icon:
                                                Icons.sports_baseball_outlined),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 2.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "About the Game",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                ConstrainedBox(
                                  constraints: BoxConstraints(
                                      minWidth:
                                          MediaQuery.of(context).size.width),
                                  child: SingleChildScrollView(
                                    child: Card(
                                      margin: const EdgeInsets.fromLTRB(
                                          16.0, 0.0, 16.0, 0.0),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ExpandableText(
                                              text: description,
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black),
                                              maxLines: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 2.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Game Organizer",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                Card(
                                  margin: const EdgeInsets.fromLTRB(
                                      16.0, 2.0, 16.0, 8.0),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16.0, 8.0, 16.0, 8.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        const Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  'https://www.google.com/url?sa=i&url=https%3A%2F%2Fpixabay.com%2Fvectors%2Fblank-profile-picture-mystery-man-973460%2F&psig=AOvVaw3JI2500CJ2fKtI1CqCvyNB&ust=1705723691821000&source=images&cd=vfe&ved=0CBMQjRxqFwoTCNDm_ojK6IMDFQAAAAAdAAAAABAE'),
                                              radius: 20.0,
                                            ),
                                            SizedBox(width: 10.0),
                                            Text(
                                              'Dick',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Add your message button action here
                                          },
                                          child: const Column(
                                            children: <Widget>[
                                              Icon(Icons.message_outlined,
                                                  color: Colors.grey),
                                              Text(
                                                "Contact",
                                                style: TextStyle(
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 2.0),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "Players",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => GamePlayers(
                                                players: players,
                                              )),
                                    );
                                  },
                                  child: Card(
                                    margin: const EdgeInsets.fromLTRB(
                                        16.0, 2.0, 16.0, 8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          16.0, 8.0, 16.0, 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              _buildPlayerIconsRow(),
                                            ],
                                          ),
                                          const Icon(Icons.navigate_next_sharp,
                                              color: Colors.grey),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 30.0),
            child: ElevatedButton(
              onPressed: isLoading || isFull || widget.userAlreadyJoined
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                                  gameID: widget.gameID,
                                )),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isLoading || isFull ? Colors.grey : Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: const BorderSide(color: Colors.white, width: 2),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                widget.userAlreadyJoined
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

  Widget _buildInfoSection(String value, {String? title, IconData? icon}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) Icon(icon, size: 24.0),
        SizedBox(height: icon != null ? 4 : 0),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        if (title != null) const SizedBox(height: 2),
        if (title != null)
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
      ],
    );
  }

  Widget _buildPlayerIconsRow() {
    int maxIcons = 5;
    int playerCount = players.length > maxIcons ? maxIcons : players.length;

    return Row(
      children: List.generate(playerCount, (index) {
        return const Padding(
          padding: EdgeInsets.only(right: 8.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(defaultImageUrl),
            radius: 20.0,
          ),
        );
      }),
    );
  }

  Widget _buildButton(IconData icon, String label, VoidCallback onPressed,
      {double iconSize = 24.0,
      double fontSize = 14.0,
      EdgeInsets padding = const EdgeInsets.symmetric(vertical: 10)}) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Fit content in the column
        children: <Widget>[
          Icon(icon,
              color: Colors.blue, size: iconSize), // Icon with increased size
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize, // Increased font size
              color: Colors.blue, // Text color set to blue
              fontWeight: FontWeight.bold, // Make text bold
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<dynamic, dynamic>> getGameInfo() async {
    Map gameInfo = {};

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var result = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/${widget.gameID}', token);

    Map<String, dynamic> gameDetails = jsonDecode(result.body);

    Map<String, dynamic> venueInfo = await getVenueInfo(gameDetails['venueId']);

    gameInfo.addAll(venueInfo);
    // gameDetails has to be second because it retrieves the players joined for the game (venue would return the players that have liked the venue)
    gameInfo.addAll(gameDetails);

    print(gameInfo);

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
