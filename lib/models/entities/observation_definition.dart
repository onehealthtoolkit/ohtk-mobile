class ObservationDefinition {
  String id;
  String name;
  String registerFormDefinition;
  String? registerFormMapping;
  String? titleTemplate;
  String? descriptionTemplate;
  String? identityTemplate;
  String? imageUrl;

  ObservationDefinition({
    required this.id,
    required this.name,
    required this.registerFormDefinition,
    this.registerFormMapping,
    this.titleTemplate,
    this.descriptionTemplate,
    this.identityTemplate,
    this.imageUrl,
  });

  // TODO Use in sync result from api
  // ObservationDefinition.fromJson(Map<String, dynamic> jsonMap):

  ObservationDefinition.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        name = map['name'],
        registerFormDefinition = map['register_form_definition'],
        registerFormMapping = map['register_form_mapping'],
        titleTemplate = map['title_template'],
        descriptionTemplate = map['description_template'],
        identityTemplate = map['identity_template'],
        imageUrl = map['image_url'];

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "register_form_definition": registerFormDefinition,
      "register_form_mapping": registerFormMapping,
      "title_template": titleTemplate,
      "description_template": descriptionTemplate,
      "identity_template": identityTemplate,
      "image_url": imageUrl,
    };
    return map;
  }
}
