import 'package:flutter_test/flutter_test.dart';
import 'package:podd_app/models/entities/incident_report.dart';

void main() {
  test('IncidentReport accepts image without thumbnail', () {
    final report = IncidentReport.fromJson(<String, dynamic>{
      'id': 'report-1',
      'rendererData': 'Sick animal',
      'reportType': <String, dynamic>{
        'id': 'type-1',
        'name': 'Animal Sick/Death',
      },
      'incidentDate': '2026-05-19',
      'createdAt': '2026-05-19T08:00:00Z',
      'updatedAt': '2026-05-19T08:00:00Z',
      'gpsLocation': null,
      'data': <String, dynamic>{},
      'caseId': null,
      'threadId': null,
      'testFlag': false,
      'images': [
        <String, dynamic>{
          'id': 'image-1',
          'file': '/media/reports/not-image.txt',
          'imageUrl': 'https://example.test/media/reports/not-image.txt',
          'thumbnail': null,
        }
      ],
      'uploadFiles': [],
    });

    expect(report.images, hasLength(1));
    expect(
      report.images!.single.thumbnailPath,
      'https://example.test/media/reports/not-image.txt',
    );
    expect(
      report.images!.single.imageUrl,
      'https://example.test/media/reports/not-image.txt',
    );
  });

  group('followup availability', () {
    Map<String, dynamic> reportJson() => {
          'id': 'report-1',
          'rendererData': 'Sick animal',
          'reportType': {
            'id': 'type-1',
            'name': 'Animal Sick/Death',
            'isFollowable': true,
          },
          'incidentDate': '2026-11-05',
          'createdAt': '2026-11-05T08:00:00Z',
          'updatedAt': '2026-11-05T08:00:00Z',
          'hasFollowupPermission': true,
        };

    test('allows followup when the server grants permission', () {
      expect(IncidentReport.fromJson(reportJson()).canFollowup, isTrue);
    });

    test('hides followup outside assigned villages even if type is followable',
        () {
      final json = reportJson()..['hasFollowupPermission'] = false;
      expect(IncidentReport.fromJson(json).canFollowup, isFalse);
    });

    test('does not grant permission when the server value is missing or null',
        () {
      final json = reportJson()..remove('hasFollowupPermission');
      expect(IncidentReport.fromJson(json).canFollowup, isFalse);
      json['hasFollowupPermission'] = null;
      expect(IncidentReport.fromJson(json).canFollowup, isFalse);
    });

    test('keeps followup hidden for test reports', () {
      final json = reportJson()..['testFlag'] = true;
      expect(IncidentReport.fromJson(json).canFollowup, isFalse);
    });

    test('keeps followup hidden for types without followup', () {
      final json = reportJson();
      (json['reportType'] as Map)['isFollowable'] = false;
      expect(IncidentReport.fromJson(json).canFollowup, isFalse);
    });
  });
}
