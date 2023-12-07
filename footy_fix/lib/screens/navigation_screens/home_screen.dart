import 'package:flutter/material.dart';
import 'package:footy_fix/components/navigation.dart';
import 'package:footy_fix/services/geolocator_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    GeolocatorService().determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        // bottomNavigationBar: NavBar(),
        );
  }
}

// class HomeScreen extends StatefulWidget {
//   // Constructor to accept a string
//   const HomeScreen({Key? key}) : super(key: key);

//   @override
//   _SearchScreenState createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   Position? currentPosition = GeolocatorService().currentPosition;

//   Future<List<MyListItem>>? _itemsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _itemsFuture = _loadItems(currentPosition!);
//   }

//   Future<List<MyListItem>> _loadItems(Position currentPosition) async {
//     List<MyListItem> items = [];
//     List<String> locationNamesList = [];

//     // Check if location data is stored in shared preferences
//     items = await PreferencesService().loadLocationDataList(context);
//     // Object? locationNames = await DatabaseServices().retrieveLocal('Locations');

//     if (items.isEmpty) {
//       // print(locationNames);
//       // else fetch location names from the database
//       Object? locationNames =
//           await DatabaseServices().retrieveMultiple('Locations');

//       // Check if locationNames is a list
//       if (locationNames is List) {
//         locationNamesList =
//             locationNames.map((item) => item.toString()).toList();
//       } else {
//         print('locationNames is not a list');
//       }

//       for (String locationName in locationNamesList) {
//         if (locationName != null) {
//           // Fetch address from the database
//           var address = await DatabaseServices()
//               .retrieveLocal('Location Details/$locationName/Address');
//           String addressString = address.toString();

//           Map<double, double>? coordinates = await GeolocatorService()
//               .getCoordinatesFromAddress(addressString);

//           double distance = GeolocatorService().calculateDistance(
//             currentPosition.latitude,
//             currentPosition.longitude,
//             coordinates!.keys.first,
//             coordinates.values.first,
//           );

//           items.add(MyListItem(
//             locationName: locationName,
//             distance: distance, // Pass the calculated distance
//             onTap: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => LocationDescription(
//                     locationName: locationName,
//                   ),
//                 ),
//               );
//             },
//           ));
//         }
//       }
//       await PreferencesService().saveLocationDataList(items);
//     }
//     return items;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         automaticallyImplyLeading: false, // This line removes the back button
//         title: Text("Search"),
//       ),
//       body: FutureBuilder<List<MyListItem>>(
//         future: _itemsFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             // Show loading indicator while data is being fetched
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             // Handle any errors here
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             // Data is ready, build the ListView
//             return ListView.builder(
//               itemCount: snapshot.data!.length,
//               itemBuilder: (context, index) {
//                 return snapshot.data![index];
//               },
//             );
//           } else {
//             // Handle the case where there's no data
//             return Center(child: Text('No data found'));
//           }
//         },
//       ),
//     );
//   }
// }
