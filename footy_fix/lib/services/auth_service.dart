import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:footy_fix/shared_preferences.dart';

class AuthService {
  Future<UserCredential> registerWithEmailPassword(
      String email, String password) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      PreferencesService().saveUserId(userCredential.user!.uid);

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

      // store userID locally
      PreferencesService().saveUserId(userCredential.user!.uid);

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

      final OAuthCredential credential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      PreferencesService().saveUserId(userCredential.user!.uid);

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
        final AuthCredential credential =
            FacebookAuthProvider.credential(result.accessToken!.token);

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        PreferencesService().saveUserId(userCredential.user!.uid);

        return userCredential;
      } else {
        print("Facebook Sign-In Failed: ${result.status}");
      }
    } catch (e) {
      print("Error during Facebook Sign-In: $e");
    }
  }
}
