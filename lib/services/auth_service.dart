import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> register(String email, String password) {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Stream<User?> get authState => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;
}