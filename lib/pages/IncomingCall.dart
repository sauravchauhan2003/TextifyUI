import 'package:flutter/material.dart';

class IncomingCall extends StatelessWidget {
  final String from;
  final String callType;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingCall({
    super.key,
    required this.from,
    required this.callType,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              callType == "video" ? Icons.videocam : Icons.call,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            Text(
              '$from is calling...',
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(Icons.call, color: Colors.white),
                  label: const Text("Accept"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: onReject,
                  icon: const Icon(Icons.call_end, color: Colors.white),
                  label: const Text("Reject"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
