import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    throw UnsupportedError(
      'DefaultFirebaseOptions are not supported for this platform.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCeyouKT8n0byj-VVQR4oLn8Md973-58F4',
    authDomain: 'event-7e7d4.firebaseapp.com',
    projectId: 'event-7e7d4',
    storageBucket: 'event-7e7d4.firebasestorage.app',
    messagingSenderId: '28834744285',
    appId: '1:28834744285:web:b69af973d605bdbbed1834',
    measurementId: 'G-EL694RD33D',
  );
} 