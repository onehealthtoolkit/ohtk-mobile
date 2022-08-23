import 'package:podd_app/models/entities/attachment.dart';
import 'package:podd_app/models/entities/user.dart';

class Comment {
  String id;
  String body;
  User user;
  DateTime createdAt;
  List<Attachment> attachments;
  int? threadId;

  Comment({
    required this.id,
    required this.body,
    required this.user,
    required this.createdAt,
    required this.attachments,
    this.threadId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      body: json['body'],
      user: User.fromJson(json['createdBy']),
      createdAt: DateTime.parse(json['createdAt']),
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((attach) => Attachment.fromJson(attach))
              .toList()
          : [],
      threadId: json['threadId'],
    );
  }
}
