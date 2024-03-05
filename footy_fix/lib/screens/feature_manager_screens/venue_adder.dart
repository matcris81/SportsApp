import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:image_picker/image_picker.dart';

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
                    _buildCustomButton(
                      label: 'Add Image',
                      onPressed: _pickImage,
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

  Widget _buildCustomButton(
      {required String label, required VoidCallback onPressed}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
      ),
      child: _venueImage == null
          ? Text(label)
          : Container(
              width: double.infinity, // Use the full width of the button
              height: 60, // Fixed height for the image
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: MemoryImage(_venueImage!),
                  fit: BoxFit.cover,
                ),
              ),
            ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery); // or ImageSource.camera

    if (image != null) {
      Uint8List imageBytes = await image.readAsBytes();

      String base64Image = base64Encode(imageBytes);

      Map<String, dynamic> imageData = {
        'imageData': base64Image,
      };

      String token =
          await DatabaseServices().authenticateAndGetToken('admin', 'admin');

      try {
        var response = await DatabaseServices().postData(
          '${DatabaseServices().backendUrl}/api/images',
          token,
          imageData,
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          print('Image uploaded successfully: ${response.body}');
        } else {
          print('Failed to upload image: ${response.statusCode}');
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }
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
