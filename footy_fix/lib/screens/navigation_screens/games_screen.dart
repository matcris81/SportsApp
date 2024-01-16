import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:footy_fix/components/game_tile.dart';
import 'package:footy_fix/descriptions/game_description.dart';

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
    DateTime dateTime = DateTime.parse(day);
    String formattedDate =
        "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";

    // Authenticate and get the token
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    print('formattedDate: $formattedDate');

    // Make the API call
    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/games/by-date?date=$formattedDate',
        token);

    // Check the response status and decode the body
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
            child: FutureBuilder<List<dynamic>>(
              future: _getGamesForDay(_selectedDate.toString()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No events this day'));
                }

                var gameInfo = snapshot.data!;
                print(gameInfo);
                return ListView.builder(
                  itemCount: gameInfo.length,
                  itemBuilder: (context, index) {
                    var game = gameInfo[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: 310,
                        child: GameTile(
                          gameID: game['id'],
                          locationID: game['venueId'],
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
