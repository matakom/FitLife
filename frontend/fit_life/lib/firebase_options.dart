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
    apiKey: 'AIzaSyCpfGu_HKM2PsMjphijqeLfWLsXbHJqEPc',
    appId: '1:755428474674:web:b1fd30e55a6fe73d92212b',
    messagingSenderId: '755428474674',
    projectId: 'fit-life-398908',
    authDomain: 'fit-life-398908.firebaseapp.com',
    storageBucket: 'fit-life-398908.appspot.com',
    measurementId: 'G-V117SFGQ0Z',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBA5l5hVe-Zw2zb878tkqzi1V7-Imw3LPE',
    appId: '1:755428474674:android:b78fd00f8ca3c48692212b',
    messagingSenderId: '755428474674',
    projectId: 'fit-life-398908',
    storageBucket: 'fit-life-398908.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAN7XeR_ArERKXBE2RBG1jogOuF5TwKssQ',
    appId: '1:755428474674:ios:d5418a9dede929d992212b',
    messagingSenderId: '755428474674',
    projectId: 'fit-life-398908',
    storageBucket: 'fit-life-398908.appspot.com',
    iosClientId: '755428474674-200fid7ape8lk1fl44m2u4hlf2s2ktk7.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitLife',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAN7XeR_ArERKXBE2RBG1jogOuF5TwKssQ',
    appId: '1:755428474674:ios:b11932c17bb4ee3992212b',
    messagingSenderId: '755428474674',
    projectId: 'fit-life-398908',
    storageBucket: 'fit-life-398908.appspot.com',
    iosClientId: '755428474674-831in28g5e29uq8m9fv3uio6ob4h88t8.apps.googleusercontent.com',
    iosBundleId: 'com.example.fitLife.RunnerTests',
  );
}
