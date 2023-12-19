import 'package:flutter/material.dart';

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
          'Payment',
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
              padding: EdgeInsets.only(bottom: 30),
              child: Text(
                'What would you like to add?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Venue button functionality
              },
              child: Text(
                'Venue',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button background color
                onPrimary: Colors.blue, // Button text color
                padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15), // Increased horizontal padding
                minimumSize: const Size(150, 40), // Minimum size of the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
            const SizedBox(height: 20), // Spacing between the buttons
            ElevatedButton(
              onPressed: () {
                // TODO: Implement Event button functionality
              },
              child: Text(
                'Event',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                primary: Colors.black, // Button background color
                onPrimary: Colors.green, // Button text color
                padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 15), // Increased horizontal padding
                minimumSize: const Size(150, 40), // Minimum size of the button
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
