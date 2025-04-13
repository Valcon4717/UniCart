import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

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

  Future<void> register(String email, String password) async {
    try {
      error = null;
      await authService.register(email, password);
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