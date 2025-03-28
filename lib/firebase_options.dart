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
    apiKey: 'AIzaSyDxWf16j8LMP78B9kAMA_pgLDEuMSTunwE',
    appId: '1:236762861453:web:5fde6871a83355d47177c4',
    messagingSenderId: '236762861453',
    projectId: 'travellista-59e43',
    authDomain: 'travellista-59e43.firebaseapp.com',
    storageBucket: 'travellista-59e43.firebasestorage.app',
    measurementId: 'G-78RK6H8DFS',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDeoAKUP2CnDKeQxm5HI8rmX0_PinaRsUQ',
    appId: '1:236762861453:android:1f65102e4cb05bfa7177c4',
    messagingSenderId: '236762861453',
    projectId: 'travellista-59e43',
    storageBucket: 'travellista-59e43.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCN3t4CaiVsrsfYn1G7Ag1FS5ab3VnOXNE',
    appId: '1:236762861453:ios:efe3b80c9369ed667177c4',
    messagingSenderId: '236762861453',
    projectId: 'travellista-59e43',
    storageBucket: 'travellista-59e43.firebasestorage.app',
    iosBundleId: 'com.example.travellista',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCN3t4CaiVsrsfYn1G7Ag1FS5ab3VnOXNE',
    appId: '1:236762861453:ios:efe3b80c9369ed667177c4',
    messagingSenderId: '236762861453',
    projectId: 'travellista-59e43',
    storageBucket: 'travellista-59e43.firebasestorage.app',
    iosBundleId: 'com.example.travellista',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDxWf16j8LMP78B9kAMA_pgLDEuMSTunwE',
    appId: '1:236762861453:web:a7d56474f84f00bf7177c4',
    messagingSenderId: '236762861453',
    projectId: 'travellista-59e43',
    authDomain: 'travellista-59e43.firebaseapp.com',
    storageBucket: 'travellista-59e43.firebasestorage.app',
    measurementId: 'G-SJ2LTDYY9H',
  );
}
