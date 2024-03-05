import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';

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
                    _buildInvisibleTextField(
                      label: 'Venue Name',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter venue name'
                          : null,
                      onSaved: (value) => venueName = value!,
                    ),
                    const SizedBox(height: 16.0),
                    _buildInvisibleTextField(
                      label: 'Address',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Address'
                          : null,
                      onSaved: (value) => address = value!,
                    ),
                    const SizedBox(height: 16.0),
                    _buildInvisibleTextField(
                      label: 'Suburb',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Suburb'
                          : null,
                      onSaved: (value) => suburb = value!,
                    ),
                    const SizedBox(height: 16.0),
                    // No need for Row for City and Postcode since it's similar to the others
                    _buildInvisibleTextField(
                      label: 'City',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter City'
                          : null,
                      onSaved: (value) => city = value!,
                    ),
                    const SizedBox(height: 16.0),
                    _buildInvisibleTextField(
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
                            // 'description': description,
                          };

                          String token = await DatabaseServices()
                              .authenticateAndGetToken('admin', 'admin');

                          await DatabaseServices().postData(
                              '${DatabaseServices().backendUrl}/api/venues',
                              token,
                              newVenue);

                          if (!mounted) return;

                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Submit',
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

  Widget _buildInvisibleTextField({
    required String label,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String?)? onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
