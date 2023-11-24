import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  // for all sign in techniques/ registration there needs to be a userID created and stored locally using shared preferences

  Future<UserCredential> registerWithEmailPassword(
      String email, String password) async {
    FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // Handle error
      throw e;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Begin interactive sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

      // If user cancelled the Google sign-in process, gUser will be null
      if (gUser == null) {
        print('Google Sign-In cancelled');
        return null;
      }

      // Obtain auth details from request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a new credential for the user
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Finally, sign in with Firebase
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      print('Google Sign-In successful, User UID: ${userCredential.user?.uid}');

      // USE SHARED PREFERENCES TO STORE USER ID

      return userCredential;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  // may need to check if apple sign in is available appleSignInAvailable() type shi
  signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Create a new credential
      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // USE SHARED PREFERENCES TO STORE USER ID

      // Sign in to Firebase with the Apple credential
      return userCredential;
    } catch (error) {
      print("Error signing in with Apple: $error");
    }
  }

  signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ["public_profile", "email"],
      );

      if (result.status == LoginStatus.success) {
        // Create a credential from the access token
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        // USE SHARED PREFERENCES TO STORE USER ID

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        // Sign in to Firebase with the Facebook credential
        return userCredential;
      } else {
        print("Facebook Sign-In Failed: ${result.status}");
      }
    } catch (e) {
      print("Error during Facebook Sign-In: $e");
    }
  }
}
