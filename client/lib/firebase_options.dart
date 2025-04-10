// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
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
        return windows;
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
    apiKey: 'AIzaSyCgPyIg6OLATw7T0-Q2kn7ySNr6qT8T1m4',
    appId: '1:559511865236:web:f90245e9601f4e0a6e3181',
    messagingSenderId: '559511865236',
    projectId: 'famcare-1d4c9',
    authDomain: 'famcare-1d4c9.firebaseapp.com',
    storageBucket: 'famcare-1d4c9.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-CON-cvhW8w4wYe9tLV_s0UG4-ChW0nY',
    appId: '1:559511865236:android:76ad37a0688eae376e3181',
    messagingSenderId: '559511865236',
    projectId: 'famcare-1d4c9',
    storageBucket: 'famcare-1d4c9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBVBXAstV20A3F_RCzS-NJn2Tmoslq9z-0',
    appId: '1:559511865236:ios:df72c685c534fb7e6e3181',
    messagingSenderId: '559511865236',
    projectId: 'famcare-1d4c9',
    storageBucket: 'famcare-1d4c9.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBVBXAstV20A3F_RCzS-NJn2Tmoslq9z-0',
    appId: '1:559511865236:ios:df72c685c534fb7e6e3181',
    messagingSenderId: '559511865236',
    projectId: 'famcare-1d4c9',
    storageBucket: 'famcare-1d4c9.firebasestorage.app',
    iosBundleId: 'com.example.client',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCgPyIg6OLATw7T0-Q2kn7ySNr6qT8T1m4',
    appId: '1:559511865236:web:9bfc07f678da9d216e3181',
    messagingSenderId: '559511865236',
    projectId: 'famcare-1d4c9',
    authDomain: 'famcare-1d4c9.firebaseapp.com',
    storageBucket: 'famcare-1d4c9.firebasestorage.app',
  );

}