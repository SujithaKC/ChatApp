import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../models/chat_model.dart';
import '../../../models/user_model.dart';

// ChatViewModel is responsible for managing chat-related operations, such as starting chats, sending messages, and retrieving chat data.
class ChatViewModel extends ChangeNotifier {
  // Private lists to store chats and users.
  final List<ChatModel> _chats = [];
  final List<UserModel> _users = [];

  // Private variable to store error messages.
  String? _errorMessage;

  // Public getters to access private variables.
  List<ChatModel> get chats => _chats;
  List<UserModel> get users => _users;
  String? get errorMessage => _errorMessage;

  // Starts a chat with a specific user identified by their email.
  Future<void> startChat(String friendEmail) async {
    try {
      _errorMessage = null; // Reset error message.

      // Fetch the friend's user document from Firestore.
      final friendSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: friendEmail)
          .get();

      // If no user is found, set an error message and notify listeners.
      if (friendSnapshot.docs.isEmpty) {
        _errorMessage = 'User not found';
        notifyListeners();
        return;
      }

      // Extract the friend's user ID and the current user's ID.
      final friendId = friendSnapshot.docs.first.id;
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Check if a chat already exists between the two users.
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

      // If a chat already exists, notify listeners and return.
      if (existingChatId != null) {
        notifyListeners();
        return;
      }

      // Create a new chat document in Firestore.
      final chatId = const Uuid().v4();
      await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
        'members': [currentUserId, friendId],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'type': 'individual',
      });

      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to start chat: $e';
      notifyListeners();
    }
  }

  // Sends a message in a specific chat.
  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return; // Do nothing if the message is empty.
    try {
      // Create a message object.
      final message = {
        'senderId': FirebaseAuth.instance.currentUser!.uid,
        'text': text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add the message to the chat's messages collection in Firestore.
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message);

      // Update the chat document with the last message and timestamp.
      await FirebaseFirestore.instance.collection('chats').doc(chatId).update({
        'lastMessage': text.trim(),
        'lastMessageTime': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      // Handle errors and notify listeners.
      _errorMessage = 'Failed to send message: $e';
      notifyListeners();
    }
  }

  // Retrieves a stream of chats for the current user filtered by type (e.g., individual or group).
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

  // Retrieves a stream of messages for a specific chat.
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

  // Retrieves a stream of user data for a specific user ID.
  Stream<UserModel> getUser(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) => UserModel.fromMap(userId, snapshot.data() as Map<String, dynamic>));
  }
}