class Configuration {
  String key;
  String value;

  Configuration({
    required this.key,
    required this.value,
  });

  Configuration.fromJson(Map<String, dynamic> jsonMap)
      : key = jsonMap['key'],
        value = jsonMap['value'];
}
