import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  String? _errorMessage;
  bool _isLoading = false;

  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Sign up with email and password
      User? user = await _authService.signUp(email, password);
      if (user == null) {
        _errorMessage = 'Failed to create user. Please try again.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Send email verification
      await user.sendEmailVerification();

      // Update the user's display name
      await user.updateDisplayName(displayName);
      await user.reload();

      // Store user data in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'email': email,
        'displayName': displayName,
        'photoURL': '',
        'bio': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Sign out the user after sign-up to enforce email verification
      await _authService.signOut();

      _errorMessage = 'Sign-up successful! Verification email sent. Please verify your email.';
      _isLoading = false;
      notifyListeners();
      return false; // Return false because user needs to verify email before proceeding
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'email-already-in-use':
          errorMsg = 'Email is already in use. Please log in or verify your email.';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid email address';
          break;
        case 'weak-password':
          errorMsg = 'Password is too weak';
          break;
        default:
          errorMsg = 'Sign-up failed: ${e.message}';
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      User? user = await _authService.login(email, password);
      if (user == null) {
        _errorMessage = 'Login failed. Please check your credentials.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Check if email is verified
      await user.reload();
      user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await _authService.signOut();
        _errorMessage = 'Please verify your email. Verification email sent.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      String errorMsg;
      switch (e.code) {
        case 'user-not-found':
        case 'wrong-password':
          errorMsg = 'Invalid email or password';
          break;
        case 'invalid-email':
          errorMsg = 'Invalid email address';
          break;
        default:
          errorMsg = 'Login failed: ${e.message}';
      }
      _errorMessage = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
      _errorMessage = null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = 'Failed to send password reset email: ${e.message}';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
    }
    notifyListeners();
  }
}