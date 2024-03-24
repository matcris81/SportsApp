import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';

class GamePlayers extends StatelessWidget {
  final List<dynamic> players;

  GamePlayers({Key? key, required this.players}) : super(key: key);

  Future<String?> fetchImageData(String playerImageId) async {
    // var token =
    //     await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    try {
      var response = await DatabaseServices().getData(
          '${DatabaseServices().backendUrl}/api/player-images/$playerImageId');

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print('Failed to load image data');
        return null;
      }
    } catch (exception) {
      print('Exception fetching image data: $exception');
      return null;
    }
  }

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
              leading: (player['playerImage'] != null &&
                      player['playerImage']['id'] != null)
                  ? FutureBuilder<String?>(
                      future: fetchImageData(
                          player['playerImage']['id'].toString()),
                      builder: (BuildContext context,
                          AsyncSnapshot<String?> snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            snapshot.hasData) {
                          Map<String, dynamic> imageData =
                              jsonDecode(snapshot.data!);
                          var decodedBytes =
                              base64Decode(imageData['imageData']);
                          return CircleAvatar(
                            backgroundImage: MemoryImage(decodedBytes),
                            radius: 20.0,
                          );
                        } else if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 20.0,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          );
                        } else {
                          return const CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 20.0,
                            child: Icon(Icons.person, color: Colors.white),
                          );
                        }
                      },
                    )
                  : const CircleAvatar(
                      backgroundColor: Colors.grey,
                      radius: 20.0,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
              title: Text(player['username'] ?? 'Unknown Player'),
              onTap: () {
                // Handle the tap event
              },
            ),
          );
        },
      ),
    );
  }
}
