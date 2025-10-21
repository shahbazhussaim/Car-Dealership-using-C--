import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

enum AppRole { user, admin }

class AuthProvider extends ChangeNotifier {
  fb.FirebaseAuth? _auth; // Lazily initialized after Firebase is configured
  FirebaseFirestore? _db; // Lazily initialized after Firebase is configured

  bool _initializing = true;
  AppRole? _role;
  Map<String, dynamic>? _profile;

  bool get isInitializing => _initializing;
  fb.User? get user => _auth?.currentUser;
  AppRole? get role => _role;
  Map<String, dynamic>? get profile => _profile;
  bool get isAdmin => _role == AppRole.admin;

  Future<void> initialize() async {
    try {
      // Initialize Firebase instances only after app has been configured.
      _auth ??= fb.FirebaseAuth.instance;
      _db ??= FirebaseFirestore.instance;

      _auth!.authStateChanges().listen((fb.User? u) async {
        if (u == null) {
          _profile = null;
          _role = null;
          _initializing = false;
          notifyListeners();
          return;
        }
        final doc = await _db!.collection('users').doc(u.uid).get();
        _profile = doc.data();
        _role = _parseRole(_profile?['role'] as String?);
        _initializing = false;
        notifyListeners();
      });
    } catch (_) {
      _initializing = false;
      notifyListeners();
    }
  }

  AppRole? _parseRole(String? r) {
    switch (r) {
      case 'admin':
        return AppRole.admin;
      case 'user':
        return AppRole.user;
      default:
        return null;
    }
  }

  Future<String?> signIn(String email, String password) async {
    try {
      _auth ??= fb.FirebaseAuth.instance;
      await _auth!.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    String? phone,
    String? address,
  }) async {
    try {
      _auth ??= fb.FirebaseAuth.instance;
      _db ??= FirebaseFirestore.instance;
      final cred = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _db!.collection('users').doc(cred.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': 'user',
      });
      return null;
    } on fb.FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> signOut() async {
    _auth ??= fb.FirebaseAuth.instance;
    await _auth!.signOut();
  }
}
