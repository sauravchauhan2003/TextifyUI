import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting time

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.user,
    required this.timestamp,
  });

  final String sender;
  final String text;
  final int user; // 1 = current user, 0 = other user
  final DateTime timestamp;

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat(
      'hh:mm a',
    ).format(timestamp); // e.g., 08:45 PM

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            user == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Material(
            borderRadius:
                user == 1
                    ? const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    )
                    : const BorderRadius.only(
                      topRight: Radius.circular(30),
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
            elevation: 5,
            color:
                user == 1 ? const Color(0xFF1a80e6) : const Color(0xFFf1f3f4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      color: user == 1 ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeString,
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          user == 1
                              ? Colors.white.withOpacity(0.7)
                              : Colors.black.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
