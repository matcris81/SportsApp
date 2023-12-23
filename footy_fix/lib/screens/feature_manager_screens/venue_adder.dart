import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_service.dart';
import 'package:footy_fix/services/db_services.dart';

class AddVenue extends StatefulWidget {
  const AddVenue({Key? key}) : super(key: key);

  @override
  _AddVenueState createState() => _AddVenueState();
}

class _AddVenueState extends State<AddVenue> {
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  String venueName = '';
  String address = '';
  String description = '';
  String city = '';
  String suburb = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Venue',
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
                            return 'Please enter venue name';
                          }
                          return null;
                        },
                        onSaved: (value) => venueName = value!,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Address',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Address';
                          }
                          return null;
                        },
                        onSaved: (value) => address = value!,
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Suburb',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter Suburb';
                          }
                          return null;
                        },
                        onSaved: (value) => suburb = value!,
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        children: <Widget>[
                          Expanded(
                            // Use Expanded to fill the available space
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'City',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter City';
                                }
                                return null;
                              },
                              onSaved: (value) => city = value!,
                            ),
                          ),
                          const SizedBox(
                              width: 16.0), // Space between the TextFields
                          Expanded(
                            // Use Expanded for the second TextField
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Post Code',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter Post Code';
                                }
                                return null;
                              },
                              onSaved: (value) => city =
                                  value!, // This should probably be a different variable, not 'city'
                            ),
                          ),
                        ],
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            String formattedAddress =
                                '$address, $suburb, $city';

                            var newVenue = {
                              'name': venueName,
                              'address': formattedAddress,
                              'description': description,
                            };

                            // DatabaseServices()
                            //     .addWithIDToDataBase('Venues/', newVenue);

                            PostgresService().insert('venues', newVenue);

                            // Navigator.pop(context);
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
