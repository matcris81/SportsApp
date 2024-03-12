import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'dart:convert';

class SelectVenue extends StatefulWidget {
  const SelectVenue({Key? key}) : super(key: key);

  @override
  _SelectVenueState createState() => _SelectVenueState();
}

class _SelectVenueState extends State<SelectVenue> {
  String filter = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Select Venue',
          style: TextStyle(
            fontSize: 20,
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
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 40,
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    filter = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<int, String>>(
              future: getData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No data found'));
                } else {
                  // Filter the list
                  Map<int, String> filteredMap = Map.fromIterable(
                    snapshot.data!.entries,
                    key: (entry) => entry.key,
                    value: (entry) => entry.value,
                  )..removeWhere((key, value) => !value.contains(filter));

                  return ListView.builder(
                    itemCount: filteredMap.length,
                    itemBuilder: (context, index) {
                      int key = filteredMap.keys.elementAt(index);
                      String value = filteredMap[key]!;
                      List<dynamic> keyValue = [key, value];
                      return ListTile(
                        title: Text(filteredMap[key]!),
                        onTap: () {
                          Navigator.pop(context, keyValue);
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<int, String>> getData() async {
    String token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/venues',
        token); // Replace with your API endpoint

    print('response.body: ${response.body}');

    // Decode the JSON string
    List<dynamic> jsonList = json.decode(response.body);

    // Convert the list into a Map
    Map<int, String> venuesMap = {
      for (var item in jsonList) item['id']: item['venueName']
    };

    return venuesMap;
  }
}
