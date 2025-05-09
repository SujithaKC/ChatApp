import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String displayName;
  final double radius;

  const UserAvatar({Key? key, required this.displayName, this.radius = 30}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      child: Text(
        displayName.isNotEmpty ? displayName.substring(0, 1) : '?',
        style: TextStyle(fontSize: radius * 0.8),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String content;
  final bool isMe;
  final String? senderName;

  const MessageBubble({Key? key, required this.content, required this.isMe, this.senderName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue[100] : Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (senderName != null && !isMe)
              Text(
                senderName!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}