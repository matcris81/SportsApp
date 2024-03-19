import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:footy_fix/screens/feature_manager_screens/select_venues_screen.dart';
import 'package:footy_fix/components/invisibleButton.dart';
import 'package:footy_fix/components/invisibleTextField.dart';

class AddEvent extends StatefulWidget {
  final bool privateEvent;
  final int? venueId;

  const AddEvent({Key? key, required this.privateEvent, this.venueId})
      : super(key: key);

  @override
  _AddEventState createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final _formKey = GlobalKey<FormState>();
  String locationName = '';
  int venueID = 0;
  String time = '';
  double price = 0;
  int size = 0;
  String sport = '';
  String description = '';
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  bool _isSubmitting = false;

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? tempPickedTime =
        selectedTime ?? TimeOfDay.fromDateTime(DateTime.now());

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
              use24hFormat: true,
              onDateTimeChanged: (DateTime newDateTime) {
                tempPickedTime = TimeOfDay(
                    hour: newDateTime.hour, minute: newDateTime.minute);
              },
            ),
          );
        });
    if (!mounted) return;

    if (tempPickedTime != selectedTime) {
      setState(() {
        selectedTime = tempPickedTime;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime tempPickedDate = selectedDate ?? DateTime.now();

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
        venueID = result[0];
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

  Future<String> fetchVenueName(int venueId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');
    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/venues/$venueId', token);
    var venueDetails = json.decode(response.body);
    return venueDetails['venueName'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Event',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
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
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: <Widget>[
                    const SizedBox(height: 16.0),
                    widget.venueId != null
                        ? FutureBuilder<String>(
                            future: fetchVenueName(widget.venueId!),
                            builder: (BuildContext context,
                                AsyncSnapshot<String> snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return buildCustomButton(
                                    label: 'Loading venue...',
                                    onPressed: () {});
                              } else if (snapshot.hasError) {
                                return buildCustomButton(
                                    label: 'Error loading venue',
                                    onPressed: () {});
                              } else {
                                return buildCustomButton(
                                  label: 'Venue: ${snapshot.data}',
                                );
                              }
                            },
                          )
                        : buildCustomButton(
                            label: locationName.isNotEmpty
                                ? 'Venue: $locationName'
                                : 'Select Venue',
                            onPressed: () =>
                                navigateAndDisplaySelection(context),
                            icon: Icons.keyboard_arrow_right,
                          ),
                    const SizedBox(height: 16.0),
                    buildCustomButton(
                      label: selectedDate != null
                          ? 'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                          : 'Select Date',
                      onPressed: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16.0),
                    buildCustomButton(
                      label: selectedTime == null
                          ? 'Select Time'
                          : 'Time: ${timeOfDayToString(selectedTime!)}',
                      onPressed: () => _selectTime(context),
                    ),
                    const SizedBox(height: 16.0),
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
                    buildInvisibleTextField(
                      label: 'Sport',
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter Sport'
                          : null,
                      onSaved: (value) => sport = value!,
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

                          print('venueId: ${widget.venueId}');

                          if (widget.privateEvent) {
                            venueID = widget.venueId!;
                          }

                          var game = {
                            'venueId': venueID,
                            'sportId': sportID,
                            'gameDate': formattedDate,
                            'description': description,
                            'size': size,
                            'price': price,
                            'organizer': {'id': userID},
                          };

                          var response = await DatabaseServices().postData(
                              '${DatabaseServices().backendUrl}/api/games',
                              token,
                              game);

                          Map<String, dynamic> gameInfo =
                              jsonDecode(response.body);

                          setState(() {
                            _isSubmitting = false;
                          });
                          if (!mounted) return;

                          // Navigator.pop(context);

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
