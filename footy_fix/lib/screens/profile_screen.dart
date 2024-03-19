import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:footy_fix/screens/checkout_screen.dart';
import 'package:footy_fix/screens/edit_profile_screen.dart';
import 'package:footy_fix/screens/past_purchases_screen.dart';
import 'package:footy_fix/screens/payment_screen.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';
import 'package:footy_fix/services/database_services.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Uint8List? _profileImage; // State variable for profile image
  String userID = '';
  Future<Map<String, dynamic>>? playerDataFuture;

  @override
  void initState() {
    super.initState();
    getUserID();
    playerDataFuture = getPlayerData(); // Fetch player data once
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
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 5.0),
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.edit, color: Colors.black),
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => EditProfileScreen()));
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
      body: FutureBuilder(
        future: playerDataFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var playerData = snapshot.data as Map<String, dynamic>;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: <Widget>[
                const SizedBox(height: 30),
                Center(
                    child: GestureDetector(
                  onTap: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? image =
                        await _picker.pickImage(source: ImageSource.gallery);

                    if (image != null) {
                      var compressedImage =
                          await FlutterImageCompress.compressWithFile(
                        image.path,
                        minWidth: 120,
                        minHeight: 120,
                        quality: 90,
                      );

                      if (compressedImage != null) {
                        Uint8List imageBytes = compressedImage;
                        String base64Image = base64Encode(imageBytes);

                        setState(() {
                          _profileImage = imageBytes;
                        });

                        Map<String, dynamic> imageBody = {
                          'imageData': base64Image,
                        };

                        var token = await DatabaseServices()
                            .authenticateAndGetToken('admin', 'admin');
                        var playerImage = await DatabaseServices().postData(
                            '${DatabaseServices().backendUrl}/api/player-images',
                            token,
                            imageBody);

                        Map<String, dynamic> playerImageID =
                            jsonDecode(playerImage.body);

                        Map<String, dynamic> body = {
                          'id': userID,
                          'playerImage': {
                            'id': playerImageID['id'],
                            'imageData': base64Image
                          },
                        };

                        var response = await DatabaseServices().patchData(
                            '${DatabaseServices().backendUrl}/api/players/$userID',
                            token,
                            body);
                      } else {
                        print("Image compression failed.");
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey,
                    child: _profileImage != null
                        ? CircleAvatar(
                            radius: 59,
                            backgroundImage: MemoryImage(_profileImage!),
                          )
                        : const Icon(Icons.person,
                            size: 60, color: Colors.white),
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
                        '${playerData['email'] ?? '-'}',
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
                        '${playerData['dob'] ?? '-'}',
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
                        '${playerData['gender'] ?? '-'}',
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
                        '${playerData['phoneNumber'] ?? '-'}',
                        style: const TextStyle(
                            fontWeight: FontWeight.normal, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentScreen(
                                  price: 10.0,
                                  topUp: true,
                                )));
                    print("Top Up button pressed!");
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Top Up Balance'),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PastPurchasesScreen()));
                  },
                  child: Text('Past Purchases'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
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

    print('userID: $userID');

    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices()
        .getData('${DatabaseServices().backendUrl}/api/players/$userID', token);

    playerData = jsonDecode(response.body);
    print('response.body: ${response.body}');

    if (playerData['playerImage'] != null) {
      getPlayerImage(playerData['playerImage']['id']);
    }

    return playerData;
  }

  Future<Uint8List> getPlayerImage(int imageId) async {
    var token =
        await DatabaseServices().authenticateAndGetToken('admin', 'admin');

    var response = await DatabaseServices().getData(
        '${DatabaseServices().backendUrl}/api/player-images/$imageId', token);

    String image = jsonDecode(response.body)['imageData'];

    if (image != '') {
      setState(() {
        _profileImage = base64Decode(image);
      });
    }

    return response.bodyBytes;
  }
}
