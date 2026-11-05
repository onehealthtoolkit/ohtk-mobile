import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/report_api.dart';

class QueueLink extends Link {
  final List<Map<String, dynamic>> responses;
  final requests = <Request>[];

  QueueLink(this.responses);

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests.add(request);
    final data = responses.removeAt(0);
    return Stream.value(Response(data: data, response: {'data': data}));
  }
}

void main() {
  setUpAll(() {
    if (!locator.isRegistered<Logger>()) {
      locator.registerSingleton<Logger>(Logger());
    }
  });

  test('submit sends the report village id', () async {
    final link = QueueLink([
      {
        'submitIncidentReport': {
          'result': {
            'id': 'report-1',
            'incidentDate': '2026-08-11',
            'gpsLocation': null,
            'rendererData': 'Sick animal',
            'createdAt': '2026-08-11T08:00:00Z',
            'updatedAt': '2026-08-11T08:00:00Z',
            'reportType': {
              'id': 'type-1',
              'name': 'Animal Sick/Death',
              'isFollowable': false,
            },
            'reportedBy': {'id': 'user-1', 'username': 'reporter'},
            'testFlag': false,
          },
        },
      }
    ]);
    final api = ReportApi(
      () => GraphQLClient(link: link, cache: GraphQLCache()),
    )..baseLogger = null;
    final report = Report(
      id: 'report-1',
      data: const {'symptom': 'cough'},
      reportTypeId: 'type-1',
      incidentDate: DateTime(2026, 8, 11),
      villageId: 11,
      incidentInAuthority: true,
      testFlag: false,
    );

    final result = await api.submit(report);

    expect(result, isA<ReportSubmitSuccess>());
    expect(link.requests.single.variables['villageId'], 11);
    expect(
      link.requests.single.operation.toString(),
      contains(r'villageId: $villageId'),
    );
  });

  test('report detail requests and reads current followup permission',
      () async {
    for (final allowed in [true, false]) {
      final link = QueueLink([
        {
          '__typename': 'Query',
          'incidentReport': {
            '__typename': 'IncidentReportType',
            'gpsLocation': null,
            'accumulatedMetrics': null,
            'authorities': [],
            'reportedBy': null,
            'images': [],
            'uploadFiles': [],
            'caseId': null,
            'caseStatus': null,
            'threadId': null,
            'testFlag': false,
            'id': 'report-1',
            'incidentDate': '2026-11-05',
            'rendererData': 'Sick animal',
            'createdAt': '2026-11-05T08:00:00Z',
            'updatedAt': '2026-11-05T08:00:00Z',
            'reportType': {
              '__typename': 'ReportTypeType',
              'id': 'type-1',
              'name': 'Animal Sick/Death',
              'isFollowable': true,
            },
            'hasFollowupPermission': allowed,
          },
        }
      ]);
      final api = ReportApi(
        () => GraphQLClient(link: link, cache: GraphQLCache()),
      )..baseLogger = null;

      final result = await api.getIncidentReport('report-1');

      expect(result.data.canFollowup, allowed);
      expect(link.requests.single.operation.toString(),
          contains('hasFollowupPermission'));
      expect(link.requests.single.variables['id'], 'report-1');
    }
  });
}
