class ConfigService {
  String get graphqlEndpoint => const String.fromEnvironment('GRAPHQL_ENDPOINT',
      defaultValue: 'https://opensur.test/graphql/');

  String get tenantApiEndpoint =>
      const String.fromEnvironment('TENANT_API_ENDPOINT',
          defaultValue: "https://opensur.test/api/servers/");
}
