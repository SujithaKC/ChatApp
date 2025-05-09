import 'package:cloud_firestore/cloud_firestore.dart';

class ChatModel {
  final String id;
  final List<String> members;
  final String lastMessage;
  final DateTime? lastMessageTime;
  final String type;

  ChatModel({
    required this.id,
    required this.members,
    required this.lastMessage,
    this.lastMessageTime,
    required this.type,
  });

  factory ChatModel.fromMap(String id, Map<String, dynamic> data) {
    return ChatModel(
      id: id,
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null ? (data['lastMessageTime'] as Timestamp).toDate() : null,
      type: data['type'] ?? 'individual',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'members': members,
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime,
      'type': type,
    };
  }
}

class MessageModel {
  final String id;
  final String senderId;
  final String text;
  final DateTime? timestamp;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    this.timestamp,
  });

  factory MessageModel.fromMap(String id, Map<String, dynamic> data) {
    return MessageModel(
      id: id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: data['timestamp'] != null ? (data['timestamp'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp,
    };
  }
}