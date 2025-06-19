import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:textify/Logic/Constants.dart';

class WebRtcManager {
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  IOWebSocketChannel? _channel;
  bool _connected = false;

  final Map<String, dynamic> _config = {
    'iceServers': [
      {'urls': 'stun:stun.l.google.com:19302'},
    ],
  };

  Future<void> connectToSignalingServer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('jwt_token');
    if (jwt == null) {
      print('JWT not found');
      return;
    }

    final uri = Uri.parse(
      WebRtcWebsocketUrl,
    ); // e.g. ws://localhost:8000/webrtc
    _channel = IOWebSocketChannel.connect(
      uri,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    _channel!.stream.listen(
      (event) {
        final data = jsonDecode(event);
        _handleSignalingMessage(data);
      },
      onDone: () {
        print('WebRTC signaling connection closed');
        _connected = false;
      },
      onError: (error) {
        print('WebRTC signaling error: $error');
        _connected = false;
      },
    );

    _connected = true;
  }

  Future<void> startCall(String toUsername, String callType) async {
    await _createPeerConnection();

    RTCSessionDescription offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    _sendMessage({
      'type': 'offer',
      'from': await _getUsername(),
      'to': toUsername,
      'callType': callType,
      'sdp': offer.sdp,
    });
  }

  Future<void> _createPeerConnection() async {
    _localStream = await navigator.mediaDevices.getUserMedia({
      'audio': true,
      'video': true,
    });

    _peerConnection = await createPeerConnection(_config);
    _peerConnection!.addStream(_localStream!);

    _peerConnection!.onIceCandidate = (candidate) {
      if (candidate != null) {
        _sendMessage({
          'type': 'candidate',
          'to': _remoteUser,
          'from': _getUsername(),
          'candidate': {
            'candidate': candidate.candidate,
            'sdpMid': candidate.sdpMid,
            'sdpMLineIndex': candidate.sdpMLineIndex,
          },
        });
      }
    };

    _peerConnection!.onAddStream = (stream) {
      print('Remote stream added');
    };
  }

  Future<void> _handleSignalingMessage(dynamic message) async {
    switch (message['type']) {
      case 'offer':
        await _createPeerConnection();
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(message['sdp'], 'offer'),
        );
        RTCSessionDescription answer = await _peerConnection!.createAnswer();
        await _peerConnection!.setLocalDescription(answer);
        _sendMessage({
          'type': 'answer',
          'from': await _getUsername(),
          'to': message['from'],
          'sdp': answer.sdp,
        });
        break;

      case 'answer':
        await _peerConnection!.setRemoteDescription(
          RTCSessionDescription(message['sdp'], 'answer'),
        );
        break;

      case 'candidate':
        final candidate = message['candidate'];
        await _peerConnection!.addCandidate(
          RTCIceCandidate(
            candidate['candidate'],
            candidate['sdpMid'],
            candidate['sdpMLineIndex'],
          ),
        );
        break;
    }
  }

  void _sendMessage(Map<String, dynamic> message) {
    if (_connected && _channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  Future<String> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('username') ?? 'unknown';
  }

  void dispose() {
    _peerConnection?.close();
    _peerConnection = null;
    _localStream?.dispose();
    _localStream = null;
    _channel?.sink.close();
  }

  String? _remoteUser;
}
