import 'package:flutter/material.dart';
import 'package:footy_fix/services/db_services.dart';
import 'package:intl/intl.dart';

class AddEvent extends StatefulWidget {
  const AddEvent({Key? key}) : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  String location = '';
  String date = '';
  String time = '';
  double price = 0;
  int size = 0;
  String sport = '';
  String description = '';

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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Venue Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Venue Name';
                          }
                          return null;
                        },
                        onSaved: (value) => location = value!,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Date';
                          }
                          return null;
                        },
                        onSaved: (value) => date = value!,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Time';
                          }
                          return null;
                        },
                        onSaved: (value) => time = value!,
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

                            // Parse the date from DD/MM/YYYY format and reformat to YYYY-MM-DD
                            DateTime parsedDate =
                                DateFormat('dd/MM/yyyy').parse(date);
                            String formattedDate =
                                DateFormat('yyyy-MM-dd').format(parsedDate);

                            var venueIDResult = await PostgresService().retrieve(
                                "SELECT venue_id FROM venues WHERE name = '$location'");
                            var venueID = venueIDResult[0][0];

                            var sportIDResult = await PostgresService().retrieve(
                                "SELECT sport_id FROM sports WHERE name = '$sport'");
                            var sportID = sportIDResult[0][0];

                            var game = {
                              'venue_id': venueID,
                              'sport_id': sportID,
                              'game_date':
                                  formattedDate, // Use the correctly formatted date
                              'start_time': time,
                              'description': description,
                              'max_players': size,
                              'price': price,
                            };

                            print(game);

                            await PostgresService().insert('games', game);

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
