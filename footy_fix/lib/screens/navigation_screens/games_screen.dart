import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/components/game_tile.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  DateTime _selectedDate = DateTime.now();
  // DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late final List<DateTime> _dates;
  late final ValueNotifier<List<int>> _selectedGames;

  @override
  void initState() {
    super.initState();
    _dates = _generateDatesList(30); // Generate dates for the next 30 days
    _selectedGames = ValueNotifier<List<int>>([]);
    // _loadGamesForSelectedDay(_selectedDate);
  }

  @override
  void dispose() {
    _selectedGames.dispose();
    super.dispose();
  }

  List<DateTime> _generateDatesList(int daysCount) {
    return List.generate(
        daysCount, (index) => DateTime.now().add(Duration(days: index)));
  }

  Future<Map<int, int>> _getGamesForDay(String day) async {
    var result = await PostgresService().retrieve(
        "SELECT game_id, venue_id FROM games WHERE game_date = '$day'");

    Map<int, int> games = {
      for (var row in result) row[0] as int: row[1] as int
    };
    return games;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          SizedBox(
            height: 60, // Set a fixed height for the date list
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _dates.length,
              itemBuilder: (context, index) {
                DateTime date = _dates[index];
                bool isSelected = _selectedDate == date;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('d').format(date), // Day number
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          DateFormat('E').format(date), // Day name
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<int, int>>(
              future: _getGamesForDay(_selectedDate.toString()),
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

                var gameInfo = snapshot.data!;
                return ListView.builder(
                  itemCount: gameInfo.length,
                  itemBuilder: (context, index) {
                    var entry = gameInfo.entries.elementAt(index);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: 310,
                        child: GameTile(
                          gameID: entry.key,
                          locationID: entry.value,
                          onTap: () {
                            // Handle tap event, e.g., navigate to a game detail screen
                            // You might want to pass the game ID to the detail screen
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
