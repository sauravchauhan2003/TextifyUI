import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoCallScreen extends StatefulWidget {
  final MediaStream localStream;
  final RTCVideoRenderer remoteRenderer;

  const VideoCallScreen({
    super.key,
    required this.localStream,
    required this.remoteRenderer,
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void initState() {
    super.initState();
    _initializeRenderers();
  }

  Future<void> _initializeRenderers() async {
    await _localRenderer.initialize();
    _localRenderer.srcObject = widget.localStream;
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    widget.remoteRenderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          RTCVideoView(
            widget.remoteRenderer,
            objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
          ),
          Positioned(
            right: 20,
            top: 40,
            child: SizedBox(
              width: 120,
              height: 160,
              child: RTCVideoView(_localRenderer, mirror: true),
            ),
          ),
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 3,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.call_end),
              label: const Text("End"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
