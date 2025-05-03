import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
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
    final credential = await authService.register(email, password);
    final user = credential.user;
    
    if (user != null) {
      // Default profile image URL from your Firebase Storage
      const defaultPhotoURL = 'https://firebasestorage.googleapis.com/v0/b/unicart-dbc61.firebasestorage.app/o/user_profiles%2Fdefault.png?alt=media&token=ba7e3f76-61ec-40b4-9d3e-e77cbabb80cc';
      
      // Set display name
      await user.updateDisplayName(name);
      
      // Set profile photo
      await user.updatePhotoURL(defaultPhotoURL);
      await user.reload();
      
      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'photoURL': defaultPhotoURL,
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
