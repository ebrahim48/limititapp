// File generated based on GoogleService-Info.plist (iOS) and
// google-services.json (Android) for Firebase project: limitit-387c8.
// To regenerate, run: flutterfire configure --project=limitit-387c8

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Values from GoogleService-Info.plist
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDC8wko81NPXrwH3N-SKcmxNiSticqAKbc',
    appId: '1:499698578290:ios:ae3e77513af06012c923eb',
    messagingSenderId: '499698578290',
    projectId: 'limitit-387c8',
    storageBucket: 'limitit-387c8.firebasestorage.app',
    iosBundleId: 'com.limitit.digitalbalance',
    iosClientId: '499698578290-4l2bs1816ffmqiblnnps3q0n4j9q21jo.apps.googleusercontent.com',
  );

  // Values from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAeRbC_PIudcRh9xoZcx0B6WF54IpnknIw',
    appId: '1:499698578290:android:e88def277fbac1afc923eb',
    messagingSenderId: '499698578290',
    projectId: 'limitit-387c8',
    storageBucket: 'limitit-387c8.firebasestorage.app',
    androidClientId: '499698578290-44brc5ch03s9gqd4pss9c5goji31d42r.apps.googleusercontent.com',
  );
}
