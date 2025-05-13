import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance; // Instance of FirebaseAuth to handle authentication.

  Future<User?> signUp(String email, String password) async {
    // Signs up a new user with email and password.
    UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(), // Trims whitespace from the email.
      password: password.trim(), // Trims whitespace from the password.
    );
    return userCredential.user; // Returns the created user.
  }

  Future<User?> login(String email, String password) async {
    // Logs in an existing user with email and password.
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: email.trim(), // Trims whitespace from the email.
      password: password.trim(), // Trims whitespace from the password.
    );
    return userCredential.user; // Returns the logged-in user.
  }

  Future<void> signOut() async {
    // Signs out the current user.
    await _auth.signOut();
  }

  User? getCurrentUser() {
    // Retrieves the currently logged-in user.
    return _auth.currentUser;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Sends a password reset email to the provided email address.
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}