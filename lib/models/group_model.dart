// This file defines the `GroupModel` class, which represents a group chat entity.
// It includes methods for converting between Dart objects and Firestore data.

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

  factory GroupModel.fromMap(String id, Map<String, dynamic> data) { // Creates a GroupModel instance from Firestore data.
    return GroupModel(
      id: id,
      name: data['name'] ?? 'Unnamed Group', // Retrieves the group name or defaults to 'Unnamed Group'.
      members: List<String>.from(data['members'] ?? []), // Retrieves the list of group members.
      admins: List<String>.from(data['admins'] ?? []), // Retrieves the list of group admins.
      adminOnlyChat: data['adminOnlyChat'] ?? false, // Indicates if only admins can chat.
      lastMessage: data['lastMessage'] ?? '', // Retrieves the last message in the group.
      lastMessageSenderId: data['lastMessageSenderId'] ?? '', // Retrieves the sender ID of the last message.
      lastMessageTime: data['lastMessageTime'] != null ? (data['lastMessageTime'] as Timestamp).toDate() : null, // Converts Firestore timestamp to DateTime.
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null, // Converts Firestore timestamp to DateTime.
    );
  }

  Map<String, dynamic> toMap() { // Converts a GroupModel instance to a Firestore-compatible map.
    return {
      'name': name, // Stores the group name.
      'members': members, // Stores the list of group members.
      'admins': admins, // Stores the list of group admins.
      'adminOnlyChat': adminOnlyChat, // Indicates if only admins can chat.
      'lastMessage': lastMessage, // Stores the last message in the group.
      'lastMessageSenderId': lastMessageSenderId, // Stores the sender ID of the last message.
      'lastMessageTime': lastMessageTime, // Converts DateTime to Firestore timestamp.
      'createdAt': createdAt, // Converts DateTime to Firestore timestamp.
    };
  }
}