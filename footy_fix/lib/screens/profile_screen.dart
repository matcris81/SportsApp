import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;
  String userID = '';

  @override
  void initState() {
    super.initState();
    getUserID();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile',
            style: TextStyle(color: Colors.black, fontSize: 20)),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.arrow_back, color: Colors.black),
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder(
        future: getPlayerData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var playerData = snapshot.data as Map<String, dynamic>;

            Uint8List? _profileImage;

            if (playerData['profilePicture'] != null) {
              _profileImage = base64Decode(playerData['profilePicture']);
            }
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                const SizedBox(height: 30), // Spacer
                Center(
                    child: GestureDetector(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      String base64Image =
                          base64Encode(await image.readAsBytes());

                      setState(() {
                        _image = File(image.path);
                      });

                      Map<String, dynamic> body = {
                        'id': userID,
                        'profilePicture': base64Image,
                      };

                      var token = await DatabaseServices()
                          .authenticateAndGetToken('admin', 'admin');

                      var resposnse = await DatabaseServices().patchData(
                          '${DatabaseServices().backendUrl}/api/players/$userID',
                          token,
                          body);
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: MemoryImage(_profileImage ?? Uint8List(0)),
                  ),
                )),
                const SizedBox(height: 50),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Email:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '${playerData['email']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Date of Birth:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '${playerData['dateOfBirth']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.email),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Gender:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '${playerData['gender']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      const Text(
                        'Phone:',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      Text(
                        '${playerData['phone']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30), // Spacer between buttons
                ElevatedButton(
                  onPressed: () {
                    // TODO: Navigate to past orders screen
                  },
                  child: const Text('Past Orders'),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> getUserID() async {
    String? id = await PreferencesService().getUserId();
    setState(() {
      this.userID = id!;
    });
  }

  Future<Map<String, dynamic>> getPlayerData() async {
    Map<String, dynamic> playerData = {};

    var userID = await PreferencesService().getUserId();

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/players/$userID', token);

    playerData = jsonDecode(response.body);

    return playerData;
  }
}
