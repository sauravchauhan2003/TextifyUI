import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VoiceCallScreen extends StatelessWidget {
  final String remoteUser;
  final MediaStream localStream;

  const VoiceCallScreen({
    super.key,
    required this.remoteUser,
    required this.localStream,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text('Voice Call: $remoteUser')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.call, size: 80, color: Colors.greenAccent),
            const SizedBox(height: 20),
            Text(
              remoteUser,
              style: const TextStyle(color: Colors.white, fontSize: 22),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.call_end),
              label: const Text("End Call"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        ),
      ),
    );
  }
}
