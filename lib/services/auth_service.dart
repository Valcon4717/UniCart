import 'package:firebase_auth/firebase_auth.dart';

/// Provides authentication services using Firebase.
/// with [FirebaseAuth].
///
/// Properties:
/// - [authState]: A stream that emits authentication state changes, such as
///   when a user logs in or logs out.
/// - [currentUser]: The currently authenticated user, or `null` if no user is
///   logged in.
///
/// Methods:
/// - [login]: Logs in a user with the provided email and password.
/// - [register]: Registers a new user with the provided email and password.
/// - [logout]: Logs out the currently authenticated user.

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}
