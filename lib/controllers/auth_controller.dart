import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends ChangeNotifier {
  final AuthenticationService authService;

  AuthController({required this.authService});

  String? error;

  Future<void> login(String email, String password) async {
    try {
      error = null;
      await authService.login(email, password);
      notifyListeners();
    } on FirebaseAuthException catch (e) {
      error = e.message;
      notifyListeners();
    }
  }

Future<void> register(String email, String password, String name) async {
  try {
    final storageRef = FirebaseStorage.instance.ref();
    final credential = await authService.register(email, password);
    final user = credential.user;

    if (user != null) {
      // Set display name
      await user.updateDisplayName(name);
      await user.reload();
      final photoURL = await storageRef.getDownloadURL();
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'photoURL': photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    notifyListeners();
  } on FirebaseAuthException catch (e) {
    error = e.message;
    notifyListeners();
  }
}

  void logout() {
    authService.logout();
  }

  Stream<User?> get authState => authService.authState;

  User? get currentUser => authService.currentUser;
}
