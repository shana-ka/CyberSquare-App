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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyD021jqi-P-pOQmHUPSmNgxIhs7Piub5Zk',
    appId: '1:954080835515:web:97c95feaad5e256a3a369e',
    messagingSenderId: '954080835515',
    projectId: 'cyber-square-app',
    authDomain: 'cyber-square-app.firebaseapp.com',
    storageBucket: 'cyber-square-app.appspot.com',
    measurementId: 'G-PBNHRM3Z3V',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAnaqWVN77bxpQc1qDrXTe3uINvghuaNU',
    appId: '1:954080835515:android:3889c1059b08dede3a369e',
    messagingSenderId: '954080835515',
    projectId: 'cyber-square-app',
    storageBucket: 'cyber-square-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCTw1gt95MIIUwX5JAQFma2pGAfA0h5XQQ',
    appId: '1:954080835515:ios:31c50ac36f6fd3873a369e',
    messagingSenderId: '954080835515',
    projectId: 'cyber-square-app',
    storageBucket: 'cyber-square-app.appspot.com',
    iosBundleId: 'com.example.cybersquareapp',
  );
}
