import 'package:podd_app/models/entities/user_message.dart';

class UserMessageQueryResult {
  List<UserMessage> data;
  bool hasNextPage;

  UserMessageQueryResult(this.data, this.hasNextPage);

  factory UserMessageQueryResult.fromJson(Map<String, dynamic> json) {
    return UserMessageQueryResult(
      (json["results"] as List)
          .map((item) => UserMessage.fromJson(item))
          .toList(),
      (json["pageInfo"] as Map)["hasNextPage"],
    );
  }
}

class UserMessageGetResult {
  UserMessage data;

  UserMessageGetResult({
    required this.data,
  });

  factory UserMessageGetResult.fromJson(Map<String, dynamic> jsonMap) {
    return UserMessageGetResult(data: UserMessage.fromJson(jsonMap));
  }
}
