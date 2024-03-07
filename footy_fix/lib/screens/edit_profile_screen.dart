import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/components/invisibleButton.dart';
import 'package:footy_fix/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>(); // Add a key for the form
  List<String> genderOptions = ['MALE', 'FEMALE'];
  int genderElement = 0;
  String? email;
  String? dob;
  String? gender;
  int? phone;
  String _selectedGender = 'None';
  String? userID;
  String? _genderValidationError;

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  String? _validateGender(String? selectedGender) {
    if (selectedGender == null || selectedGender == 'None') {
      return 'Please select a gender';
    }
    return null; // null means valid
  }

// When validating (e.g., on form submission)
  void _validateForm() {
    setState(() {
      _genderValidationError = _validateGender(_selectedGender);
    });

    if (_genderValidationError == null) {
      // Proceed with form submission or further validation
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2025),
    );

    if (picked != null) {
      setState(() {
        dob = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  void getUserID() async {
    var id = await PreferencesService().getUserId();
    setState(() {
      userID = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
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
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Center vertically
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 16.0),
                      _buildInvisibleTextField(
                        label: 'Email',
                        maxLines: 1,
                        onSaved: (value) => email = value,
                      ),
                      const SizedBox(height: 16.0),
                      buildCustomButton(
                        label: dob != null && dob!.isNotEmpty
                            ? dob!
                            : 'Select Date of Birth',
                        onPressed: () {
                          _selectDate(context);
                        },
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16.0),
                      buildCustomButton(
                        label: _selectedGender != 'None'
                            ? _selectedGender
                            : 'Select Gender',
                        onPressed: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                                backgroundColor: Colors.white,
                                itemExtent: 30,
                                scrollController: FixedExtentScrollController(
                                  initialItem:
                                      genderOptions.indexOf(_selectedGender),
                                ),
                                children: genderOptions
                                    .map((gender) => Text(gender))
                                    .toList(),
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    _selectedGender = genderOptions[value];
                                    // Validate gender selection immediately upon change
                                    _genderValidationError =
                                        _validateGender(_selectedGender);
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        icon: Icons.arrow_drop_down,
                      ),
                      if (_genderValidationError !=
                          null) // Show error message if validation fails
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            _genderValidationError!,
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                        ),
                      const SizedBox(height: 16.0),
                      _buildInvisibleTextField(
                        label: 'Phone',
                        maxLines: 3,
                        onSaved: (value) {
                          if (value != null && value.isNotEmpty) {
                            phone = int.parse(value);
                          }
                        },
                      ),
                      const SizedBox(height: 24.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();

                            Map<String, dynamic> data = {
                              'id': userID,
                            };

                            if (email != null && email!.isNotEmpty) {
                              data['email'] = email;

                              AuthService().updateUserEmail(data['email']);
                            }

                            if (dob != null && dob!.isNotEmpty) {
                              data['dob'] = dob;
                            }

                            if (phone != null) {
                              data['phoneNumber'] = phone;
                            }

                            data['gender'] = _selectedGender != 'None'
                                ? _selectedGender
                                : null;

                            var token = await DatabaseServices()
                                .authenticateAndGetToken('admin', 'admin');

                            var response = await DatabaseServices().patchData(
                                '${DatabaseServices().backendUrl}/api/players/$userID',
                                token,
                                data);

                            Navigator.pop(context);
                          }
                        },
                        child: Text('Done'),
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
        labelStyle: const TextStyle(
          color: Colors.black, // Set label color to black
          fontWeight: FontWeight.w500, // Set font weight
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide:
              BorderSide(color: Colors.black), // Set border color to black
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
              color: Colors
                  .black), // Set border color to black when field is focused
        ),
      ),
      style: const TextStyle(
        fontWeight: FontWeight.w500, // Set font weight for input text
        color: Colors.black, // Set input text color to black
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      onSaved: onSaved,
    );
  }
}
