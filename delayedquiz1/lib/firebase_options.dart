import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyAEfVoCIK4IZs9ObcKwIswWi34w-O3ODok',
    appId: '1:669389968480:web:df758af0e1c9ca90f6df05',
    messagingSenderId: '669389968480',
    projectId: 'delayedquiz-app',
    authDomain: 'delayedquiz-app.firebaseapp.com',
    storageBucket: 'delayedquiz-app.firebasestorage.app',
    measurementId: 'G-77D8MKZMZN',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCh4rGSr41x6Lj_s_uSKxbOlWHVsZW3cX8',
    appId: '1:669389968480:android:b4018c2781599ebcf6df05',
    messagingSenderId: '669389968480',
    projectId: 'delayedquiz-app',
    storageBucket: 'delayedquiz-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALkih-jpLS_oyOXz-bKyYZaybbgyey8pE',
    appId: '1:669389968480:ios:4ed0da649b1ec3c1f6df05',
    messagingSenderId: '669389968480',
    projectId: 'delayedquiz-app',
    storageBucket: 'delayedquiz-app.firebasestorage.app',
    iosBundleId: 'com.example.delayedquiz1',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALkih-jpLS_oyOXz-bKyYZaybbgyey8pE',
    appId: '1:669389968480:ios:4ed0da649b1ec3c1f6df05',
    messagingSenderId: '669389968480',
    projectId: 'delayedquiz-app',
    storageBucket: 'delayedquiz-app.firebasestorage.app',
    iosBundleId: 'com.example.delayedquiz1',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAEfVoCIK4IZs9ObcKwIswWi34w-O3ODok',
    appId: '1:669389968480:web:0a088a44e614de07f6df05',
    messagingSenderId: '669389968480',
    projectId: 'delayedquiz-app',
    authDomain: 'delayedquiz-app.firebaseapp.com',
    storageBucket: 'delayedquiz-app.firebasestorage.app',
    measurementId: 'G-N5ZFD0CPMR',
  );

}