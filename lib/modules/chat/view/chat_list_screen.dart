// This file defines the ChatListScreen, which displays a list of chats (individual or group) based on the selected chat type.
// It uses providers for state management and RxDart for combining streams of individual and group chats.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/chat_model.dart';
import '../../../models/group_model.dart';
import '../../../models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../viewmodel/group_chat_viewmodel.dart';
import 'chat_screen.dart';
import 'group_chat_screen.dart';
import 'group_create_screen.dart';

class ChatListScreen extends StatefulWidget {
  // Represents the type of chat to display (e.g., 'individual', 'group', or 'all').
  final String chatType;

  const ChatListScreen({Key? key, required this.chatType}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Controller for the search input field.
  final _searchController = TextEditingController();
  // Controller for the email input field when adding a new friend.
  final _newFriendEmailController = TextEditingController();
  // Stores the current search query.
  String _searchQuery = '';

  @override
  void dispose() {
    // Dispose controllers to free resources.
    _searchController.dispose();
    _newFriendEmailController.dispose();
    super.dispose();
  }

  // Formats a timestamp into a readable string (e.g., 'HH:mm' for today or 'DD/MM' for other days).
  String _formatTimestamp(DateTime? dateTime) {
    if (dateTime == null) return '';
    final now = DateTime.now();
    if (dateTime.day == now.day && dateTime.month == now.month && dateTime.year == now.year) {
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
    return '${dateTime.day}/${dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    // Determine the current theme mode (dark or light).
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return MultiProvider(
      providers: [
        // Provide instances of ChatViewModel and GroupChatViewModel for state management.
        ChangeNotifierProvider(create: (_) => ChatViewModel()),
        ChangeNotifierProvider(create: (_) => GroupChatViewModel()),
      ],
      child: Builder(
        builder: (context) {
          // Access the view models for chat and group chat.
          final chatViewModel = Provider.of<ChatViewModel>(context);
          final groupChatViewModel = Provider.of<GroupChatViewModel>(context);

          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false, // Remove the back button from the app bar.
              // Display the title based on the chat type.
              title: Text(
                widget.chatType == 'all'
                    ? 'All Chats'
                    : widget.chatType == 'individual'
                        ? 'Individual Chats'
                        : 'Group Chats',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              actions: [
                // Add friend or group based on the chat type.
                if (widget.chatType == 'individual')
                  IconButton(
                    icon: const Icon(Icons.person_add),
                    onPressed: () => _showAddFriendDialog(context, chatViewModel, isDarkMode),
                  ),
                if (widget.chatType != 'individual')
                  IconButton(
                    icon: const Icon(Icons.group_add),
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.groupCreate),
                  ),
              ],
            ),
            body: Column(
              children: [
                // Search bar for filtering chats.
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search ${widget.chatType == 'all' ? 'Chats' : widget.chatType == 'individual' ? 'Friends' : 'Groups'}',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.toLowerCase();
                      });
                    },
                  ),
                ),
                // Display error messages if any.
                if (chatViewModel.errorMessage != null || groupChatViewModel.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      chatViewModel.errorMessage ?? groupChatViewModel.errorMessage!,
                      style: TextStyle(color: isDarkMode ? AppColors.darkError : AppColors.lightError),
                    ),
                  ),
                // Display the list of chats.
                Expanded(
                  child: _buildChatList(context, chatViewModel, groupChatViewModel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Show a dialog to add a new friend.
  void _showAddFriendDialog(BuildContext context, ChatViewModel chatViewModel, bool isDarkMode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(
          'Add New Friend',
          style: TextStyle(
            color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
        ),
        content: TextField(
          controller: _newFriendEmailController,
          decoration: InputDecoration(
            labelText: 'Friend Email',
            labelStyle: TextStyle(
              color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
            ),
          ),
          style: TextStyle(
            color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              await chatViewModel.startChat(_newFriendEmailController.text);
              if (chatViewModel.errorMessage != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(chatViewModel.errorMessage!)),
                );
              } else {
                Navigator.pop(context); // Close the dialog
                Navigator.pushNamed(
                  context,
                  AppRoutes.chat,
                  arguments: {
                    'chatId': chatViewModel.chats.last.id,
                    'friendId': chatViewModel.users.last.id,
                  },
                );
              }
              _newFriendEmailController.clear();
            },
            child: Text(
              'Start Chat',
              style: TextStyle(
                color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build the list of chats based on the chat type.
  Widget _buildChatList(BuildContext context, ChatViewModel chatViewModel, GroupChatViewModel groupChatViewModel) {
    if (widget.chatType == 'individual') {
      return StreamBuilder<List<ChatModel>>(
        stream: chatViewModel.getChats('individual'),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final chats = snapshot.data!;
          if (chats.isEmpty) {
            return Center(child: Text('No chats found', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final friendId = chat.members.firstWhere((id) => id != FirebaseAuth.instance.currentUser!.uid, orElse: () => '');
              if (friendId.isEmpty) return const SizedBox.shrink();
              return StreamBuilder<UserModel>(
                stream: chatViewModel.getUser(friendId),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();
                  if (userSnapshot.hasError) return const ListTile(title: Text('Error loading user'));
                  final user = userSnapshot.data!;
                  if (_searchQuery.isNotEmpty &&
                      !user.displayName.toLowerCase().contains(_searchQuery) &&
                      !user.email.toLowerCase().contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user.displayName.isNotEmpty ? user.displayName.substring(0, 1) : '?'),
                    ),
                    title: Text(user.displayName, style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(
                      chat.lastMessage,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Text(
                      _formatTimestamp(chat.lastMessageTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => Navigator.pushNamed(
                      context,
                      AppRoutes.chat,
                      arguments: {'chatId': chat.id, 'friendId': friendId},
                    ),
                  );
                },
              );
            },
          );
        },
      );
    } else if (widget.chatType == 'group') {
      return StreamBuilder<List<GroupModel>>(
        stream: groupChatViewModel.getGroups(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final groups = snapshot.data!;
          if (groups.isEmpty) {
            return Center(child: Text('No groups found', style: Theme.of(context).textTheme.bodyMedium));
          }
          final filteredGroups = groups
              .where((group) =>
                  _searchQuery.isEmpty || group.name.toLowerCase().contains(_searchQuery))
              .toList();
          if (filteredGroups.isEmpty) {
            return Center(child: Text('No matching groups found', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView.builder(
            itemCount: filteredGroups.length,
            itemBuilder: (context, index) {
              final group = filteredGroups[index];
              return StreamBuilder<UserModel>(
                stream: group.lastMessageSenderId.isNotEmpty
                    ? groupChatViewModel.getUser(group.lastMessageSenderId)
                    : Stream.value(UserModel(id: '', email: '', displayName: '', bio: '', photoURL: '')),

                builder: (context, userSnapshot) {
                  String lastMessageText = group.lastMessage;
                  if (userSnapshot.hasData && group.lastMessage.isNotEmpty) {
                    final senderName = userSnapshot.data!.displayName;
                    lastMessageText = '$senderName: ${group.lastMessage}';
                  }
                  return ListTile(
                    leading: CircleAvatar(child: Text(group.name.isNotEmpty ? group.name.substring(0, 1) : '?')),
                    title: Text(group.name, style: Theme.of(context).textTheme.bodyMedium),
                    subtitle: Text(
                      '${group.members.length} members | $lastMessageText',
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Text(
                      _formatTimestamp(group.lastMessageTime),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    onTap: () => Navigator.pushNamed(context, AppRoutes.groupChat, arguments: group.id),
                  );
                },
              );
            },
          );
        },
      );
    } else {
      return StreamBuilder<List<dynamic>>(
        stream: _combineChatsAndGroups(chatViewModel, groupChatViewModel),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: Theme.of(context).textTheme.bodyMedium));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final allChats = snapshot.data!;
          if (allChats.isEmpty) {
            return Center(child: Text('No chats found', style: Theme.of(context).textTheme.bodyMedium));
          }
          final filteredChats = allChats.where((chat) {
            if (chat is GroupModel) {
              return _searchQuery.isEmpty || chat.name.toLowerCase().contains(_searchQuery);
            }
            return true;
          }).toList();
          if (filteredChats.isEmpty) {
            return Center(child: Text('No matching chats found', style: Theme.of(context).textTheme.bodyMedium));
          }
          return ListView.builder(
            itemCount: filteredChats.length,
            itemBuilder: (context, index) {
              final chat = filteredChats[index];
              if (chat is ChatModel) {
                final friendId = chat.members.firstWhere((id) => id != FirebaseAuth.instance.currentUser!.uid, orElse: () => '');
                if (friendId.isEmpty) return const SizedBox.shrink();
                return StreamBuilder<UserModel>(
                  stream: chatViewModel.getUser(friendId),
                  builder: (context, userSnapshot) {
                    if (!userSnapshot.hasData) return const SizedBox.shrink();
                    if (userSnapshot.hasError) return const ListTile(title: Text('Error loading user'));
                    final user = userSnapshot.data!;
                    if (_searchQuery.isNotEmpty &&
                        !user.displayName.toLowerCase().contains(_searchQuery) &&
                        !user.email.toLowerCase().contains(_searchQuery)) {
                      return const SizedBox.shrink();
                    }
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(user.displayName.isNotEmpty ? user.displayName.substring(0, 1) : '?'),
                      ),
                      title: Text(user.displayName, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(
                        chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        _formatTimestamp(chat.lastMessageTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.chat,
                        arguments: {'chatId': chat.id, 'friendId': friendId},
                      ),
                    );
                  },
                );
              } else if (chat is GroupModel) {
                return StreamBuilder<UserModel>(
                  stream: chat.lastMessageSenderId.isNotEmpty
                      ? groupChatViewModel.getUser(chat.lastMessageSenderId)
                      : Stream.value(UserModel(id: '', email: '', displayName: '', bio: '', photoURL: '')),

                  builder: (context, userSnapshot) {
                    String lastMessageText = chat.lastMessage;
                    if (userSnapshot.hasData && chat.lastMessage.isNotEmpty) {
                      final senderName = userSnapshot.data!.displayName;
                      lastMessageText = '$senderName: ${chat.lastMessage}';
                    }
                    return ListTile(
                      leading: CircleAvatar(child: Text(chat.name.isNotEmpty ? chat.name.substring(0, 1) : '?')),

                      title: Text(chat.name, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(
                        '${chat.members.length} members | $lastMessageText',
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        _formatTimestamp(chat.lastMessageTime),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () => Navigator.pushNamed(context, AppRoutes.groupChat, arguments: chat.id),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          );
        },
      );
    }
  }

  // Combine individual and group chat streams into a single stream.
  Stream<List<dynamic>> _combineChatsAndGroups(ChatViewModel chatViewModel, GroupChatViewModel groupChatViewModel) {
    final individualChatsStream = chatViewModel.getChats('individual');
    final groupChatsStream = groupChatViewModel.getGroups();

    return Rx.combineLatest2<List<ChatModel>, List<GroupModel>, List<dynamic>>(
      individualChatsStream,
      groupChatsStream,
      (individualChats, groupChats) {
        final allChats = [...individualChats, ...groupChats];
        allChats.sort((a, b) {
          DateTime aTime = DateTime.fromMillisecondsSinceEpoch(0);
          DateTime bTime = DateTime.fromMillisecondsSinceEpoch(0);

          if (a is ChatModel) {
            aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          } else if (a is GroupModel) {
            aTime = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          }

          if (b is ChatModel) {
            bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          } else if (b is GroupModel) {
            bTime = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
          }

          return bTime.compareTo(aTime);
        });
        return allChats;
      },
    ).onErrorReturnWith((error, stackTrace) {
      debugPrint('Error in combineChatsAndGroups: $error');
      return [];
    });
  }
}