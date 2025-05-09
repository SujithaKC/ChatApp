import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';

class ChatViewModel extends ChangeNotifier {
  final List<ChatModel> _chats = [];
  final List<UserModel> _users = [];
  String? _errorMessage;

  List<ChatModel> get chats => _chats;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;

  Future<void> startChat(String friendEmail) async {
    try {
      _errorMessage = null;
      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();
      if (friendSnapshot.docs.isEmpty) {
        _errorMessage = 'User not found';
        notifyListeners();
        return;
      }

      final friendId = friendSnapshot.docs.first.id;
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final chatSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .where('members', arrayContains: currentUserId)
          .get();

      String? existingChatId;
      for (var doc in chatSnapshot.docs) {
        final members = List<String>.from(doc['members']);
        if (members.contains(friendId) && members.length == 2) {
          existingChatId = doc.id;
          break;
        }
      }

      if (existingChatId != null) {
        notifyListeners();
        return;
      }

      final chatId = const Uuid().v4();
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'members': [currentUserId, friendId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'type': 'individual',
      });

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to start chat: $e';
      notifyListeners();
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;
    try {
      final message = {
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message);
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  Stream<List<ChatModel>> getChats(String type) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return FirebaseFirestore.instance
        .collection('chats')
        .where('members', arrayContains: currentUserId)
        .where('type', isEqualTo: type)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatModel.fromMap(doc.id, doc.data())).toList());
  }

  Stream<List<MessageModel>> getMessages(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
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
}