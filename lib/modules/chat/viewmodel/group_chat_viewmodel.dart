import 'package:chat_app/models/chat_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/group_model.dart';
import '../../../models/user_model.dart';

class GroupChatViewModel extends ChangeNotifier {
  String? _errorMessage;
  bool _adminOnlyChat = false;

  String? get errorMessage => _errorMessage;
  bool get adminOnlyChat => _adminOnlyChat;

  Future<void> createGroup(String groupName, List<String> members) async {
    if (groupName.trim().isEmpty) {
      _errorMessage = 'Group name is required';
      notifyListeners();
      return;
    }
    try {
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
      _errorMessage = 'Failed to create group: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String groupId, String text) async {
    if (text.trim().isEmpty) return;
    try {
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
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'lastMessage': text.trim(),
        'lastMessageSenderId': FirebaseAuth.instance.currentUser!.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Future<void> toggleAdminOnlyChat(String groupId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'adminOnlyChat': !_adminOnlyChat,
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update chat settings: $e';
      notifyListeners();
    }
  }

  Future<void> removeMember(String groupId, String memberId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayRemove([memberId]),
        'admins': FieldValue.arrayRemove([memberId]),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove member: $e';
      notifyListeners();
    }
  }

  Future<void> makeAdmin(String groupId, String memberId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayUnion([memberId]),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to make admin: $e';
      notifyListeners();
    }
  }

  Future<void> removeAdmin(String groupId, String memberId) async {
    try {
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'admins': FieldValue.arrayRemove([memberId]),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to remove admin: $e';
      notifyListeners();
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      final messages = await FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('messages')
          .get();
      for (var doc in messages.docs) {
        await doc.reference.delete();
      }
      await FirebaseFirestore.instance.collection('groups').doc(groupId).delete();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete group: $e';
      notifyListeners();
    }
  }

  Future<void> addMember(String groupId, String email) async {
    if (email.trim().isEmpty) {
      _errorMessage = 'Please enter an email';
      notifyListeners();
      return;
    }
    try {
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
      await FirebaseFirestore.instance.collection('groups').doc(groupId).update({
        'members': FieldValue.arrayUnion([memberId]),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add member: $e';
      notifyListeners();
    }
  }

  Stream<List<GroupModel>> getGroups() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => GroupModel.fromMap(doc.id, doc.data())).toList());
  }

  Stream<GroupModel> getGroup(String groupId) {
    return FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .snapshots()
        .map((snapshot) => GroupModel.fromMap(groupId, snapshot.data() as Map<String, dynamic>));
  }

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

  Stream<UserModel> getUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(userId, snapshot.data() as Map<String, dynamic>));
  }

  void setAdminOnlyChat(bool value) {
    _adminOnlyChat = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}