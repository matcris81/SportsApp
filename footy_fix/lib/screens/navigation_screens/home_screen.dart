import 'package:flutter/material.dart';
import 'package:footy_fix/services/geolocator_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // var venues = DatabaseServices().('/');

  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text('Home', style: TextStyle(color: Colors.black)),
      centerTitle: true,
      automaticallyImplyLeading: false, // This line removes the back button
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Aligns children to the start of the column
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Implement the button's on-pressed action
            },
            style: ElevatedButton.styleFrom(
              primary: Colors.black,
              onPrimary: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              minimumSize: const Size(double.infinity, 36),
            ),
            child: Text('Find a Game'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Venues',
            style: TextStyle(
              fontSize: 24, // Adjust the font size as needed
              fontWeight: FontWeight.bold, // Makes the text bold
              color: Colors.black, // Set the color of the text
            ),
          ),
        ),
      ],
    ),
  );
}

}
