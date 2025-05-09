import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/chat_model.dart';
import '../viewmodel/group_chat_viewmodel.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;

  const GroupChatScreen({Key? key, required this.groupId}) : super(key: key);

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _memberEmailController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _memberEmailController.dispose();
    super.dispose();
  }

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
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    return ChangeNotifierProvider(
      create: (_) => GroupChatViewModel(),
      child: Consumer<GroupChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: StreamBuilder(
                stream: viewModel.getGroup(widget.groupId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Group Chat');
                  final group = snapshot.data!;
                  return Text(group.name);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => StreamBuilder(
                      stream: viewModel.getGroup(widget.groupId),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                        final group = snapshot.data!;
                        final isAdmin = group.admins.contains(FirebaseAuth.instance.currentUser!.uid);
                        viewModel.setAdminOnlyChat(group.adminOnlyChat);
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
                                    onChanged: (value) => viewModel.toggleAdminOnlyChat(widget.groupId),
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
                                          controller: _memberEmailController,
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
                                              await viewModel.addMember(widget.groupId, _memberEmailController.text);
                                              if (viewModel.errorMessage != null) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text(viewModel.errorMessage!)),
                                                );
                                              } else {
                                                _memberEmailController.clear();
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
                                      await viewModel.deleteGroup(widget.groupId);
                                      if (viewModel.errorMessage != null) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(viewModel.errorMessage!)),
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
                                        stream: viewModel.getUser(memberId),
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
                                          final isMemberAdmin = group.admins.contains(memberId);
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
                                                                    viewModel.removeAdmin(widget.groupId, memberId);
                                                                  } else {
                                                                    viewModel.makeAdmin(widget.groupId, memberId);
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
                                                                  viewModel.removeMember(widget.groupId, memberId);
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
              stream: viewModel.getGroup(widget.groupId),
              builder: (context, groupSnapshot) {
                if (!groupSnapshot.hasData) return const Center(child: CircularProgressIndicator());
                final group = groupSnapshot.data!;
                final isAdmin = group.admins.contains(FirebaseAuth.instance.currentUser!.uid);
                final canSendMessage = !group.adminOnlyChat || isAdmin;
                return Column(
                  children: [
                    Expanded(
                      child: StreamBuilder<List<MessageModel>>(
                        stream: viewModel.getGroupMessages(widget.groupId),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                          final messages = snapshot.data!;
                          if (messages.isEmpty) {
                            return const Center(child: Text('No messages yet'));
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
                            controller: _scrollController,
                            itemCount: messages.length,
                            itemBuilder: (context, index) {
                              final message = messages[index];
                              final isMe = message.senderId == FirebaseAuth.instance.currentUser!.uid;
                              return Align(
                                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                child: StreamBuilder(
                                  stream: viewModel.getUser(message.senderId),
                                  builder: (context, userSnapshot) {
                                    String senderName = 'Unknown User';
                                    if (userSnapshot.hasData) {
                                      senderName = userSnapshot.data!.displayName;
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
                                        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
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
                                            message.text,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _formatTimestamp(message.timestamp),
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
                                controller: _messageController,
                                decoration: const InputDecoration(
                                  hintText: 'Type a message...',
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send, color: AppColors.infoBlue),
                              onPressed: () async {
                                await viewModel.sendMessage(widget.groupId, _messageController.text);
                                if (viewModel.errorMessage != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(viewModel.errorMessage!)),
                                  );
                                } else {
                                  _messageController.clear();
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