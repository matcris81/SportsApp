// import 'package:flutter/material.dart';

// class UpcomingGamesList extends StatelessWidget {
//   final List<String> games;

//   // Constructor to accept a list of games
//   const UpcomingGamesList({Key? key, required this.games}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: games.length,
//       itemBuilder: (context, index) {
//         return Card(
//           child: ListTile(
//             title: Text(games[index]),
//             // You can add more properties here, like leading, trailing widgets
//             onTap: () {
//               // Handle the game item tap, if necessary
//               print('Tapped on: ${games[index]}');
//             },
//           ),
//         );
//       },
//     );
//   }
// }
