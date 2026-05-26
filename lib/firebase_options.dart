// ✅ FIXED: Added Android platform support
// Previously crashed with UnsupportedError on Android

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;  // ✅ Now returns Android config instead of crashing
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'iOS not configured yet. Add iOS app in Firebase Console.',
        );
      default:
        throw UnsupportedError(
          'Unsupported platform: $defaultTargetPlatform',
        );
    }
  }

  // ── Web config (unchanged) ──────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey:            'AIzaSyCiMMyo4HLRfASZMNjMhnKKnOuiNsjrlMY',
    authDomain:        'easype-898d5.firebaseapp.com',
    databaseURL:       'https://easype-898d5-default-rtdb.firebaseio.com',
    projectId:         'easype-898d5',
    storageBucket:     'easype-898d5.firebasestorage.app',
    messagingSenderId: '22375589279',
    appId:             '1:22375589279:web:fb1bfbae6e6e97c42cc9aa',
  );

  // ── Android config ──────────────────────────────────────────────────────────
  // ⚠️  REPLACE these values with your actual Android credentials from:
  //     Firebase Console → Project Settings → Your Apps → Android app
  //     OR just download google-services.json (see README_FIREBASE_SETUP.md)
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_ANDROID_API_KEY',          // ← replace
    appId:             'YOUR_ANDROID_APP_ID',           // ← replace  e.g. 1:22375589279:android:xxxx
    messagingSenderId: '22375589279',                   // same as web
    projectId:         'easype-898d5',                  // same as web
    storageBucket:     'easype-898d5.firebasestorage.app',
    databaseURL:       'https://easype-898d5-default-rtdb.firebaseio.com',
  );
}