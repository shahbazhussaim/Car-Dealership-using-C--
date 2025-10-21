// Placeholder Firebase options. Replace this file by running:
// flutter pub add firebase_core && dart pub global activate flutterfire_cli
// flutterfire configure
// For now, we create a placeholder so the app compiles and shows a setup screen.

import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => const FirebaseOptions(
        apiKey: 'REPLACE_ME',
        appId: 'REPLACE_ME',
        messagingSenderId: 'REPLACE_ME',
        projectId: 'REPLACE_ME',
        storageBucket: 'REPLACE_ME.appspot.com',
      );

  static bool get isPlaceholder =>
      currentPlatform.apiKey == 'REPLACE_ME' ||
      currentPlatform.projectId == 'REPLACE_ME';
}
