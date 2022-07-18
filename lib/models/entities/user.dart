class User {
  String id;
  String username;
  String firstName;
  String lastName;

  User(
      {required this.id,
      required this.username,
      required this.firstName,
      required this.lastName});

  User.fromJson(Map<String, dynamic> jsonMap)
      : id = jsonMap["id"],
        username = jsonMap["username"],
        firstName = jsonMap["firstName"],
        lastName = jsonMap["lastName"];
}
