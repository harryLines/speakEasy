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
    apiKey: 'AIzaSyA3NL0j4oets1TUXgea_g8cDY6HyQhD968',
    appId: '1:519080341275:web:94c9447499c377da80adbe',
    messagingSenderId: '519080341275',
    projectId: 'speakeasy-dcd1f',
    authDomain: 'speakeasy-dcd1f.firebaseapp.com',
    storageBucket: 'speakeasy-dcd1f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDMrJbuwUe3VDo3MoVZMWaKeVH81RVoLNQ',
    appId: '1:519080341275:android:310d0310bc4276f180adbe',
    messagingSenderId: '519080341275',
    projectId: 'speakeasy-dcd1f',
    storageBucket: 'speakeasy-dcd1f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDjFi1gyPqP2uKmgrxi2BEqQdksIz0STRI',
    appId: '1:519080341275:ios:5a80eeca174adb7b80adbe',
    messagingSenderId: '519080341275',
    projectId: 'speakeasy-dcd1f',
    storageBucket: 'speakeasy-dcd1f.appspot.com',
    iosClientId: '519080341275-7g1s4odqp7bhs6qj2fabqescdjkjkdhh.apps.googleusercontent.com',
    iosBundleId: 'com.example.speakEasy',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDjFi1gyPqP2uKmgrxi2BEqQdksIz0STRI',
    appId: '1:519080341275:ios:5a80eeca174adb7b80adbe',
    messagingSenderId: '519080341275',
    projectId: 'speakeasy-dcd1f',
    storageBucket: 'speakeasy-dcd1f.appspot.com',
    iosClientId: '519080341275-7g1s4odqp7bhs6qj2fabqescdjkjkdhh.apps.googleusercontent.com',
    iosBundleId: 'com.example.speakEasy',
  );
}
