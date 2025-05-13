// This file defines the `AppRoutes` class, which manages the app's navigation.
// It includes route names and a method to generate routes dynamically.

import 'package:chat_app/modules/main/main_screen.dart';
import 'package:flutter/material.dart';
import '../modules/auth/view/login_screen.dart';
import '../modules/auth/view/sign_up_screen.dart';
import '../modules/auth/view/forgot_password_screen.dart';
import '../modules/chat/view/chat_screen.dart';
import '../modules/chat/view/group_chat_screen.dart';
import '../modules/chat/view/group_create_screen.dart';
import '../modules/profile/view/friend_profile_screen.dart';

class AppRoutes {
  static const String login = '/login'; // Route for the login screen.
  static const String signUp = '/sign-up'; // Route for the sign-up screen.
  static const String main = '/main'; // Route for the main screen.
  static const String chat = '/chat'; // Route for the individual chat screen.
  static const String groupChat = '/group-chat'; // Route for the group chat screen.
  static const String groupCreate = '/group-create'; // Route for the group creation screen.
  static const String friendProfile = '/friend-profile'; // Route for the friend's profile screen.
  static const String forgotPassword = '/forgot-password'; // Route for the forgot password screen.

  static Route<dynamic> generateRoute(RouteSettings settings) { // Generates routes based on the route name and arguments.
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen()); // Navigates to the login screen.
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen()); // Navigates to the sign-up screen.
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen()); // Navigates to the main screen.
      case chat:
        final args = settings.arguments as Map<String, dynamic>; // Extracts chat arguments.
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'], // Passes the chat ID to the chat screen.
            friendId: args['friendId'], // Passes the friend's ID to the chat screen.
          ),
        );
      case groupChat:
        final groupId = settings.arguments as String; // Extracts the group ID.
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(groupId: groupId), // Navigates to the group chat screen.
        );
      case groupCreate:
        return MaterialPageRoute(builder: (_) => const GroupCreateScreen()); // Navigates to the group creation screen.
      case friendProfile:
        final friendId = settings.arguments as String; // Extracts the friend's ID.
        return MaterialPageRoute(
          builder: (_) => FriendProfileScreen(friendId: friendId), // Navigates to the friend's profile screen.
        );
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()); // Navigates to the forgot password screen.
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen()); // Default route to the main screen.
    }
  }
}