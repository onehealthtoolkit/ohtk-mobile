class UserProfile {
  int id;
  String username;
  String firstName;
  String lastName;
  String authorityName;
  int authorityId;
  String? email;
  String? telephone;
  String? role;
  bool? consent;
  List<String> features;

  UserProfile(
      {required this.id,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.authorityName,
      required this.authorityId,
      this.email,
      this.telephone,
      this.role,
      this.consent,
      this.features = const []});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as int,
        username: json['username'].toString(),
        firstName: json['firstName'].toString(),
        lastName: json['lastName'].toString(),
        authorityName: json['authorityName'].toString(),
        authorityId: json['authorityId'] as int,
        email: json['email']?.toString(),
        telephone: json['telephone']?.toString(),
        role: json['role']?.toString(),
        consent: json['consent'] ?? false,
        features: (json['features'] as List).cast<String>(),
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'authorityId': authorityId,
      'authorityName': authorityName,
      'email': email,
      'telephone': telephone,
      'role': role,
      'consent': consent,
      'features': features,
    };
  }

  bool hasFeatureEnabled(String name) =>
      features.indexWhere((feature) => feature == "features.$name") != -1;
}
