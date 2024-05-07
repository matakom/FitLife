import 'package:firebase_auth/firebase_auth.dart';
import 'package:fit_life/preferences.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'connection.dart' as server;


Future<bool> loginUser() async {
  User? user = await MyAuthentication().signInWithGoogle();
  if(user?.emailVerified ?? false){
    server.Connection.login(user?.email ?? '', user?.displayName ?? '');
    Preferences.setMail(user?.email ?? '');
    server.Connection.getSteps();
    return true;
  }
  return false;
}

Future<void> logoutUser() async {
  await MyAuthentication().signOut();
}

class MyAuthentication{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();


  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount!.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      UserCredential authResult = await _auth.signInWithCredential(credential);
      User? user = authResult.user;
      return user;
    } catch (error) {
      print("Google Sign-In Error: $error");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await googleSignIn.signOut();
  }
}