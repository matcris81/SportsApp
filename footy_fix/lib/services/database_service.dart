import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:footy_fix/services/sharedPreferences_service.dart';
import 'package:firebase_core/firebase_core.dart';

class DatabaseServices {
  DatabaseReference ref = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://fitfeat-bf285-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  void createUser(UserCredential userCredential, String email) async {
    print("User $userCredential created");
    await ref.child('/users/${userCredential.user!.uid}').set({
      "name": userCredential.user!.displayName,
      "email": email,
    });
  }

  Future<bool?> getUserPreferences() async {
    var userID = await PreferencesService().getUserId();

    try {
      DataSnapshot snapshot = await ref.child('users/$userID').get();

      if (snapshot.exists) {
        if (snapshot.value == true) {
          return true;
        } else {
          return false;
        }
      } else {
        print('No data available at the specified path.');
        return null;
      }
    } catch (e) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        print('Permission denied to access data: $e');
        return null;
      } else {
        print('Error fetching data: $e');
        return null;
      }
    }
  }

  Future<void> updateDatabase(String uid, String key, dynamic value) async {
    DatabaseReference userPrefRef = FirebaseDatabase.instance.ref('users/$uid');

    print(userPrefRef);

    return await userPrefRef.update({key: value});
  }

  Future<void> addFilter(String path, dynamic value) async {
    // print(userPrefRef);

    return await ref.child(path).push().set(value);
  }
}
