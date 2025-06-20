// File: WebSocketService.dart
import 'package:textify/Logic/Constants.dart';
import 'package:web_socket_channel/io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'dart:convert';
import 'package:hive/hive.dart';
import 'message.dart';

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();

  factory WebSocketService() => _instance;

  WebSocketService._internal();

  IOWebSocketChannel? _channel;
  bool _isListening = false;

  Future<void> startListening() async {
    if (_isListening) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwt = prefs.getString('jwt_token');

    if (jwt == null) {
      print('JWT not found in SharedPreferences.');
      return;
    }

    final uri = Uri.parse(Websocketurl);
    _channel = IOWebSocketChannel.connect(
      uri,
      headers: {'Authorization': 'Bearer $jwt'},
    );

    _isListening = true;

    _channel!.stream.listen(
      (event) async {
        print('Received: $event');

        final data = jsonDecode(event);

        if (data['type'] == 'message') {
          final messageData = data['data'];
          final message = Message.fromJson(
            Map<String, dynamic>.from(messageData),
          );

          final box = await Hive.openBox<Message>('messages');
          await box.add(message);
        }
      },
      onDone: () {
        print('WebSocket closed.');
        _isListening = false;
      },
      onError: (error) {
        print('WebSocket error: $error');
        _isListening = false;
      },
    );
  }

  void stopListening() {
    _channel?.sink.close(status.normalClosure);
    _isListening = false;
  }

  void sendMessage(Message message) {
    if (_channel != null && _isListening) {
      _channel!.sink.add(jsonEncode(message));
    }
  }
}
