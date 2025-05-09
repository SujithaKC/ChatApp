import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../models/user_model.dart';

class ProfileViewModel extends ChangeNotifier {
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  Future<void> fetchUser(String userId) async {
    try {
      setLoading(true);
      final snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (snapshot.exists) {
        _user = UserModel.fromMap(userId, snapshot.data() as Map<String, dynamic>);
      } else {
        _errorMessage = 'User not found';
      }
      setLoading(false);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch user: $e';
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> updateProfile(String displayName, String bio) async {
    if (displayName.trim().isEmpty) {
      _errorMessage = 'Display name cannot be empty';
      notifyListeners();
      return;
    }
    try {
      setLoading(true);
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'displayName': displayName.trim(),
        'bio': bio.trim(),
      });
      await fetchUser(userId); // Refresh user data
      setLoading(false);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      setLoading(false);
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}