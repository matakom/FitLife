//import 'package:googleapis/fitness/v1.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


Future<bool> loginUser() async {
  print('loginUser');
  User? user = await my_authentication().signInWithGoogle();
  print('done maybe...');
  if(user?.emailVerified ?? false){
    return true;
  }
  return false;
}

Future<void> logoutUser() async {
  print('logoutUser');
  await my_authentication().signOut();
  print('done maybe...');
}

class my_authentication{
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