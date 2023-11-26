import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:footy_fix/services/sharedPreferences_service.dart';

class DatabaseServices {
  final ref = FirebaseDatabase.instance.ref();

  void createUser(UserCredential userCredential, String email) async {
    DatabaseReference usersRef =
        FirebaseDatabase.instance.ref("users/${userCredential.user!.uid}");
    await usersRef.set({
      "email": email,
      "newUser": true,
    });
  }

  Future<bool?> getUserPreferences() async {
    var userID = await PreferencesService().getUserId();
    print("User ID: $userID");
    final snapshot = await ref.child('users/$userID/newUser').get();
    print(snapshot.value);
    if (snapshot.exists) {
      return snapshot.value as bool?;
    } else {
      return null;
    }
  }

  Future<void> updateUserPreference(
      String uid, String key, dynamic value) async {
    DatabaseReference userPrefRef =
        FirebaseDatabase.instance.ref('users/$uid/preferences');

    await userPrefRef.update({key: value});
  }
}
