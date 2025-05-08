import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// The `AuthController` class manages user authentication operations like login, registration, and
/// logout using Firebase services.
class AuthController extends ChangeNotifier {
  final AuthenticationService authService;

  AuthController({required this.authService});

  String? error;

  /// Logs in a user with the given email and password.
  ///
  /// Parameters:
  /// - [email]: The email address of the user.
  /// - [password]: The password for the user account.
  /// 
  /// Throws:
  /// - [FirebaseAuthException]: If an error occurs during the registration process.
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

  /// Registers a new user with the provided email, password, and name.
  ///
  /// Parameters:
  /// - [email]: The email address of the user to register.
  /// - [password]: The password for the new user account.
  /// - [name]: The display name of the user.
  ///
  /// Throws:
  /// - [FirebaseAuthException]: If an error occurs during the registration process.
  Future<void> register(String email, String password, String name) async {
    try {
      final credential = await authService.register(email, password);
      final user = credential.user;

      if (user != null) {
        const defaultPhotoURL =
            'https://firebasestorage.googleapis.com/v0/b/unicart-dbc61.firebasestorage.app/o/user_profiles%2Fdefault.png?alt=media&token=ba7e3f76-61ec-40b4-9d3e-e77cbabb80cc';
        await user.updateDisplayName(name);
        await user.updatePhotoURL(defaultPhotoURL);
        await user.reload();

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

  /// Logs the user out by calling the logout method from the authentication service.
  void logout() {
    authService.logout();
  }

  Stream<User?> get authState => authService.authState;
  User? get currentUser => authService.currentUser;
}
