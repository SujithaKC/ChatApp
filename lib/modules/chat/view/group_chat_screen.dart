// This file defines the `GroupChatScreen` class, which provides the user interface for group chats.
// It includes message input, display, and sending functionality for group conversations.

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/chat_model.dart';
import '../viewmodel/group_chat_viewmodel.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId; // The ID of the group chat to display.

  const GroupChatScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController(); // Controller for the message input field.
  final _scrollController = ScrollController(); // Controller for scrolling the message list.
  final _memberEmailController = TextEditingController(); // Controller for the email input field when adding members.

  @override
  void dispose() {
    _messageController.dispose(); // Dispose of the message controller to free resources.
    _scrollController.dispose(); // Dispose of the scroll controller to free resources.
    _memberEmailController.dispose(); // Dispose of the email input controller to free resources.
    super.dispose();
  }

  // Formats a timestamp into a readable string (e.g., "HH:mm" for today or "DD/MM" for other days).
  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    if (timestamp.day == now.day && timestamp.month == now.month && timestamp.year == now.year) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
    return '${timestamp.day}/${timestamp.month}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode; // Check if the app is in dark mode.
    return ChangeNotifierProvider(
      create: (_) => GroupChatViewModel(), // Provide a GroupChatViewModel instance to the widget tree.
      child: Consumer<GroupChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              // Display the group's name in the app bar using a StreamBuilder.
              title: StreamBuilder(
                stream: viewModel.getGroup(widget.groupId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Group Chat');
                  final group = snapshot.data!;
                  return Text(group.name);
                },
              ),
              actions: [
                // Open group settings when the settings icon is tapped.
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => StreamBuilder(
                      stream: viewModel.getGroup(widget.groupId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final group = snapshot.data!;
                        final isAdmin = group.admins.contains(FirebaseAuth.instance.currentUser!.uid); // Check if the current user is an admin.
                        viewModel.setAdminOnlyChat(group.adminOnlyChat); // Set the admin-only chat state.
                        return AlertDialog(
                          title: Text(
                            'Group Settings',
                            style: TextStyle(
                              color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                            ),
                          ),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isAdmin)
                                  SwitchListTile(
                                    title: Text(
                                      'Admin Only Chat',
                                      style: TextStyle(
                                        color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                      ),
                                    ),
                                    value: viewModel.adminOnlyChat,
                                    onChanged: (value) => viewModel.toggleAdminOnlyChat(widget.groupId), // Toggle admin-only chat.
                                    activeColor: AppColors.infoBlue,
                                  ),
                                if (isAdmin)
                                  ListTile(
                                    title: Text(
                                      'Add Member',
                                      style: TextStyle(
                                        color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                      ),
                                    ),
                                    leading: Icon(
                                      Icons.person_add,
                                      color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                    ),
                                    onTap: () => showDialog(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: Text(
                                          'Add Member',
                                          style: TextStyle(
                                            color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                          ),
                                        ),
                                        content: TextField(
                                          controller: _memberEmailController, // Input field for the member's email.
                                          decoration: InputDecoration(
                                            labelText: 'Member Email',
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
                                              await viewModel.addMember(widget.groupId, _memberEmailController.text); // Add a new member to the group.
                                              if (viewModel.errorMessage != null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(viewModel.errorMessage!)), // Display error if adding fails.
                                                );
                                              } else {
                                                _memberEmailController.clear(); // Clear the input field after adding.
                                                Navigator.pop(context);
                                              }
                                            },
                                            child: Text(
                                              'Add',
                                              style: TextStyle(
                                                color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                if (isAdmin)
                                  ElevatedButton(
                                    onPressed: () async {
                                      await viewModel.deleteGroup(widget.groupId); // Delete the group.
                                      if (viewModel.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(viewModel.errorMessage!)), // Display error if deletion fails.
                                        );
                                      } else {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: Text(
                                      'Delete Group',
                                      style: TextStyle(
                                        color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  ),
                                if (group.members.isEmpty)
                                  Text(
                                    'No members found',
                                    style: TextStyle(
                                      color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                    ),
                                  ),
                                if (group.members.isNotEmpty)
                                  Column(
                                    children: group.members.map<Widget>((memberId) {
                                      return StreamBuilder(
                                        stream: viewModel.getUser(memberId), // Stream to fetch the member's user data.
                                        builder: (context, userSnapshot) {
                                          if (!userSnapshot.hasData) {
                                            return ListTile(
                                              leading: const CircleAvatar(child: Text('?')),
                                              title: Text(
                                                'Unknown User',
                                                style: TextStyle(
                                                  color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                                ),
                                              ),
                                            );
                                          }
                                          final user = userSnapshot.data!;
                                          final isMemberAdmin = group.admins.contains(memberId); // Check if the member is an admin.
                                          return ListTile(
                                            leading: CircleAvatar(
                                              child: Text(user.displayName.substring(0, 1)),
                                            ),
                                            title: Text(
                                              user.displayName,
                                              style: TextStyle(
                                                color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                              ),
                                            ),
                                            trailing: isAdmin && memberId != FirebaseAuth.instance.currentUser!.uid
                                                ? IconButton(
                                                    icon: const Icon(Icons.more_vert),
                                                    color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                                    onPressed: () {
                                                      showModalBottomSheet(
                                                        context: context,
                                                        builder: (context) => Container(
                                                          padding: const EdgeInsets.all(16),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            children: [
                                                              ListTile(
                                                                leading: const Icon(Icons.admin_panel_settings),
                                                                title: Text(
                                                                  isMemberAdmin ? 'Remove Admin' : 'Make Admin',
                                                                  style: TextStyle(
                                                                    color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context);
                                                                  if (isMemberAdmin) {
                                                                    viewModel.removeAdmin(widget.groupId, memberId); // Remove admin privileges.
                                                                  } else {
                                                                    viewModel.makeAdmin(widget.groupId, memberId); // Grant admin privileges.
                                                                  }
                                                                },
                                                              ),
                                                              ListTile(
                                                                leading: const Icon(Icons.remove_circle, color: Colors.red),
                                                                title: Text(
                                                                  'Remove Member',
                                                                  style: TextStyle(
                                                                    color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                                                  ),
                                                                ),
                                                                onTap: () {
                                                                  Navigator.pop(context);
                                                                  viewModel.removeMember(widget.groupId, memberId); // Remove the member from the group.
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  )
                                                : null,
                                          );
                                        },
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: isDarkMode ? AppColors.darkOnSurface : AppColors.lightOnSurface,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            body: StreamBuilder(
              stream: viewModel.getGroup(widget.groupId), // Stream to fetch the group data.
              builder: (context, groupSnapshot) {
                if (!groupSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                final group = groupSnapshot.data!;
                final isAdmin = group.admins.contains(FirebaseAuth.instance.currentUser!.uid); // Check if the current user is an admin.
                final canSendMessage = !group.adminOnlyChat || isAdmin; // Check if the user can send messages.
                return Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<MessageModel>>(
                        stream: viewModel.getGroupMessages(widget.groupId), // Stream of messages for the group chat.
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final messages = snapshot.data!;
                          if (messages.isEmpty) {
                            return const Center(child: Text('No messages yet')); // Display if no messages exist.
                          }
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeOut,
                              );
                            }
                          });
                          return ListView.builder(
                            controller: _scrollController, // Attach the scroll controller to the list.
                            itemCount: messages.length, // Number of messages to display.
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == FirebaseAuth.instance.currentUser!.uid; // Check if the message is sent by the current user.
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Align messages based on the sender.
                                child: StreamBuilder(
                                  stream: viewModel.getUser(message.senderId), // Stream to fetch the sender's user data.
                                  builder: (context, userSnapshot) {
                                    String senderName = 'Unknown User';
                                    if (userSnapshot.hasData) {
                                      senderName = userSnapshot.data!.displayName; // Display the sender's name.
                                    }
                                    return Container(
                                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                      padding: const EdgeInsets.all(12),
                                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? (Provider.of<ThemeProvider>(context).isDarkMode
                                                ? AppColors.darkSenderMessageBg
                                                : AppColors.lightSenderMessageBg)
                                            : (Provider.of<ThemeProvider>(context).isDarkMode
                                                ? AppColors.darkReceiverMessageBg
                                                : AppColors.lightReceiverMessageBg),
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(12),
                                          topRight: const Radius.circular(12),
                                          bottomLeft: Radius.circular(isMe ? 12 : 0),
                                          bottomRight: Radius.circular(isMe ? 0 : 12),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start, // Align text based on the sender.
                                        children: [
                                          Text(
                                            senderName,
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: isMe
                                                      ? (Provider.of<ThemeProvider>(context).isDarkMode
                                                          ? AppColors.darkOnSurface
                                                          : AppColors.lightOnSurface)
                                                      : (Provider.of<ThemeProvider>(context).isDarkMode
                                                          ? AppColors.darkOnSurface
                                                          : AppColors.lightOnSurface),
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            message.text, // Display the message text.
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTimestamp(message.timestamp), // Display the formatted timestamp.
                                            style: Theme.of(context).textTheme.bodySmall,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    if (canSendMessage)
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _messageController, // Input field for typing messages.
                                decoration: const InputDecoration(
                                  hintText: 'Type a message...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: AppColors.infoBlue), // Send button.
                              onPressed: () async {
                                await viewModel.sendMessage(widget.groupId, _messageController.text); // Send the message.
                                if (viewModel.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(viewModel.errorMessage!)), // Display error if sending fails.
                                  );
                                } else {
                                  _messageController.clear(); // Clear the input field after sending.
                                  Future.delayed(const Duration(milliseconds: 100), () {
                                    if (_scrollController.hasClients) {
                                      _scrollController.animateTo(
                                        _scrollController.position.maxScrollExtent,
                                        duration: const Duration(milliseconds: 300),
                                        curve: Curves.easeOut,
                                      );
                                    }
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}