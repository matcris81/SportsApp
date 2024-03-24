import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/components/game_tile.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  DateTime _selectedDate = DateTime.now();
  late final List<DateTime> _dates;
  late final ValueNotifier<List<int>> _selectedGames;

  @override
  void initState() {
    super.initState();
    _dates = _generateDatesList(30);
    _selectedGames = ValueNotifier<List<int>>([]);
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

  Future<List<dynamic>> _getGamesForDay(String day) async {
    // Parse the day string to DateTime and format it as yyyy-MM-dd
    DateTime selectedDate = DateTime.parse(day);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    // Check if the selectedDate is today
    bool isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    String endpoint;

    if (isToday) {
      // If it's today, use the endpoint that considers the current time
      endpoint = "/api/games/by-date-time-asc?date=$formattedDate";
    } else {
      // For any other day, just use the date
      endpoint = "/api/games/by-date?date=$formattedDate";
    }

    print('Fetching games from: $endpoint');

    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}$endpoint');

    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to load games. Status Code: ${response.statusCode}');
    }
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
            height: 60,
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
            child: FutureBuilder<List<dynamic>>(
              future: _getGamesForDay(_selectedDate.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.data == null ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events this day'));
                }

                var gameInfo = snapshot.data!;
                return ListView.builder(
                  itemCount: gameInfo.length,
                  itemBuilder: (context, index) {
                    var gameDetails = gameInfo[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0), // Increased vertical padding
                      child: Container(
                        margin: const EdgeInsets.only(
                            bottom:
                                16.0), // Added bottom margin for more spacing
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
          ),
        ],
      ),
    );
  }
}
