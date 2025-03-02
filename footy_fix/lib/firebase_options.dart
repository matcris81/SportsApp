// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDB_opz2o0-9B_2LR0wFJO67kP3wFoY-eU',
    appId: '1:955778873823:web:7b316680142b89f641ec6a',
    messagingSenderId: '955778873823',
    projectId: 'fitfeat-bf285',
    authDomain: 'fitfeat-bf285.firebaseapp.com',
    storageBucket: 'fitfeat-bf285.appspot.com',
    measurementId: 'G-L7DH7H8NJR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB2RUByYt57hT8HeinrhS2AXu2F9pXnB5g',
    appId: '1:955778873823:android:2b90c5cdce45af7d41ec6a',
    messagingSenderId: '955778873823',
    projectId: 'fitfeat-bf285',
    storageBucket: 'fitfeat-bf285.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-2xH1BItUWeaZYe8x9rWSqDa5yItq4iA',
    appId: '1:955778873823:ios:540469368ebabe1a41ec6a',
    messagingSenderId: '955778873823',
    projectId: 'fitfeat-bf285',
    storageBucket: 'fitfeat-bf285.appspot.com',
    androidClientId: '955778873823-a82asu6781g0iaqoh1keh57pek2a9l60.apps.googleusercontent.com',
    iosClientId: '955778873823-e7hkg44t0sk3euiijgsti38ogtverqo2.apps.googleusercontent.com',
    iosBundleId: 'com.21e8.footyFix',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-2xH1BItUWeaZYe8x9rWSqDa5yItq4iA',
    appId: '1:955778873823:ios:a756f228cad35d2341ec6a',
    messagingSenderId: '955778873823',
    projectId: 'fitfeat-bf285',
    storageBucket: 'fitfeat-bf285.appspot.com',
    androidClientId: '955778873823-a82asu6781g0iaqoh1keh57pek2a9l60.apps.googleusercontent.com',
    iosClientId: '955778873823-tq1vcot1l02fgqnts86d05nls6c50k02.apps.googleusercontent.com',
    iosBundleId: 'com.example.footyFix.RunnerTests',
  );
}
