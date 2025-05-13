import 'package:flutter/material.dart';

// A widget to display a user's avatar.
class UserAvatar extends StatelessWidget {
  final String displayName; // The display name of the user.
  final double radius; // The radius of the avatar circle.

  const UserAvatar({Key? key, required this.displayName, this.radius = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius, // Sets the size of the avatar.
      child: Text(
        displayName.isNotEmpty ? displayName.substring(0, 1) : '?', // Displays the first letter of the display name or '?' if empty.
        style: TextStyle(fontSize: radius * 0.8), // Adjusts the font size based on the radius.
      ),
    );
  }
}

// A widget to display a chat message bubble.
class MessageBubble extends StatelessWidget {
  final String content; // The content of the message.
  final bool isMe; // Indicates if the message is sent by the current user.
  final String? senderName; // The name of the sender (optional).

  const MessageBubble({Key? key, required this.content, required this.isMe, this.senderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, // Aligns the bubble based on the sender.
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Adds spacing around the bubble.
        padding: const EdgeInsets.all(10), // Adds padding inside the bubble.
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200], // Sets the background color based on the sender.
          borderRadius: BorderRadius.circular(10), // Rounds the corners of the bubble.
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Aligns text to the start of the column.
          children: [
            if (senderName != null && !isMe)
              Text(
                senderName!, // Displays the sender's name if provided and not sent by the current user.
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            Text(
              content, // Displays the message content.
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}