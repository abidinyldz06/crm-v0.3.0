// lib/firebase_options.dart

// ignore_for_file: type=lint

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

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
    // This is a web-only project for now. 
    // Throw an error for other platforms to indicate they need configuration.
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform. '
          'You need to configure them manually in firebase_options.dart',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDiPCw0dFstgWN6tyh6SlZBWp2iHhn3mEg',
    appId: '1:697382137611:web:7703a7788c465ae852bc0e',
    messagingSenderId: '697382137611',
    projectId: 'vize-danismanlik-crm-eda30',
    authDomain: 'vize-danismanlik-crm-eda30.firebaseapp.com',
    storageBucket: 'vize-danismanlik-crm-eda30.firebasestorage.app',
    measurementId: 'G-2LKHDY1GDX',
  );
} 