import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Locations'),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50), // Adjust as needed
            child: Container(
              padding: const EdgeInsets.only(bottom: 20), // Adjust as needed
              alignment: Alignment.bottomCenter,
              child: Text(
                'Locations',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ),
        ),
        body: FutureBuilder<List<String>>(
            future: DatabaseServices().retrieveMultiple('Locations'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No data found'));
              }

              List<String> games = snapshot.data!;
              return ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(games[index]),
                  );
                },
              );
            }));
  }
}
