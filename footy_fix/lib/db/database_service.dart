import 'package:firebase_database/firebase_database.dart';
import 'package:footy_fix/shared_preferences.dart';

class DatabaseServices {
  final databaseReference = FirebaseDatabase.instance.ref();

  void createUserPreferences() {}

  void getUserPreferences() {
    PreferencesService().getUserId().then((userId) {
      databaseReference.child('users').child(userId!).once().then((snapshot) {
        // print('Data : ${snapshot.value}');
      });
    });
  }
}
