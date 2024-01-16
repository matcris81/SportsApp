import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/db_services.dart';

class UpcomingGamesList extends StatefulWidget {
  final int venueID;
  final String locationName;

  const UpcomingGamesList(
      {Key? key, required this.venueID, this.locationName = ''})
      : super(key: key);

  @override
  _UpcomingGamesListState createState() => _UpcomingGamesListState();
}

class _UpcomingGamesListState extends State<UpcomingGamesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.locationName} Upcoming Games',
          style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white, // Background color of the circle
            child:
                Icon(Icons.arrow_back, color: Colors.black), // Black arrow icon
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchGamesByVenue(widget.venueID),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No upcoming games'));
          }

          List<Map<String, dynamic>> games = snapshot.data!;

          return ListView.builder(
            itemCount: games.length,
            itemBuilder: (context, index) {
              var gameDetails = games[index];
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Container(
                    height: 310,
                    child: GameTile(
                      gameID: gameDetails['id'],
                      locationID: gameDetails['venueId'],
                    ),
                  ));
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchGamesByVenue(int venueID) async {
    List<Map<String, dynamic>> gamesList = [];

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/by-venue/$venueID', token);

    var games = jsonDecode(response.body);

    gamesList = List<Map<String, dynamic>>.from(games);

    return gamesList;
  }
}
