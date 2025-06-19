import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  String sender;

  @HiveField(1)
  String receiver;

  @HiveField(2)
  String content;

  @HiveField(3)
  DateTime timestamp;

  Message({
    required this.sender,
    required this.receiver,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'] ?? 'unknown',
      receiver: json['receiver'] ?? 'unknown',
      content: json['message'] ?? '',
      timestamp:
          DateTime.tryParse(json['localDateTime'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'receiver': receiver,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };
}
