import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCRE0gF-4TASBYFsz8g9sEtSCTO37IHCz4',
    appId: '1:799003895018:web:YOUR_WEB_APP_ID',
    messagingSenderId: '799003895018',
    projectId: 'dawa-sante',
    authDomain: 'dawa-sante.firebaseapp.com',
    storageBucket: 'dawa-sante.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRE0gF-4TASBYFsz8g9sEtSCTO37IHCz4',
    appId: '1:799003895018:android:f2c12c15b69f2063552393',
    messagingSenderId: '799003895018',
    projectId: 'dawa-sante',
    storageBucket: 'dawa-sante.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCRE0gF-4TASBYFsz8g9sEtSCTO37IHCz4',
    appId: '1:799003895018:ios:ef1320a8ba708741552393',
    messagingSenderId: '799003895018',
    projectId: 'dawa-sante',
    storageBucket: 'dawa-sante.firebasestorage.app',
    iosBundleId: 'com.dawa-sante.dawa',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCPkze36iJ29sG6uS9MMHo4z47kyw9IG5c',
    appId: '1:799003895018:ios:7dd62c518a7e41c2552393',
    messagingSenderId: '799003895018',
    projectId: 'dawa-sante',
    storageBucket: 'dawa-sante.firebasestorage.app',
    iosBundleId: 'com.dawa-sante.dawaSante',
  );
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCRE0gF-4TASBYFsz8g9sEtSCTO37IHCz4',
    appId: '1:799003895018:windows:YOUR_WINDOWS_APP_ID',
    messagingSenderId: '799003895018',
    projectId: 'dawa-sante',
    storageBucket: 'dawa-sante.firebasestorage.app',
  );
}
