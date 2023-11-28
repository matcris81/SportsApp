import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';

class LocationDescription extends StatefulWidget {
  final String location;

  // Constructor to accept a string
  const LocationDescription({Key? key, required this.location})
      : super(key: key);

  @override
  _LocationDescriptionState createState() => _LocationDescriptionState();
}

class _LocationDescriptionState extends State<LocationDescription> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.location),
        ),
        body: FutureBuilder<Object?>(
            future: DatabaseServices()
                .retrieveMultiple('Location Details/${widget.location}'),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }
              // print(snapshot.data);
              if (!snapshot.hasData) {
                return const Center(child: Text('No data found'));
              }

              List<String> games = [];
              if (snapshot.data is Map) {
                Map<Object?, Object?> dataMap =
                    snapshot.data as Map<Object?, Object?>;
                games = dataMap.values.whereType<String>().toList();
              } else {
                // Handle the case where data is not a map
                return const Center(
                    child: Text('Data is not in the expected format'));
              }

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
