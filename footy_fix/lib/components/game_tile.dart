import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GameTile extends StatelessWidget {
  final String location;
  final String date;
  final String gameID;
  final String time;
  final String playersJoined;
  final double price;
  final String size;
  final Function()? onTap;

  const GameTile({
    Key? key,
    required this.location,
    required this.date,
    required this.gameID,
    required this.time,
    required this.playersJoined,
    required this.price,
    required this.size,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    DateTime dateTime = DateFormat('dd MM yyyy').parse(date);
    String dayName = DateFormat('EEEE').format(dateTime).substring(0, 3);
    String monthName = DateFormat('MMMM').format(dateTime);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              location,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 5),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$playersJoined/$size',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  '$dayName, $monthName ${dateTime.day}',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
