import 'package:flutter/material.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';

class UpcomingGamesList extends StatefulWidget {
  final Map<dynamic, dynamic> games;
  final String locationName;

  // Constructor to accept a list of games
  const UpcomingGamesList(
      {Key? key, this.locationName = '', required this.games})
      : super(key: key);

  @override
  _UpcomingGamesListState createState() => _UpcomingGamesListState();
}

class _UpcomingGamesListState extends State<UpcomingGamesList> {
  List<dynamic> sortedDates = [];

  @override
  void initState() {
    super.initState();
    sortedDates = widget.games.keys.toList()..sort((a, b) => a.compareTo(b));
  }

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
          itemCount: sortedDates.length,
          itemBuilder: (context, index) {
            var date = sortedDates[index];
            var gamesForDate = widget.games[date];
            print('gamesForDate: $gamesForDate');
            // Check if gamesForDate is a Map, if not, return an alternative widget or skip
            if (gamesForDate is! Map || gamesForDate.isEmpty) {
              return const SizedBox
                  .shrink(); // or return a widget that indicates no game details are available
            }

            String gameID = gamesForDate.keys.first;
            // print(gameID);
            var gameDetails = gamesForDate[gameID];

            return Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0), // Add horizontal padding
                child: Card(
                  child: GameTile(
                    location: widget.locationName,
                    date: date,
                    gameID: gameID,
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
                ));
          },
        ),
      ),
    );
  }
}
