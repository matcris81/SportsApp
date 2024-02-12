import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    getUserID();
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
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        // validator: (value) {
                        //   return null;
                        // },
                        onSaved: (value) => email = value,
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () => _selectDate(context),
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Date of Birth',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.calendar_today),
                            ),
                            controller: TextEditingController(text: dob),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      GestureDetector(
                        onTap: () {
                          showCupertinoModalPopup(
                            context: context,
                            builder: (_) => SizedBox(
                              width: double.infinity,
                              height: 250,
                              child: CupertinoPicker(
                                backgroundColor: Colors.white,
                                itemExtent: 30,
                                scrollController: FixedExtentScrollController(
                                  initialItem: genderElement,
                                ),
                                children: genderOptions
                                    .map((gender) => Text(gender))
                                    .toList(),
                                onSelectedItemChanged: (int value) {
                                  setState(() {
                                    _selectedGender = genderOptions[value];
                                    genderElement = value;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                        child: AbsorbPointer(
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                              suffixIcon: Icon(Icons.arrow_drop_down),
                            ),
                            controller:
                                TextEditingController(text: _selectedGender),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Phone',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        // validator: (value) {
                        //   return null;
                        // },
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
                            }

                            if (dob != null && dob!.isNotEmpty) {
                              data['dob'] = dob;
                            }

                            if (phone != null) {
                              data['phoneNumber'] = phone;
                            }

                            data['gender'] = _selectedGender;

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
}
