import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

class DatabaseServices {
  DatabaseReference rootReference = FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL:
        'https://fitfeat-bf285-default-rtdb.asia-southeast1.firebasedatabase.app/',
  ).ref();

  void createUser(UserCredential userCredential, String email) async {
    await rootReference.child('/users/${userCredential.user!.uid}').set({
      "name": userCredential.user!.displayName,
      "email": email,
    });
    print("User $userCredential created");
  }

  Future<Object?> retrieveLocal(String path) async {
    DatabaseReference localRef = rootReference.child(path);
    var completer = Completer<Object?>();

    localRef.onValue.listen((event) {
      var data = event.snapshot.value;

      // Check if data is a list and filter out null elements
      if (data is List) {
        var nonNullData = data.where((element) => element != null).toList();
        if (!completer.isCompleted) {
          completer.complete(nonNullData);
        }
      } else {
        if (!completer.isCompleted) {
          completer.complete(data);
        }
      }
    });

    return completer.future;
  }

  Future<Object?> retrieveFromDatabase(String path) async {
    try {
      DataSnapshot snapshot = await rootReference.child(path).get();
      if (snapshot.exists) {
        // Directly return the value as it should not include the userID key
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

  Future<void> updateDatabase(String path, dynamic value) async {
    return await rootReference.child(path).update(value);
  }

  Future<void> addWithIDToDataBase(String path, dynamic value) async {
    DatabaseReference reference = rootReference.child(path).push();

    try {
      await reference.set(value);
      print('Data successfully added');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<void> addWithoutIDToDataBase(String path, dynamic value) async {
    DatabaseReference reference = rootReference.child(path);

    try {
      await reference.set(value);
      print('Data successfully added');
    } catch (e) {
      print('Error adding data: $e');
    }
  }

  Future<String> addJustID(String path) async {
    DatabaseReference reference = rootReference.child(path).push();

    try {
      await reference.set(true);
      print('Data successfully added');
      return reference.key!;
    } catch (e) {
      print('Error adding data: $e');
      return 'Error adding data';
    }
  }

  Future<Object?> retrieveMultiple(String path) async {
    try {
      DataSnapshot snapshot = await rootReference.child(path).get();

      if (snapshot.exists) {
        var values = snapshot.value;
        if (values is List) {
          // Convert to a growable list and remove null values
          List<dynamic> growableList = List.from(values);
          growableList.removeWhere((value) => value == null);
          return growableList;
        }
        return values;
      } else {
        print('No data available at the specified path.');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<void> incrementValue(String path, String key) async {
    DatabaseReference referee = rootReference.child(path);

    try {
      await referee.update({key: ServerValue.increment(1)});
    } catch (e) {
      print('Error incrementing players joined: $e');
    }
  }

  Future<void> removeFromDatabase(String path) async {
    // DatabaseReference referee = rootReference.child(path);
    print(path);

    try {
      await rootReference.child(path).remove();
    } catch (e) {
      print('Error removing data: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      print('User successfully signed out');
    } catch (e) {
      print('Error signing out: $e');
    }
  }
}
