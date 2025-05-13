import 'package:chat_app/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/group_model.dart';
import '../../../models/user_model.dart';

// This file contains the GroupChatViewModel class, which manages the state and logic for group chat-related operations.

// Importing necessary packages and models.
// These include Firebase services, Flutter utilities, and custom models for groups, chats, and users.

class GroupChatViewModel extends ChangeNotifier {
  // Private variables to store error messages and admin-only chat state.
  String? _errorMessage; // Stores error messages to be displayed in the UI.
  bool _adminOnlyChat = false; // Indicates whether the chat is restricted to admins only.

  // Public getters to access private variables.
  String? get errorMessage => _errorMessage; // Getter for error messages.
  bool get adminOnlyChat => _adminOnlyChat; // Getter for admin-only chat state.

  // Method to create a new group with a given name and list of members.
  Future<void> createGroup(String groupName, List<String> members) async {
    // Validate group name.
    if (groupName.trim().isEmpty) {
      _errorMessage = 'Group name is required';
      notifyListeners(); // Notify listeners about the state change.
      return;
    }
    try {
      // Generate a unique group ID and save group details to Firestore.
      final groupId = const Uuid().v4();
      await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
        'name': groupName.trim(),
        'members': [FirebaseAuth.instance.currentUser!.uid, ...members],
        'admins': [FirebaseAuth.instance.currentUser!.uid],
        'adminOnlyChat': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to create group: $e';
      notifyListeners();
    }
  }

  // Method to send a message in a group chat.
  Future<void> sendMessage(String groupId, String text) async {
    // Validate message text.
    if (text.trim().isEmpty) return;
    try {
      // Create a message object and save it to Firestore.
      final message = {
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .add(message);
      // Update group details with the last message info.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'lastMessage': text.trim(),
        'lastMessageSenderId': FirebaseAuth.instance.currentUser!.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  // Method to toggle the admin-only chat setting for a group.
  Future<void> toggleAdminOnlyChat(String groupId) async {
    try {
      // Fetch the current admin-only chat setting from Firestore.
      final groupSnapshot = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupSnapshot.exists) {
        _errorMessage = 'Group not found';
        notifyListeners();
        return;
      }
      final currentAdminOnlyChat = groupSnapshot.data()?['adminOnlyChat'] ?? false;

      // Update the admin-only chat setting in Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'adminOnlyChat': !currentAdminOnlyChat,
      });

      // Update the local state.
      _adminOnlyChat = !currentAdminOnlyChat;
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to update chat settings: $e';
      notifyListeners();
    }
  }

  // Method to remove a member from a group.
  Future<void> removeMember(String groupId, String memberId) async {
    try {
      // Update the group's member and admin lists in Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([memberId]),
        'admins': FieldValue.arrayRemove([memberId]),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to remove member: $e';
      notifyListeners();
    }
  }

  // Method to promote a member to admin in a group.
  Future<void> makeAdmin(String groupId, String memberId) async {
    try {
      // Add the member to the admin list in Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayUnion([memberId]),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to make admin: $e';
      notifyListeners();
    }
  }

  // Method to demote an admin to a regular member in a group.
  Future<void> removeAdmin(String groupId, String memberId) async {
    try {
      // Remove the member from the admin list in Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayRemove([memberId]),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to remove admin: $e';
      notifyListeners();
    }
  }

  // Method to delete a group and its messages.
  Future<void> deleteGroup(String groupId) async {
    try {
      // Delete all messages in the group.
      final messages = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
      // Delete the group document from Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to delete group: $e';
      notifyListeners();
    }
  }

  // Method to add a new member to a group using their email.
  Future<void> addMember(String groupId, String email) async {
    // Validate email input.
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter an email';
      notifyListeners();
      return;
    }
    try {
      // Check if the user exists in Firestore.
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (snapshot.docs.isEmpty) {
        _errorMessage = 'User not found';
        notifyListeners();
        return;
      }
      final memberId = snapshot.docs.first.id;
      // Check if the group exists and the user is not already a member.
      final groupSnapshot = await FirebaseFirestore.instance.collection('groups').doc(groupId).get();
      if (!groupSnapshot.exists) {
        _errorMessage = 'Group not found';
        notifyListeners();
        return;
      }
      final groupData = groupSnapshot.data() as Map<String, dynamic>;
      final members = groupData.containsKey('members') ? List<String>.from(groupData['members']) : [];
      if (members.contains(memberId)) {
        _errorMessage = 'User already in group';
        notifyListeners();
        return;
      }
      // Add the user to the group's member list in Firestore.
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([memberId]),
      });
      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to add member: $e';
      notifyListeners();
    }
  }

  // Stream to fetch all groups the current user is a member of.
  Stream<List<GroupModel>> getGroups() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromMap(doc.id, doc.data())).toList());
  }

  // Stream to fetch details of a specific group by its ID.
  Stream<GroupModel> getGroup(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((snapshot) => GroupModel.fromMap(groupId, snapshot.data() as Map<String, dynamic>));
  }

  // Stream to fetch all messages in a specific group chat.
  Stream<List<MessageModel>> getGroupMessages(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromMap(doc.id, doc.data())).toList());
  }

  // Stream to fetch details of a specific user by their ID.
  Stream<UserModel> getUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(userId, snapshot.data() as Map<String, dynamic>));
  }

  // Method to set the admin-only chat state locally.
  void setAdminOnlyChat(bool value) {
    _adminOnlyChat = value;
    notifyListeners();
  }

  // Method to clear the error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}