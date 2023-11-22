import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  signInWithGoogle() async {
    // begin interactive sign in process
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    //obtain auth details from request
    final GoogleSignInAuthentication gAuth = await gUser!.authentication;

    print("Google Sign-In Email: ${gUser.email}");
    print("Google Sign-In Email: ${gUser.displayName}");

    // create a new credential for user
    final credential = GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    //finally, lets sign in
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  signInWithApple() async {
    try {
      var still = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print(still);
      print(AppleIDAuthorizationScopes.fullName);
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
        final userData = await FacebookAuth.instance.getUserData();
        print("Facebook Sign-In Email: ${userData["email"]}");
        print("Facebook Sign-In Name: ${userData["name"]}");
      } else {
        print("Facebook Sign-In Failed: ${result.status}");
      }
    } catch (e) {
      print("Error during Facebook Sign-In: $e");
    }
  }
}
