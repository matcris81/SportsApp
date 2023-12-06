import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';

class UpcomingGamesList extends StatefulWidget {
  final Map<dynamic, dynamic> games;
  final String locationName;

  // Constructor to accept a list of games
  const UpcomingGamesList(
      {Key? key, required this.locationName, required this.games})
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
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: Colors.white,
        child: ListView.builder(
          itemCount: widget.games.length,
          itemBuilder: (context, index) {
            var date = widget.games.keys.elementAt(index);
            var gamesForDate = widget.games[date];
            String gameID = gamesForDate.keys.first;
            var gameDetails = gamesForDate[gameID];

            return Card(
              child: GameTile(
                location: widget.locationName,
                gameID: gameID,
                time: gameDetails['Time']?.toString() ?? '',
                size: gameDetails['Size']?.toString() ?? '',
                price: gameDetails['Price']?.toDouble() ?? 0.0,
                playersJoined: gameDetails['Players joined']?.toString() ?? '',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameDescription(
                        location: widget.locationName,
                        gameID: gameID,
                        date: date,
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
            );
          },
        ),
      ),
    );
  }
}
