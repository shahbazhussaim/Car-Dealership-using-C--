import 'package:firebase_core/firebase_core.dart';
import 'package:karigar_woodwork/firebase_options.dart';

enum AppInitState { configured, setupRequired }

class FirebaseService {
  static Future<AppInitState> initialize() async {
    try {
      if (DefaultFirebaseOptions.isPlaceholder) {
        return AppInitState.setupRequired;
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      return AppInitState.configured;
    } catch (_) {
      return AppInitState.setupRequired;
    }
  }
}
