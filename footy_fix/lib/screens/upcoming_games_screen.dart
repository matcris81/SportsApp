import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';

class UpcomingGamesList extends StatefulWidget {
  final Map<dynamic, dynamic> games;
  final String locationName;

  const UpcomingGamesList(
      {Key? key, this.locationName = '', required this.games})
      : super(key: key);

  @override
  _UpcomingGamesListState createState() => _UpcomingGamesListState();
}

class _UpcomingGamesListState extends State<UpcomingGamesList> {
  @override
  Widget build(BuildContext context) {
    var gameIDs = widget.games.keys.toList(); // Get all game IDs

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
      body: Container(
        color: Colors.grey[300],
        child: ListView.builder(
          itemCount: gameIDs.length,
          itemBuilder: (context, index) {
            var gameID = gameIDs[index];
            var gameDetails = widget.games[gameID];
            if (gameDetails is! Map) {
              return const SizedBox.shrink();
            }

            return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  height: 310,
                  child: GameTile(
                    location: widget.locationName,
                    date: gameDetails['Date']?.toString() ?? '',
                    gameID: gameID.toString(),
                    time: gameDetails['Time']?.toString() ?? '',
                    size: gameDetails['Size']?.toString() ?? '',
                    price: gameDetails['Price']?.toDouble() ?? 0.0,
                    playersJoined:
                        gameDetails['Players joined']?.toString() ?? '',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameDescription(
                            location: widget.locationName,
                            gameID: gameID.toString(),
                            date: gameDetails['Date']?.toString() ?? '',
                            time: gameDetails['Time']?.toString() ?? '',
                            size: gameDetails['Size']?.toString() ?? '',
                            price: (gameDetails['Price'] is num)
                                ? gameDetails['Price'].toDouble()
                                : 0.0,
                            playersJoined:
                                gameDetails['Players joined']?.toString() ?? '',
                          ),
                        ),
                      );
                    },
                  ),
                ));
          },
        ),
      ),
    );
  }
}
