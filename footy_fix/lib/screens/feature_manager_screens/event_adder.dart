import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/screens/feature_manager_screens/select_venues_screen.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  String locationName = '';
  int locationID = 0;
  String time = '';
  double price = 0;
  int size = 0;
  String sport = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != selectedTime) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Future<List<String>> fetchVenueNames() async {
    var result = await PostgresService().retrieve("SELECT name FROM venues");
    return result.map((row) => row[0] as String).toList();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);
      DateTime pickedDate = DateTime(picked.year, picked.month, picked.day);

      if (!mounted) return;

      if (pickedDate.isBefore(today)) {
        // Show error message if picked date is before today
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You cannot select a past date.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (pickedDate != selectedDate) {
        setState(() {
          selectedDate = picked;
        });
      }
    }
  }

  String timeOfDayToString(TimeOfDay time) {
    final hours = time.hour.toString().padLeft(2, '0');
    final minutes = time.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  void navigateAndDisplaySelection(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SelectVenue()),
    );

    if (result != null) {
      setState(() {
        locationID = result[0];
        locationName = result[1];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Event',
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
      body: SingleChildScrollView(
        // Add SingleChildScrollView
        child: Center(
          // Center the content
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              // Constrain the size of the Column
              constraints: const BoxConstraints(
                  maxWidth:
                      600), // Set a max width for better look on wide screens
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Selected Venue: $locationName'),
                      ElevatedButton(
                        onPressed: () => navigateAndDisplaySelection(context),
                        child: const Text('Select Venue'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => _selectDate(context),
                        child: const Text('Select Date'),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        child: Text(selectedTime == null
                            ? 'Select Time'
                            : 'Time: ${selectedTime!.format(context)}'),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            // Use Expanded to fill the available space
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Price',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: const TextInputType
                                  .numberWithOptions(
                                  decimal:
                                      true), // Enable numeric input with decimal
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a price';
                                }
                                if (double.tryParse(value) == null) {
                                  // Check if value is a valid double
                                  return 'Please enter a price';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                price = double.parse(
                                    value!); // Parse the value to double
                              },
                            ),
                          ),
                          const SizedBox(
                              width: 16.0), // Space between the TextFields
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Number of Players',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType
                                  .number, // Enable numeric input without decimal
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Number of Players';
                                }
                                if (int.tryParse(value) == null) {
                                  // Check if value is a valid integer
                                  return 'Please enter Number of Players';
                                }
                                return null;
                              },
                              onSaved: (value) {
                                size =
                                    int.parse(value!); // Parse the value to int
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Sport',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Sport';
                          }
                          return null;
                        },
                        onSaved: (value) => sport = value!,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                        onSaved: (value) => description = value!,
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            DateTime combinedDateTime = DateTime(
                              selectedDate!.year,
                              selectedDate!.month,
                              selectedDate!.day,
                              selectedTime!.hour,
                              selectedTime!.minute,
                            );

                            var formatter =
                                DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'");
                            String formattedDate =
                                formatter.format(combinedDateTime!);

                            print(
                                'location: $locationName'); // Output: "2024-01-06T00:00:00Z"

                            // String formattedTime =
                            //     timeOfDayToString(selectedTime!);

                            // Parse the date from DD/MM/YYYY format and reformat to YYYY-MM-DD
                            // print(selectedDate);
                            // DateTime parsedDate = DateFormat('dd/MM/yyyy')
                            //     .parse(selectedDate.toString());
                            // String formattedDate =
                            //     DateFormat('yyyy-MM-dd').format(parsedDate);

                            // var venueIDResult = await PostgresService().retrieve(
                            //     "SELECT venue_id FROM venues WHERE name = '$location'");
                            // var venueID = venueIDResult[0][0];

                            // var sportIDResult = await PostgresService().retrieve(
                            //     "SELECT sport_id FROM sports WHERE name = '$sport'");
                            // var sportID = sportIDResult[0][0];

                            var token = await DatabaseServices()
                                .authenticateAndGetToken('admin', 'admin');

                            // var sportID = DatabaseServices().getData(
                            //     'http://localhost:4242/api/venues/by-name/$location',
                            //     token);

                            // // print(sportID);

                            var game = {
                              'venueId': locationID,
                              // 'sportId': sportID,
                              'gameDate': formattedDate,
                              // 'startTime': formattedDate,
                              'description': description,
                              'size': size,
                              'price': price,
                            };

                            // print(game);

                            // // await PostgresService().insert('games', game);

                            await DatabaseServices().postData(
                                'http://localhost:4242/api/games', token, game);

                            if (!mounted) return;

                            Navigator.pop(context);
                          }
                        },
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          primary:
                              Colors.black, // Set the background color to black
                          onPrimary:
                              Colors.white, // Set the text color to white
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
