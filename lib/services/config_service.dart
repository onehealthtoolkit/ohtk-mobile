class ConfigService {
  String get serverDomain => const String.fromEnvironment(
        'SERVER_DOMAIN',
        defaultValue: "opensur.test",
      );

  String get serverPort => const String.fromEnvironment(
        'SERVER_PORT',
        defaultValue: "8000",
      );

  String get serverSchema =>
      const String.fromEnvironment('SERVER_SCHEMA', defaultValue: "http");

  String get serverHost => "$serverDomain:$serverPort";

  String get graphqlEndpoint => "$serverSchema://$serverHost/graphql/";
}
