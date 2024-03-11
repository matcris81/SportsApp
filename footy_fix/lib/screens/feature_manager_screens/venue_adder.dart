import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/components/invisibleTextField.dart';

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
  Uint8List? _venueImage; // State variable for the venue image

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Venue',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    buildInvisibleTextField(
                      label: 'Venue Name',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter venue name'
                          : null,
                      onSaved: (value) => venueName = value!,
                    ),
                    const SizedBox(height: 16.0),
                    buildInvisibleTextField(
                      label: 'Address',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Address'
                          : null,
                      onSaved: (value) => address = value!,
                    ),
                    const SizedBox(height: 16.0),
                    buildInvisibleTextField(
                      label: 'Suburb',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Suburb'
                          : null,
                      onSaved: (value) => suburb = value!,
                    ),
                    const SizedBox(height: 16.0),
                    // No need for Row for City and Postcode since it's similar to the others
                    buildInvisibleTextField(
                      label: 'City',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter City'
                          : null,
                      onSaved: (value) => city = value!,
                    ),
                    const SizedBox(height: 16.0),
                    buildInvisibleTextField(
                      label: 'Description',
                      maxLines: 3,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter a description'
                          : null,
                      onSaved: (value) => description = value!,
                    ),
                    const SizedBox(height: 24.0),
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          String formattedAddress = '$address, $suburb, $city';

                          var newVenue = {
                            'venueName': venueName,
                            'address': formattedAddress,
                            'description': description,
                          };

                          String token = await DatabaseServices()
                              .authenticateAndGetToken('admin', 'admin');

                          var response = await DatabaseServices().postData(
                              '${DatabaseServices().backendUrl}/api/venues',
                              token,
                              newVenue);

                          print('response.body: ${response.body}');

                          if (!mounted) return;

                          Navigator.pop(context);
                        }
                      },
                      child: Text('Submit',
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
