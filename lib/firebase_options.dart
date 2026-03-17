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
    apiKey: 'AIzaSyAkhccPsGzyynKoHeEDWrV52jPhFvcVMfs',
    appId: '1:32663654067:web:53dee517aafd0283c0eac6',
    messagingSenderId: '32663654067',
    projectId: 'app-aroma-hortela',
    authDomain: 'app-aroma-hortela.firebaseapp.com',
    storageBucket: 'app-aroma-hortela.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAhMcYtv_Vlpt6eEm2ViUVknwqlUihXsCs',
    appId: '1:32663654067:android:4e8a8ed1358e9fb9c0eac6',
    messagingSenderId: '32663654067',
    projectId: 'app-aroma-hortela',
    storageBucket: 'app-aroma-hortela.firebasestorage.app',
  );

  // Placeholders para outras plataformas (configurar depois se necessário)

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDBaMUYbS9e-Ewg4FjxmWKR2OebiuX6AhY',
    appId: '1:32663654067:ios:3b826f7b3db3b52fc0eac6',
    messagingSenderId: '32663654067',
    projectId: 'app-aroma-hortela',
    storageBucket: 'app-aroma-hortela.firebasestorage.app',
    iosBundleId: 'com.example.appAromaHortela',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDBaMUYbS9e-Ewg4FjxmWKR2OebiuX6AhY',
    appId: '1:32663654067:ios:3b826f7b3db3b52fc0eac6',
    messagingSenderId: '32663654067',
    projectId: 'app-aroma-hortela',
    storageBucket: 'app-aroma-hortela.firebasestorage.app',
    iosBundleId: 'com.example.appAromaHortela',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAkhccPsGzyynKoHeEDWrV52jPhFvcVMfs',
    appId: '1:32663654067:web:53dfa1e8d4865f81c0eac6',
    messagingSenderId: '32663654067',
    projectId: 'app-aroma-hortela',
    authDomain: 'app-aroma-hortela.firebaseapp.com',
    storageBucket: 'app-aroma-hortela.firebasestorage.app',
  );

}