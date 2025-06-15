import 'package:flutter/material.dart';
import 'package:textify/widgets/MessageBubble.dart'; // Ensure this is correctly implemented and imported

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true, // Ensures the back button is shown
        titleSpacing:
            0, // Removes default padding between back button and title
        title: Row(
          children: [
            const SizedBox(width: 8), // Adjust spacing after back button
            const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue, // Placeholder color
              child: Icon(
                Icons.person,
                color: Colors.white,
              ), // Placeholder icon
            ),
            const SizedBox(width: 10), // Space between avatar and name
            Flexible(
              child: Text(
                "User Name", // Replace with dynamic user name if needed
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis, // Prevents overflow
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                return MessageBubble(
                  sender: "Sender $index", // Example sender
                  text: "Message $index", // Example text
                  user: index % 2, // Alternate between user 0 and 1
                );
              },
              itemCount: 12, // Number of messages
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFf1f3f4), // Light grey background
                borderRadius: BorderRadius.circular(10), // Rounded corners
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Message Username",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file),
                        onPressed: () {
                          // Add functionality for attachment icon
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.camera_alt),
                        onPressed: () {
                          // Add functionality for camera icon
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.emoji_emotions),
                        onPressed: () {
                          // Add functionality for smiley icon
                        },
                      ),
                    ],
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
