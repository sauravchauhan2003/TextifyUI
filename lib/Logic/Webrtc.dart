// File: WebRtcManager.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:textify/Logic/Constants.dart';
import 'package:textify/pages/VideoCallScreen.dart';
import 'package:textify/pages/VoiceCallScreen.dart';

class WebRtcManager {
  static final WebRtcManager _instance = WebRtcManager._internal();
  factory WebRtcManager() => _instance;
  WebRtcManager._internal();

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IOWebSocketChannel? _channel;
  bool _connected = false;
  String? _remoteUser;

  Function(String from, String callType)? onIncomingCall;
  Function()? onCallEnded;
  Function(MediaStream stream)? onRemoteStream;

  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  MediaStream? get localStream => _localStream;
  bool get isConnected => _connected;

  Future<void> connectToSignalingServer() async {
    if (_connected) {
      print("Already connected to signaling server.");
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      print("JWT not found.");
      return;
    }

    final uri = Uri.parse(WebRtcWebsocketUrl);
    print("Connecting to signaling server with JWT: $jwt");

    _channel = IOWebSocketChannel.connect(
      uri,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    _channel!.stream.listen(
      (event) {
        print("Received signaling message: $event");
        _handleSignalingMessage(jsonDecode(event));
      },
      onDone: () {
        print("WebSocket connection closed");
        _connected = false;
      },
      onError: (error) {
        print("WebSocket error: $error");
        _connected = false;
      },
    );

    _connected = true;
    print("WebSocket connected: $_connected");
  }

  Future<void> startCall(String toUsername, String callType) async {
    if (!_connected) {
      print("WebSocket is not connected. Cannot start call.");
      return;
    }

    _remoteUser = toUsername;
    await _createPeerConnection(callType == "video");
    if (_peerConnection == null) {
      print("PeerConnection is null");
      return;
    }
    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);
    print("Created offer: ${offer.sdp}");
    sendMessage({
      'type': 'offer',
      'from': await _getUsername(),
      'to': toUsername,
      'callType': callType,
      'sdp': offer.sdp,
    });
  }

  Future<void> acceptCall(
    String callType,
    String from,
    BuildContext context,
  ) async {
    if (!_connected) {
      print("WebSocket is not connected. Cannot accept call.");
      return;
    }

    await _createPeerConnection(callType == "video");
    if (_peerConnection == null) {
      print("PeerConnection is null");
      return;
    }
    RTCSessionDescription answer = await _peerConnection!.createAnswer();
    await _peerConnection!.setLocalDescription(answer);
    print("Created answer: ${answer.sdp}");
    sendMessage({
      'type': 'answer',
      'from': await _getUsername(),
      'to': from,
      'sdp': answer.sdp,
      'callType': callType,
    });

    if (callType == "video") {
      final renderer = RTCVideoRenderer();
      await renderer.initialize();
      onRemoteStream = (stream) {
        renderer.srcObject = stream;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => VideoCallScreen(
                  localStream: _localStream!,
                  remoteRenderer: renderer,
                ),
          ),
        );
      };
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  VoiceCallScreen(remoteUser: from, localStream: _localStream!),
        ),
      );
    }
  }

  Future<void> _createPeerConnection(bool videoEnabled) async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': videoEnabled,
    });

    _peerConnection = await createPeerConnection(_config);
    if (_peerConnection != null && localStream != null) {
      for (var track in localStream!.getTracks()) {
        _peerConnection!.addTrack(track, localStream!);
      }
    }

    _peerConnection!.onIceCandidate = (candidate) async {
      if (candidate != null && _remoteUser != null) {
        print("Sending ICE candidate to $_remoteUser: ${candidate.candidate}");
        sendMessage({
          'type': 'candidate',
          'to': _remoteUser,
          'from': await _getUsername(),
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    _peerConnection!.onAddStream = (stream) {
      print("Remote stream added");
      onRemoteStream?.call(stream);
    };
  }

  Future<void> _handleSignalingMessage(dynamic message) async {
    print("Handling signaling message: $message");
    switch (message['type']) {
      case 'offer':
        _remoteUser = message['from'];
        onIncomingCall?.call(_remoteUser!, message['callType']);
        break;
      case 'answer':
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(message['sdp'], 'answer'),
        );
        break;
      case 'candidate':
        final c = message['candidate'];
        await _peerConnection!.addCandidate(
          RTCIceCandidate(c['candidate'], c['sdpMid'], c['sdpMLineIndex']),
        );
        break;
      case 'end':
        _peerConnection?.close();
        onCallEnded?.call();
        break;
    }
  }

  void sendMessage(Map<String, dynamic> message) {
    if (_connected && _channel != null) {
      final encoded = jsonEncode(message);
      print("Sending message: $encoded");
      _channel!.sink.add(encoded);
    } else {
      print("WebSocket not connected, message not sent: $message");
    }
  }

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'unknown';
  }

  void dispose() {
    print("Disposing WebRTC Manager");
    _peerConnection?.close();
    _localStream?.dispose();
    _channel?.sink.close();
    _connected = false;
  }
}
