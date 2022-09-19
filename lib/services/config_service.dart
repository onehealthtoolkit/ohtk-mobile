class ConfigService {
  String get serverDomain => const String.fromEnvironment(
        'SERVER_DOMAIN',
        defaultValue: "opensur.test",
      );

  String get serverPort => const String.fromEnvironment(
        'SERVER_PORT',
        defaultValue: "80",
      );

  String get serverSchema =>
      const String.fromEnvironment('SERVER_SCHEMA', defaultValue: "https");

  String get serverHost {
    if (serverPort != "80") {
      return "$serverDomain:$serverPort";
    }
    return serverDomain;
  }

  String get graphqlEndpoint => "$serverSchema://$serverHost/graphql/";

  String get tenantApiEndpoint => String.fromEnvironment('TENANT_API_ENDPOINT',
      defaultValue: "$serverSchema://$serverHost/api/servers/");
}
