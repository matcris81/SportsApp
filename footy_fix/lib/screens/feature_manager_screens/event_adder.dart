import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/descriptions/game_description.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/screens/feature_manager_screens/select_venues_screen.dart';
import 'package:footy_fix/components/invisibleButton.dart';
import 'package:footy_fix/components/invisibleTextField.dart';

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
  int? playersAlreadyJoined;
  bool _isSubmitting = false; // Add this line

  Future<void> _selectTime(BuildContext context) async {
    // Initialize tempPickedTime with the current selectedTime or the current time
    TimeOfDay? tempPickedTime =
        selectedTime ?? TimeOfDay.fromDateTime(DateTime.now());

    // Show Cupertino Modal Bottom Sheet
    final result = await showModalBottomSheet<TimeOfDay>(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime(
                  DateTime.now().year,
                  DateTime.now().month,
                  DateTime.now().day,
                  selectedTime?.hour ?? DateTime.now().hour,
                  selectedTime?.minute ?? DateTime.now().minute),
              use24hFormat: true, // Use 24 hour format based on your preference
              onDateTimeChanged: (DateTime newDateTime) {
                // Update tempPickedTime as the user changes the picker's value
                tempPickedTime = TimeOfDay(
                    hour: newDateTime.hour, minute: newDateTime.minute);
              },
            ),
          );
        });

    // If the modal is dismissed (result == null), then the picker was used and dismissed by tapping outside
    if (!mounted) return;

    // Update the state with the temporary picked time when the modal is dismissed
    if (tempPickedTime != selectedTime) {
      setState(() {
        selectedTime = tempPickedTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    // Store the picked date temporarily
    DateTime tempPickedDate = selectedDate ?? DateTime.now();

    // Show Cupertino Modal Bottom Sheet
    await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height * 0.25,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              initialDateTime: selectedDate ?? DateTime.now(),
              minimumYear: 2000,
              maximumYear: 2025,
              onDateTimeChanged: (DateTime newDate) {
                tempPickedDate = newDate;
              },
            ),
          );
        });

    // Once a date is selected and modal is closed, update the state
    if (!mounted) return;

    if (tempPickedDate != selectedDate) {
      setState(() {
        selectedDate = tempPickedDate;
      });
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

  Future<String?> getSportInfo(String sport) async {
    bool sportExists = false;
    String? sportId;
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var sports = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/sports', token);

    List<dynamic> sportsResponse = jsonDecode(sports.body);

    print('sportsResponse: $sportsResponse');

    for (var sportInfo in sportsResponse) {
      if (sportInfo['sportName'] == sport) {
        sportExists = true;
        sportId = sportInfo['id'].toString();

        break;
      }
    }

    if (!sportExists) {
      Map<String, dynamic> sportBody = {
        'sportName': sport,
      };

      var response = await DatabaseServices().postData(
          '${DatabaseServices().backendUrl}/api/sports', token, sportBody);

      Map<String, dynamic> sportInfo = jsonDecode(response.body);

      sportId = sportInfo['id'].toString();
    }

    return sportId;
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
        backgroundColor: Colors.white, // Make AppBar background white
        iconTheme:
            IconThemeData(color: Colors.black), // Make AppBar back icon black
        elevation: 0, // Remove shadow
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
                child: ListView(
                  shrinkWrap:
                      true, // Ensures the ListView only occupies the space it needs
                  physics:
                      NeverScrollableScrollPhysics(), // Disables scrolling within the ListView
                  children: <Widget>[
                    const SizedBox(height: 16.0),
                    buildCustomButton(
                      label: locationName.isNotEmpty
                          ? 'Venue: $locationName'
                          : 'Select Venue',
                      onPressed: () => navigateAndDisplaySelection(context),
                      icon: Icons.keyboard_arrow_right,
                    ),
                    buildInvisibleTextField(
                      label: 'Price',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter a price';
                        if (double.tryParse(value) == null)
                          return 'Please enter a valid price';
                        return null;
                      },
                      onSaved: (value) => price = double.parse(value!),
                    ),
                    const SizedBox(height: 16.0),
                    buildInvisibleTextField(
                      label: 'Number of Players',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Number of Players';
                        if (int.tryParse(value) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                      onSaved: (value) => size = int.parse(value!),
                    ),
                    const SizedBox(height: 16.0),
                    buildCustomButton(
                      label: selectedDate != null
                          ? 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                          : 'Select Date',
                      onPressed: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16.0),
                    buildInvisibleTextField(
                      label: 'Sport',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Sport'
                          : null,
                      onSaved: (value) => sport = value!,
                    ),
                    const SizedBox(height: 16.0),
                    buildCustomButton(
                      label: selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${timeOfDayToString(selectedTime!)}',
                      onPressed: () => _selectTime(context),
                    ),
                    buildInvisibleTextField(
                      label: 'Players joined',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Please enter Number of Players that have joined';
                        if (int.tryParse(value) == null)
                          return 'Please enter a valid number';
                        return null;
                      },
                      onSaved: (value) =>
                          playersAlreadyJoined = int.parse(value!),
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
                              formatter.format(combinedDateTime);

                          var token = await DatabaseServices()
                              .authenticateAndGetToken('admin', 'admin');

                          var sportID = await getSportInfo(sport);

                          String? userID =
                              await PreferencesService().getUserId();

                          var game = {
                            'venueId': locationID,
                            'sportId': sportID,
                            'gameDate': formattedDate,
                            'description': description,
                            'size': size,
                            'price': price,
                            'organizer': {'id': userID},
                            'fakePlayers': playersAlreadyJoined,
                          };

                          print('playersAlreadyJoined: $playersAlreadyJoined');

                          var response = await DatabaseServices().postData(
                              '${DatabaseServices().backendUrl}/api/games',
                              token,
                              game);

                          Map<String, dynamic> gameInfo =
                              jsonDecode(response.body);

                          if (!mounted) return;

                          if (!mounted) return;
                          setState(() {
                            _isSubmitting = false;
                          });

                          context.go('/game/${gameInfo['id']}');
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            )
                          : const Text('Submit Event'),
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
