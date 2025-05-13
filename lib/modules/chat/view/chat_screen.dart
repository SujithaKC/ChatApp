import 'package:chat_app/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../models/chat_model.dart';
import '../viewmodel/chat_viewmodel.dart';
import '../../profile/view/friend_profile_screen.dart';

// This file defines the `ChatScreen` class, which provides the user interface for individual chats.
// It includes message input, display, and sending functionality.

class ChatScreen extends StatefulWidget {
  final String chatId; // The ID of the chat to display.
  final String friendId; // The ID of the friend participating in the chat.

  const ChatScreen({Key? key, required this.chatId, required this.friendId}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController(); // Controller for the message input field.

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _messageController.dispose(); // Dispose of the message controller to free resources.
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
    return ChangeNotifierProvider(
      create: (_) => ChatViewModel(), // Provide a ChatViewModel instance to the widget tree.
      child: Consumer<ChatViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              // Display the friend's name in the app bar using a StreamBuilder.
              title: StreamBuilder(
                stream: viewModel.getUser(widget.friendId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text('Chat');
                  return Text(snapshot.data!.displayName);
                },
              ),
              actions: [
                // Navigate to the friend's profile screen when the profile icon is tapped.
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
                    stream: viewModel.getMessages(widget.chatId), // Stream of messages for the chat.
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final messages = snapshot.data!;
                      if (messages.isEmpty) {
                        return const Center(child: Text('No messages yet')); // Display if no messages exist.
                      }
                      return ListView.builder(
                        reverse: true, // Automatically scroll to the most recent messages.
                        itemCount: messages.length, // Number of messages to display.
                        itemBuilder: (context, index) {
                          final message = messages[messages.length - 1 - index]; // Adjust indexing for reverse order.
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
                          await viewModel.sendMessage(widget.chatId, _messageController.text); // Send the message.
                          if (viewModel.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(viewModel.errorMessage!)), // Display error if sending fails.
                            );
                          } else {
                            _messageController.clear(); // Clear the input field after sending.
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