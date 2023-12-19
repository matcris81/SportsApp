import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/screens/payment_screen.dart';

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
    String dayOfWeek = DateFormat('EEEE').format(dateTime);
    String abbreviatedDayName = dayOfWeek.substring(0, 3).toUpperCase();
    String abbreviatedMonthName = DateFormat('MMM')
        .format(dateTime)
        .toUpperCase(); // Abbreviated month name

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize:
              MainAxisSize.min, // Add this to make the card wrap content height
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Image.asset(
                    'assets/football.jpg',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
                Positioned(
                  top: 65, // Adjust the position as needed
                  right: 8, // Adjust the position as needed
                  child: Container(
                    padding: const EdgeInsets.all(
                        6), // Padding inside the container for the icon
                    decoration: BoxDecoration(
                      color: Colors.black
                          .withOpacity(0.5), // Semi-transparent black
                      borderRadius: BorderRadius.circular(
                          4), // Slightly rounded corners for the square
                    ),
                    child: Icon(
                      Icons.sports_soccer, // Use the appropriate Icons value
                      size: 16, // Size of the icon
                      color: Colors.white, // Color of the icon
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$abbreviatedDayName, $abbreviatedMonthName ${dateTime.day} • $time',
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                  ),
                  const SizedBox(height: 4),
                  const Divider(),
                  Text(
                    '$playersJoined/$size spots left',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical:
                        0), // Increase horizontal padding to make the button narrower
                child: TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    minimumSize:
                        const Size.fromHeight(50), // Keeps the button height
                    backgroundColor: Colors.black, // Button color
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(30), // Very rounded edges
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                                  locationName: location,
                                  gameID: gameID,
                                  price: price,
                                  date: date,
                                )));
                  }, // Use the onTap passed to the widget
                  child: Text(
                      'Join for \$${price.toStringAsFixed(2)}'), // Formats the price with 2 decimal places
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
