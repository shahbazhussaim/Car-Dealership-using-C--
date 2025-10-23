import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:karigar_woodwork/firebase_options.dart';
import 'package:google_sign_in/google_sign_in.dart';

enum AppInitState { configured, setupRequired }

class FirebaseService {
  // --- Initialization ---
  static Future<AppInitState> initialize() async {
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      final hasPlaceholders =
          options.apiKey == 'REPLACE_ME' || options.appId == 'REPLACE_ME';
      if (hasPlaceholders) {
        return AppInitState.setupRequired;
      }
      await Firebase.initializeApp(options: options);
      return AppInitState.configured;
    } catch (_) {
      return AppInitState.setupRequired;
    }
  }

  // --- Shortcuts ---
  static fb.FirebaseAuth get auth => fb.FirebaseAuth.instance;
  static FirebaseFirestore get db => FirebaseFirestore.instance;
  static FirebaseStorage get storage => FirebaseStorage.instance;

  // --- Auth helpers ---
  static Future<String?> signInWithEmailPassword(String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> registerWithEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await auth.createUserWithEmailAndPassword(email: email, password: password);
      await db.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'user',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<void> signOut() async => auth.signOut();

  static Future<String?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return 'Sign-in aborted';
      final googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await auth.signInWithCredential(credential);
      // Ensure user doc exists
      final ref = db.collection('users').doc(cred.user!.uid);
      await ref.set({
        'name': cred.user!.displayName,
        'email': cred.user!.email,
        'photoURL': cred.user!.photoURL,
        'role': 'user',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // --- Storage helpers ---
  static Future<String> uploadFileAndGetUrl({
    required File file,
    required String path,
    String? contentType,
  }) async {
    final ref = storage.ref().child(path);
    final task = await ref.putFile(file, SettableMetadata(contentType: contentType));
    return await task.ref.getDownloadURL();
  }

  // Example combined helper used by add_product screen
  static Future<String> createProductWithImage({
    required String name,
    required num price,
    required File imageFile,
  }) async {
    final id = db.collection('products').doc().id;
    final ext = imageFile.path.split('.').last;
    final url = await uploadFileAndGetUrl(
      file: imageFile,
      path: 'products/$id/main.$ext',
      contentType: 'image/$ext',
    );
    await db.collection('products').doc(id).set({
      'name': name,
      'price': price,
      'imageUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }
}
