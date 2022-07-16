import 'package:podd_app/models/entities/message.dart';
import 'package:podd_app/models/entities/user.dart';

class UserMessage {
  String id;
  Message message;
  User? user;
  bool isSeen = false;

  UserMessage({
    required this.id,
    required this.message,
  });

  UserMessage.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap['id'],
        message = Message.fromJson(jsonMap['message']),
        user = jsonMap['user'] != null ? User.fromJson(jsonMap['user']) : null,
        isSeen = jsonMap['isSeen'];
}
