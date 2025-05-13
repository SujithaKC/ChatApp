import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier { // ViewModel to manage user profile-related operations.
  UserModel? _user; // Stores the current user's profile data.
  String? _errorMessage; // Stores error messages, if any.
  bool _isLoading = false; // Indicates whether a loading operation is in progress.

  UserModel? get user => _user; // Getter for the user's profile data.
  String? get errorMessage => _errorMessage; // Getter for the error message.
  bool get isLoading => _isLoading; // Getter for the loading state.

  Future<void> fetchUser(String userId) async { // Fetches user data from Firestore by user ID.
    try {
      setLoading(true); // Sets loading state to true.
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get(); // Retrieves user document.
      if (snapshot.exists) {
        _user = UserModel.fromMap(userId, snapshot.data() as Map<String, dynamic>); // Maps Firestore data to UserModel.
      } else {
        _errorMessage = 'User not found'; // Sets error message if user does not exist.
      }
      setLoading(false); // Sets loading state to false.
      notifyListeners(); // Notifies listeners about state changes.
    } catch (e) {
      _errorMessage = 'Failed to fetch user: $e'; // Sets error message in case of an exception.
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateProfile(String displayName, String bio) async { // Updates the user's profile data.
    if (displayName.trim().isEmpty) { // Validates that the display name is not empty.
      _errorMessage = 'Display name cannot be empty';
      notifyListeners();
      return;
    }
    try {
      setLoading(true);
      final userId = FirebaseAuth.instance.currentUser!.uid; // Gets the current user's ID.
      await FirebaseFirestore.instance.collection('users').doc(userId).update({ // Updates Firestore document.
        'displayName': displayName.trim(),
        'bio': bio.trim(),
      });
      await fetchUser(userId); // Refreshes user data after update.
      setLoading(false);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e'; // Sets error message in case of an exception.
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signOut() async { // Signs out the current user.
    try {
      await FirebaseAuth.instance.signOut(); // Calls Firebase sign-out method.
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e'; // Sets error message in case of an exception.
      notifyListeners();
    }
  }

  void setLoading(bool value) { // Sets the loading state.
    _isLoading = value;
    notifyListeners();
  }

  void clearError() { // Clears the error message.
    _errorMessage = null;
    notifyListeners();
  }
}