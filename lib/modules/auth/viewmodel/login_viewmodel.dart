// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import '../../../models/user_model.dart';

// class LoginViewModel extends ChangeNotifier {
//   String? _errorMessage;
//   bool _isLoading = false;

//   String? get errorMessage => _errorMessage;
//   bool get isLoading => _isLoading;

//   Future<bool> login(String email, String password) async {
//     try {
//       setLoading(true);
//       _errorMessage = null;

//       final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       final user = userCredential.user;
//       if (user != null) {
//         if (!user.emailVerified) {
//           await user.sendEmailVerification();
//           _errorMessage = 'Please verify your email. Verification email sent.';
//           await FirebaseAuth.instance.signOut();
//           setLoading(false);
//           notifyListeners();
//           return false;
//         }
//         setLoading(false);
//         notifyListeners();
//         return true;
//       }
//       return false;
//     } on FirebaseAuthException catch (e) {
//       String errorMsg;
//       switch (e.code) {
//         case 'invalid-email':
//           errorMsg = 'Invalid email address';
//           break;
//         case 'user-not-found':
//         case 'wrong-password':
//           errorMsg = 'Invalid email or password';
//           break;
//         default:
//           errorMsg = 'Authentication failed: ${e.message}';
//       }
//       _errorMessage = errorMsg;
//       setLoading(false);
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _errorMessage = 'Unexpected error: ${e.toString()}';
//       setLoading(false);
//       notifyListeners();
//       return false;
//     }
//   }

//   Future<bool> signUp(String email, String password, String displayName) async {
//     try {
//       setLoading(true);
//       _errorMessage = null;

//       if (displayName.trim().isEmpty) {
//         _errorMessage = 'Display name is required';
//         setLoading(false);
//         notifyListeners();
//         return false;
//       }

//       try {
//         final existingUserCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//           email: email.trim(),
//           password: password.trim(),
//         );
//         final existingUser = existingUserCredential.user;
//         if (existingUser != null) {
//           if (!existingUser.emailVerified) {
//             await existingUser.sendEmailVerification();
//             _errorMessage = 'User exists but email is not verified. Verification email sent.';
//             await FirebaseAuth.instance.signOut();
//             setLoading(false);
//             notifyListeners();
//             return false;
//           } else {
//             setLoading(false);
//             notifyListeners();
//             return true; // User exists and is verified, treat as login
//           }
//         }
//       } on FirebaseAuthException catch (e) {
//         if (e.code != 'user-not-found' && e.code != 'wrong-password') {
//           _errorMessage = 'Error checking user: ${e.message}';
//           setLoading(false);
//           notifyListeners();
//           return false;
//         }
//       }

//       final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
//         email: email.trim(),
//         password: password.trim(),
//       );
//       final user = userCredential.user;
//       if (user != null) {
//         await user.sendEmailVerification();
//         await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
//           'email': email.trim(),
//           'displayName': displayName.trim(),
//           'photoURL': '',
//           'bio': '',
//           'createdAt': FieldValue.serverTimestamp(),
//         });

//         _errorMessage = 'Sign-up successful! Verification email sent. Please verify your email.';
//         await FirebaseAuth.instance.signOut();

//         setLoading(false);
//         notifyListeners();
//         return false; // Sign-up successful but needs verification
//       }
//       return false;
//     } on FirebaseAuthException catch (e) {
//       String errorMsg;
//       switch (e.code) {
//         case 'email-already-in-use':
//           errorMsg = 'Email is already in use. Please log in or verify your email.';
//           break;
//         case 'invalid-email':
//           errorMsg = 'Invalid email address';
//           break;
//         case 'weak-password':
//           errorMsg = 'Password is too weak';
//           break;
//         default:
//           errorMsg = 'Authentication failed: ${e.message}';
//       }
//       _errorMessage = errorMsg;
//       setLoading(false);
//       notifyListeners();
//       return false;
//     } catch (e) {
//       _errorMessage = 'Unexpected error: ${e.toString()}';
//       setLoading(false);
//       notifyListeners();
//       return false;
//     }
//   }

//   void setLoading(bool value) {
//     _isLoading = value;
//     notifyListeners();
//   }

//   void clearError() {
//     _errorMessage = null;
//     notifyListeners();
//   }
// }

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
}