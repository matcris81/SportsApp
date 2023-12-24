import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  _GamesScreenState createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  DateTime _selectedDate = DateTime.now();
  late final List<DateTime> _dates;
  late final ValueNotifier<List<String>> _selectedGames;

  @override
  void initState() {
    super.initState();
    _dates = _generateDatesList(30); // Generate dates for the next 30 days
    _selectedGames = ValueNotifier<List<String>>([]);
    _loadGamesForSelectedDay(_selectedDate);
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

  Future<void> _loadGamesForSelectedDay(DateTime day) async {}

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
                      _loadGamesForSelectedDay(date);
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
            child: ValueListenableBuilder<List<String>>(
              valueListenable: _selectedGames,
              builder: (context, games, _) {
                return ListView.builder(
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(games[index]), // Display game details
                      // Add onTap or other interactive elements
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
