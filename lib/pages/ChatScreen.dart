// File: ChatScreen.dart
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:textify/Logic/Webrtc.dart';
import 'package:textify/Logic/message.dart';
import 'package:textify/widgets/MessageBubble.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:textify/Logic/Websocket.dart';
import 'package:textify/pages/VideoCallScreen.dart';
import 'package:textify/pages/VoiceCallScreen.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {
  final String otherUser;

  const ChatScreen({super.key, required this.otherUser});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> messages = [];
  String currentUser = "";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString("username") ?? "";

    final box = await Hive.openBox<Message>('messages');
    final all =
        box.values
            .where(
              (msg) =>
                  (msg.sender == currentUser &&
                      msg.receiver == widget.otherUser) ||
                  (msg.receiver == currentUser &&
                      msg.sender == widget.otherUser),
            )
            .toList();

    all.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    if (!mounted) return;
    setState(() => messages = all);

    box.watch().listen((event) {
      if (!mounted) return;
      _loadMessages();
    });
  }

  Future<bool> _ensurePermissions() async {
    final statuses = await [Permission.microphone, Permission.camera].request();

    return statuses[Permission.microphone]!.isGranted &&
        statuses[Permission.camera]!.isGranted;
  }

  void _sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty || currentUser.isEmpty) return;

    final message = Message(
      sender: currentUser,
      receiver: widget.otherUser,
      content: content,
      timestamp: DateTime.now(),
    );

    WebSocketService().sendMessage(message);
    final box = await Hive.openBox<Message>('messages');
    await box.add(message);
    _controller.clear();
  }

  void _startVoiceCall() async {
    if (await _ensurePermissions()) {
      final webrtc = WebRtcManager(); // Reuse the instance
      await webrtc.startCall(widget.otherUser, "voice");

      final localStream = webrtc.localStream;
      if (localStream == null) {
        print("❌ Local stream is null, cannot start voice call.");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => VoiceCallScreen(
                remoteUser: widget.otherUser,
                localStream: localStream,
              ),
        ),
      );
    } else {
      print("❌ Permissions not granted");
    }
  }

  void _startVideoCall() async {
    final renderer = RTCVideoRenderer();
    await renderer.initialize();

    final webrtc = WebRtcManager(); // Reuse the instance

    webrtc.onRemoteStream = (stream) {
      renderer.srcObject = stream;

      final localStream = webrtc.localStream;
      if (localStream == null) {
        print("❌ Local stream is null, cannot start video call.");
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => VideoCallScreen(
                localStream: localStream,
                remoteRenderer: renderer,
              ),
        ),
      );
    };

    await webrtc.startCall(widget.otherUser, "video");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: _startVoiceCall,
            tooltip: 'Voice Call',
          ),
          IconButton(
            icon: const Icon(Icons.videocam),
            onPressed: _startVideoCall,
            tooltip: 'Video Call',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isCurrentUser = msg.sender == currentUser;
                return MessageBubble(
                  sender: msg.sender,
                  text: msg.content,
                  user: isCurrentUser ? 1 : 0,
                  timestamp: msg.timestamp,
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFf1f3f4),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Type a message...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 15,
                    horizontal: 10,
                  ),
                ),
              ),
            ),
            IconButton(icon: const Icon(Icons.send), onPressed: _sendMessage),
          ],
        ),
      ),
    );
  }
}
