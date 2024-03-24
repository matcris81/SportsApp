import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:go_router/go_router.dart';

class UpcomingGamesList extends StatefulWidget {
  final int venueID;

  const UpcomingGamesList({Key? key, required this.venueID}) : super(key: key);

  @override
  _UpcomingGamesListState createState() => _UpcomingGamesListState();
}

class _UpcomingGamesListState extends State<UpcomingGamesList> {
  Future<String> fetchVenueName() async {
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var venueNameResponse = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/venues/${widget.venueID}');

    print('venue reponse: ${venueNameResponse.body}');

    var venueName = jsonDecode(venueNameResponse.body)['venueName'];
    return venueName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: fetchVenueName(),
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Text(
                'Loading...',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                textAlign: TextAlign.center,
              );
            } else if (snapshot.hasError) {
              return const Text(
                'Error loading name',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                textAlign: TextAlign.center,
              );
            } else {
              return Text(
                '${snapshot.data} Upcoming Games',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Colors.black),
                textAlign: TextAlign.center,
              );
            }
          },
        ),
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => context.pop(),
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 4.0), // Increased vertical padding
                child: Container(
                  margin: const EdgeInsets.only(
                      bottom: 16.0), // Added bottom margin for more spacing
                  height: 310,
                  child: GameTile(
                    gameID: gameDetails['id'],
                    locationID: gameDetails['venueId'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchGamesByVenue(int venueID) async {
    List<Map<String, dynamic>> gamesList = [];

    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/by-venue/$venueID');

    var games = jsonDecode(response.body);

    gamesList = List<Map<String, dynamic>>.from(games);

    return gamesList;
  }
}
