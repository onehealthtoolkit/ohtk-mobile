class ConfigService {
  String get graphqlEndpoint => const String.fromEnvironment('GRAPHQL_ENDPOINT',
      defaultValue: 'https://opensur.test/graphql/');

  String get tenantApiEndpoint =>
      const String.fromEnvironment('TENANT_API_ENDPOINT',
          defaultValue: "https://opensur.test/api/servers/");

  String get consentConfigurationKey =>
      const String.fromEnvironment('CONSENT_CONFIGURATION_KEY',
          defaultValue: "mobile.consent.msg");

  String get consentAcceptTextKey =>
      const String.fromEnvironment('CONSENT_ACCEPT_TEXT_KEY',
          defaultValue: "mobile.consent.accept.msg");
}
