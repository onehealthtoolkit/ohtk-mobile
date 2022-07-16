class Message {
  String id;
  String title;
  String body;
  String image;

  Message({
    required this.id,
    required this.title,
    required this.body,
    required this.image,
  });

  Message.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"],
        title = jsonMap["title"],
        body = jsonMap["body"],
        image = jsonMap["image"];
}
