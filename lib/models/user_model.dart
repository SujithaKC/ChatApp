import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String displayName;
  final String bio;
  final String photoURL;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.displayName,
    required this.bio,
    required this.photoURL,
    this.createdAt,
  });

  factory UserModel.fromMap(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'] ?? '',
      photoURL: data['photoURL'] ?? '',
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'bio': bio,
      'photoURL': photoURL,
      'createdAt': createdAt,
    };
  }
}