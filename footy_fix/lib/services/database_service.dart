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
    await ref.child('/users/${userCredential.user!.uid}').set({
      "name": userCredential.user!.displayName,
      "email": email,
    });
    print("User $userCredential created");
  }

  Future<Object?> retrieveFromDatabase(String path) async {
    try {
      DataSnapshot snapshot = await ref.child(path).get();
      if (snapshot.exists) {
        return snapshot.value;
      } else {
        print(path);
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

  Future<void> updateDatabase(String path, String key, dynamic value) async {
    DatabaseReference userPrefRef = FirebaseDatabase.instance.ref(path);

    return await userPrefRef.update({key: value});
  }

  Future<void> addToDataBase(String path, dynamic value) async {
    try {
      await ref.child(path).push().set(value);
      print('Data successfully added');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<Object?> retrieveMultiple(String path) async {
    try {
      DataSnapshot snapshot = await ref.child(path).get();

      if (snapshot.exists) {
        return snapshot.value;
      } else {
        print('No data available at the specified path.');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }
}
