import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/census_definition.dart';
import 'package:podd_app/models/village_census.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class CensusApi extends GraphQlBaseApi {
  CensusApi(ResolveGraphqlClient client) : super(client);

  Future<CensusDefinitionVersion?> getActiveCensusDefinitionVersion(
    String kind,
  ) async {
    const query = r'''
      query ActiveCensusDefinitionVersion($kind: String!) {
        activeCensusDefinitionVersion(kind: $kind) {
          id
          version
          status
          runtimeSchema
        }
      }
    ''';

    if (!await ensureAuthCookieIsSet()) {
      throw GraphQlException(
        message: 'Cookies are invalid',
        query: query,
        queryName: 'ActiveCensusDefinitionVersion',
      );
    }

    final response = await resolveClient().query(
      QueryOptions(
        document: gql(query),
        variables: {'kind': kind},
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );

    if (response.hasException) {
      if (_hasUnsupportedField(
        response.exception,
        'activeCensusDefinitionVersion',
      )) {
        return null;
      }
      if (response.exception?.linkException != null) {
        throw response.exception!.linkException!;
      }
      throw response.exception!;
    }

    final version = response.data?['activeCensusDefinitionVersion'];
    if (version == null) {
      return null;
    }
    return CensusDefinitionVersion.fromJson(version);
  }

  Future<List<CensusKindSummary>> getActiveVillageCensusDefinitions(
    int villageId,
  ) async {
    const query = r'''
      query ActiveVillageCensusDefinitions($villageId: Int!) {
        activeVillageCensusDefinitions(villageId: $villageId) {
          kind
          name
          enabled
          activeVersion {
            id
            version
            status
            runtimeSchema
          }
          latestSnapshot {
            id
            censusDate
            submittedAt
          }
        }
      }
    ''';

    if (!await ensureAuthCookieIsSet()) {
      throw GraphQlException(
        message: 'Cookies are invalid',
        query: query,
        queryName: 'ActiveVillageCensusDefinitions',
      );
    }

    final response = await resolveClient().query(
      QueryOptions(
        document: gql(query),
        variables: {'villageId': villageId},
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );

    if (response.hasException) {
      if (_hasUnsupportedField(
        response.exception,
        'activeVillageCensusDefinitions',
      )) {
        return const [];
      }
      if (response.exception?.linkException != null) {
        throw response.exception!.linkException!;
      }
      throw response.exception!;
    }

    return (response.data?['activeVillageCensusDefinitions'] as List? ??
            const [])
        .whereType<Map>()
        .map((summary) => CensusKindSummary.fromJson(
              Map<String, dynamic>.from(summary),
            ))
        .toList();
  }

  Future<VillageCensusSnapshot?> getLatestVillageCensusV2(
    int villageId,
    String kind,
  ) async {
    const query = r'''
      query LatestVillageCensusV2($villageId: Int!, $kind: String!) {
        latestVillageCensusV2(villageId: $villageId, kind: $kind) {
          id
          censusDate
          submittedAt
          villageHouseholdQuantity
          animalHouseholdQuantity
          formData
          definitionVersion {
            id
            version
            definition {
              kind
            }
          }
          village {
            id
            code
            name
          }
          facts {
            rowKey
            rowLabel
            animalQuantity
            householdQuantity
          }
        }
      }
    ''';

    if (!await ensureAuthCookieIsSet()) {
      throw GraphQlException(
        message: 'Cookies are invalid',
        query: query,
        queryName: 'LatestVillageCensusV2',
      );
    }

    final response = await resolveClient().query(
      QueryOptions(
        document: gql(query),
        variables: {'villageId': villageId, 'kind': kind},
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );

    if (response.hasException) {
      if (_hasUnsupportedField(response.exception, 'latestVillageCensusV2')) {
        return null;
      }
      if (response.exception?.linkException != null) {
        throw response.exception!.linkException!;
      }
      throw response.exception!;
    }

    final snapshot = response.data?['latestVillageCensusV2'];
    if (snapshot == null) {
      return null;
    }
    return VillageCensusSnapshot.fromJson(snapshot);
  }

  Future<List<CensusRoundOccurrence>> getOpenVillageCensusRoundOccurrences({
    required int villageId,
    required String kind,
    String mode = 'PRODUCTION',
  }) async {
    const query = r'''
      query OpenVillageCensusRoundOccurrences(
        $villageId: Int!,
        $kind: String!,
        $mode: String
      ) {
        openVillageCensusRoundOccurrences(
          villageId: $villageId,
          kind: $kind,
          mode: $mode
        ) {
          id
          occurrenceKey
          kind
          mode
          censusPeriodStart
          censusPeriodEnd
          startDate
          softFinishDate
          hardFinishDate
          status
        }
      }
    ''';

    if (!await ensureAuthCookieIsSet()) {
      throw GraphQlException(
        message: 'Cookies are invalid',
        query: query,
        queryName: 'OpenVillageCensusRoundOccurrences',
      );
    }

    final response = await resolveClient().query(
      QueryOptions(
        document: gql(query),
        variables: {
          'villageId': villageId,
          'kind': kind,
          'mode': mode,
        },
        fetchPolicy: FetchPolicy.networkOnly,
        cacheRereadPolicy: CacheRereadPolicy.ignoreAll,
      ),
    );

    if (response.hasException) {
      if (_hasUnsupportedField(
        response.exception,
        'openVillageCensusRoundOccurrences',
      )) {
        return const [];
      }
      if (response.exception?.linkException != null) {
        throw response.exception!.linkException!;
      }
      throw response.exception!;
    }

    return (response.data?['openVillageCensusRoundOccurrences'] as List? ??
            const [])
        .whereType<Map>()
        .map((occurrence) => CensusRoundOccurrence.fromJson(
              Map<String, dynamic>.from(occurrence),
            ))
        .toList();
  }

  Future<VillageCensusSubmitResult> submitVillageCensusSnapshotV2({
    required int villageId,
    required int definitionVersionId,
    int? occurrenceId,
    required String censusDate,
    required Map<String, dynamic> formData,
  }) async {
    const mutation = r'''
      mutation SubmitVillageCensusSnapshotV2(
        $villageId: Int!,
        $definitionVersionId: Int!,
        $occurrenceId: Int,
        $censusDate: Date!,
        $formData: GenericScalar!
      ) {
        submitVillageCensusSnapshotV2(
          villageId: $villageId,
          definitionVersionId: $definitionVersionId,
          occurrenceId: $occurrenceId,
          censusDate: $censusDate,
          formData: $formData
        ) {
          result {
            __typename
            ... on VillageCensusSnapshotType {
              id
              censusDate
              submittedAt
              roundResolution
              roundOccurrence {
                id
                occurrenceKey
                mode
              }
              villageHouseholdQuantity
              animalHouseholdQuantity
              village {
                id
                code
                name
              }
              facts {
                rowKey
                rowLabel
                animalQuantity
                householdQuantity
              }
            }
            ... on VillageCensusSnapshotProblem {
              fields {
                name
                message
              }
              message
            }
          }
        }
      }
    ''';

    try {
      return await runGqlMutation<VillageCensusSubmitResult>(
        mutation: mutation,
        variables: {
          'villageId': villageId,
          'definitionVersionId': definitionVersionId,
          'occurrenceId': occurrenceId,
          'censusDate': censusDate,
          'formData': formData,
        },
        parseData: _parseSubmitResult,
      );
    } on OperationException catch (e) {
      if (_hasUnsupportedField(e, 'submitVillageCensusSnapshotV2')) {
        return VillageCensusSubmitUnsupported();
      }
      return VillageCensusSubmitFailure(e);
    }
  }

  VillageCensusSubmitResult _parseSubmitResult(Map<String, dynamic>? resp) {
    final result = resp?['result'];
    if (result?['__typename'] == 'VillageCensusSnapshotType') {
      return VillageCensusSubmitSuccess(
        VillageCensusSnapshot.fromJson(result),
      );
    }

    final fieldMessages = (result?['fields'] as List? ?? const [])
        .map((field) => field['message'].toString())
        .toList();
    final message = result?['message']?.toString();
    final messages = [
      ...fieldMessages,
      if (message != null && message.isNotEmpty) message,
    ];
    if (_isDefinitionChanged(messages)) {
      return CensusDefinitionChanged(messages);
    }
    return VillageCensusSubmitValidationFailure(messages);
  }

  bool _isDefinitionChanged(List<String> messages) {
    return messages.any(
      (message) =>
          message.contains('census definition version must be published') ||
          message.contains('DEFINITION_VERSION_RETIRED') ||
          message.contains('DEFINITION_DISABLED') ||
          message.contains('ACTIVE_ANIMAL_SPECIES_CHANGED') ||
          message.contains('census definition is not enabled'),
    );
  }

  bool _hasUnsupportedField(OperationException? exception, String fieldName) {
    final errors = exception?.graphqlErrors ?? const [];
    if (errors.any(
      (error) => error.message.contains("Cannot query field '$fieldName'"),
    )) {
      return true;
    }

    return exception?.linkException
            ?.toString()
            .contains("Cannot query field '$fieldName'") ??
        false;
  }
}
