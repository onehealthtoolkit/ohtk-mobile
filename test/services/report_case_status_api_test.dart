import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/services/api/report_api.dart';
import '../fixtures/case_report.dart';

class FailingLink extends Link {
  int requests = 0;
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests++;
    return Stream<Response>.error(StateError('socket failed'));
  }
}

class StatusQueueLink extends Link {
  final List<Response> responses;
  final requests = <Request>[];
  StatusQueueLink(this.responses);
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests.add(request);
    return Stream.value(responses.removeAt(0));
  }
}

Response responseFor(String field, {Map<String, dynamic>? status}) {
  final report = caseReportJson(status: status);
  final data = <String, dynamic>{
    '__typename': 'Query',
    field: field == 'incidentReport'
        ? report
        : {
            '__typename': 'IncidentReportTypePaginationConnection',
            'pageInfo': {'__typename': 'PageInfo', 'hasNextPage': false},
            'results': [report],
          }
  };
  return Response(data: data, response: {'data': data});
}

Future<IncidentReport> readReport(ReportApi api, String field,
    {bool reset = true}) async {
  if (field == 'incidentReport') {
    return (await api.getIncidentReport('report-1')).data;
  }
  if (field == 'myIncidentReports') {
    return (await api.fetchMyIncidentReports(resetFlag: reset)).data.single;
  }
  return (await api.fetchIncidentReports(resetFlag: reset)).data.single;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  var offline = false;
  setUp(() {
    offline = false;
    if (!locator.isRegistered<Logger>()) {
      locator.registerSingleton(Logger(level: Level.off));
    }
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (call) async => [offline ? 'none' : 'wifi'],
    );
  });
  tearDown(() async => locator.reset());

  for (final field in [
    'incidentReports',
    'myIncidentReports',
    'incidentReport'
  ]) {
    test(
        '$field selects lifecycle and online reload replaces cached open status',
        () async {
      final link = StatusQueueLink([
        responseFor(field, status: caseStatusJson('', '', finished: false)),
        responseFor(field, status: caseStatusJson('officer', 'close_case')),
      ]);
      final client = GraphQLClient(link: link, cache: GraphQLCache());
      final api = ReportApi(() => client)..baseLogger = null;
      expect((await readReport(api, field)).caseStatus!.outcome,
          ReportCaseOutcome.open);
      expect((await readReport(api, field)).caseStatus!.outcome,
          ReportCaseOutcome.closed);
      expect(link.requests, hasLength(2));
      expect(
          link.requests
              .every((r) => r.operation.toString().contains('caseStatus')),
          isTrue);
    });

    test(
        '$field retries actual main unsupported-field error once without lifecycle',
        () async {
      final fixture = jsonDecode(
          File('test/fixtures/report_case_status_baseline.json')
              .readAsStringSync());
      final errors = (fixture['errors'] as List)
          .map((e) => GraphQLError(message: e['message']))
          .toList();
      expect(errors, hasLength(1));
      final link = StatusQueueLink([
        Response(errors: errors, response: {}),
        responseFor(field),
      ]);
      final client = GraphQLClient(link: link, cache: GraphQLCache());
      final api = ReportApi(() => client)..baseLogger = null;
      expect((await readReport(api, field)).caseStatus, isNull);
      expect(link.requests, hasLength(2));
      expect(link.requests.first.operation.toString(), contains('caseStatus'));
      expect(link.requests.last.operation.toString(),
          isNot(contains('caseStatus')));
    });

    test('$field does not retry a transport failure', () async {
      final link = FailingLink();
      final client = GraphQLClient(link: link, cache: GraphQLCache());
      final api = ReportApi(() => client)..baseLogger = null;
      await expectLater(readReport(api, field), throwsA(isA<LinkException>()));
      expect(link.requests, 1);
    });

    test('$field does not hide auth, unrelated or mixed GraphQL failures',
        () async {
      for (final messages in [
        ['You do not have permission to perform this action'],
        ['Cannot query field "other" on type "IncidentReportType".'],
        [
          'Cannot query field "caseStatus" on type "IncidentReportType".',
          'Permission denied.'
        ],
      ]) {
        final link = StatusQueueLink([
          Response(
              errors: messages.map((m) => GraphQLError(message: m)).toList(),
              response: {})
        ]);
        final client = GraphQLClient(link: link, cache: GraphQLCache());
        final api = ReportApi(() => client)..baseLogger = null;
        await expectLater(
            readReport(api, field), throwsA(isA<OperationException>()));
        expect(link.requests, hasLength(1));
      }
    });
  }

  for (final field in ['incidentReports', 'myIncidentReports']) {
    test('$field offline reads last known status without a network request',
        () async {
      final link = StatusQueueLink(
          [responseFor(field, status: caseStatusJson('system', 'close_case'))]);
      final client = GraphQLClient(link: link, cache: GraphQLCache());
      final api = ReportApi(() => client)..baseLogger = null;
      await readReport(api, field);
      offline = true;
      expect((await readReport(api, field)).caseStatus!.outcome,
          ReportCaseOutcome.automaticClose);
      expect(link.requests, hasLength(1));
    });

    test('$field old cache remains readable offline with generic case status',
        () async {
      final link = StatusQueueLink([
        Response(errors: [
          GraphQLError(
              message:
                  "Cannot query field 'caseStatus' on type 'IncidentReportType'.")
        ], response: {}),
        responseFor(field)
      ]);
      final client = GraphQLClient(link: link, cache: GraphQLCache());
      final api = ReportApi(() => client)..baseLogger = null;
      await readReport(api, field); // seeds the actual baseline selection
      offline = true;
      expect((await readReport(api, field)).caseStatus, isNull);
      expect(link.requests, hasLength(2));
    });
  }
}
