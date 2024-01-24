import 'package:flutter/material.dart';

class GamePlayers extends StatelessWidget {
  final List<dynamic> players;

  GamePlayers({Key? key, required this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Game Players',
          style: TextStyle(
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
      body: ListView.builder(
        itemCount: players.length,
        itemBuilder: (context, index) {
          var player = players[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                // Placeholder for player image, replace with actual image fetching logic
                backgroundImage: NetworkImage(
                    'https://example.com/avatar/${player['id']}.jpg'),
              ),
              title: Text(player['username'] ?? 'Unknown Player'),
              onTap: () {
                // Handle the tap event
                print('Tapped on ${player['username']}');
              },
            ),
          );
        },
      ),
    );
  }
}
