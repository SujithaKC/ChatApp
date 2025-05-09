import 'package:chat_app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/chat_model.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../profile/view/friend_profile_screen.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String friendId;

  const ChatScreen({Key? key, required this.chatId, required this.friendId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
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
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(),
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: StreamBuilder(
                stream: viewModel.getUser(widget.friendId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Chat');
                  return Text(snapshot.data!.displayName);
                },
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.person),
                  onPressed: () => Navigator.pushNamed(
                    context,
                    AppRoutes.friendProfile,
                    arguments: widget.friendId,
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder<List<MessageModel>>(
                    stream: viewModel.getMessages(widget.chatId),
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
                          await viewModel.sendMessage(widget.chatId, _messageController.text);
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
            ),
          );
        },
      ),
    );
  }
}