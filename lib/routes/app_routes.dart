import 'package:chat_app/modules/main/main_screen.dart';
import 'package:flutter/material.dart';
import '../modules/auth/view/login_screen.dart';
import '../modules/auth/view/sign_up_screen.dart';
import '../modules/chat/view/chat_screen.dart';
import '../modules/chat/view/group_chat_screen.dart';
import '../modules/chat/view/group_create_screen.dart';
import '../modules/profile/view/friend_profile_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/sign-up';
  static const String main = '/main';
  static const String chat = '/chat';
  static const String groupChat = '/group-chat';
  static const String groupCreate = '/group-create';
  static const String friendProfile = '/friend-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case signUp:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());
      case chat:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: args['chatId'],
            friendId: args['friendId'],
          ),
        );
      case groupChat:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => GroupChatScreen(groupId: groupId),
        );
      case groupCreate:
        return MaterialPageRoute(builder: (_) => const GroupCreateScreen());
      case friendProfile:
        final friendId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => FriendProfileScreen(friendId: friendId),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainScreen());
    }
  }
}