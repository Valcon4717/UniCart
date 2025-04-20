import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../views/home_screen.dart';
import '../views/landing_screen.dart';

/// The `AuthGate` class in Dart is a Flutter widget that conditionally displays either a `HomeScreen`
/// or a `LoginScreen` based on the user's authentication state.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to the authentication state changes
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return HomeScreen();
        } else {
          return LandingScreen();
        }
      },
    );
  }
}