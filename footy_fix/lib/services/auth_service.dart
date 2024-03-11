import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:footy_fix/services/shared_preferences_service.dart';

class AuthService {
  Future<UserCredential> registerWithEmailPassword(
      String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException {
      // Handle error
      rethrow;
    }
  }

  Future<UserCredential?> signInWithEmailPassword(
      String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await auth.currentUser!.getIdToken(true);

      return userCredential;
    } catch (e) {
      // Handle error
      return null;
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

      // store userID locally

      return userCredential;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      return null;
    }
  }

  // may need to check if apple sign in is available appleSignInAvailable() type shi
  Future<UserCredential?> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      return userCredential;
    } catch (error) {
      print("Error signing in with Apple: $error");
      return null;
    }
  }

  // Future<UserCredential?> signInWithFacebook() async {
  //   try {
  //     final LoginResult result = await FacebookAuth.instance.login(
  //       permissions: ["public_profile", "email"],
  //     );

  //     final AuthCredential credential =
  //         FacebookAuthProvider.credential(result.accessToken!.token);

  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     return userCredential;
  //   } catch (e) {
  //     print("Error during Facebook Sign-In: $e");
  //     return null;
  //   }
  // }

  Future<void> updateUserEmail(String newEmail) async {
    User? user = FirebaseAuth.instance.currentUser;

    try {
      await user?.updateEmail(newEmail);
      print("Email updated successfully");
      // Optionally, re-authenticate the user here if needed
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print(
            'The user must re-authenticate before this operation can be executed.');
        // Handle re-authentication
      } else {
        print(e.message); // Handle other errors
      }
    } catch (e) {
      print(e); // Handle generic errors
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
    // Clear local preferences if necessary
    PreferencesService().clearUserId();
  }
}
