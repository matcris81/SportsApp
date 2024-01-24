import 'package:flutter/material.dart';
import 'package:footy_fix/screens/feature_manager_screens/event_adder.dart';
import 'package:footy_fix/screens/feature_manager_screens/venue_adder.dart';

class GameVenueManager extends StatefulWidget {
  const GameVenueManager({Key? key}) : super(key: key);

  @override
  _GameVenueManagerState createState() => _GameVenueManagerState();
}

class _GameVenueManagerState extends State<GameVenueManager> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Venue or Game',
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Would you like to add a venue?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddVenue()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button background color
                foregroundColor: Colors.blue, // Button text color
                padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15), // Increased horizontal padding
                minimumSize: const Size(150, 40), // Minimum size of the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Venue',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(
                height: 30), // Spacing between the venue and event sections
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
              child: Text(
                'Or an event?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AddEvent()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15), // Increased horizontal padding
                minimumSize: const Size(150, 40), // Minimum size of the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const Text(
                'Event',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
