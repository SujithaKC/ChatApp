import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String id;
  final String name;
  final List<String> members;
  final List<String> admins;
  final bool adminOnlyChat;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime? lastMessageTime;
  final DateTime? createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.members,
    required this.admins,
    required this.adminOnlyChat,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.lastMessageTime,
    this.createdAt,
  });

  factory GroupModel.fromMap(String id, Map<String, dynamic> data) {
    return GroupModel(
      id: id,
      name: data['name'] ?? 'Unnamed Group',
      members: List<String>.from(data['members'] ?? []),
      admins: List<String>.from(data['admins'] ?? []),
      adminOnlyChat: data['adminOnlyChat'] ?? false,
      lastMessage: data['lastMessage'] ?? '',
      lastMessageSenderId: data['lastMessageSenderId'] ?? '',
      lastMessageTime: data['lastMessageTime'] != null ? (data['lastMessageTime'] as Timestamp).toDate() : null,
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members,
      'admins': admins,
      'adminOnlyChat': adminOnlyChat,
      'lastMessage': lastMessage,
      'lastMessageSenderId': lastMessageSenderId,
      'lastMessageTime': lastMessageTime,
      'createdAt': createdAt,
    };
  }
}