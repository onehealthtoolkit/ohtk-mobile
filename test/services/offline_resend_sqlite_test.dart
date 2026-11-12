import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/observation_record_service.dart';

import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/login_result.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/queue_ownership_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'auth_service_test.dart' as auth_fakes;
import 'offline_resend_test.dart' as fakes;

UserProfile originalProfile() => UserProfile(
    id: 1,
    username: 'original',
    firstName: '',
    lastName: '',
    authorityName: '',
    authorityId: 1);

// Simulates an API commit followed by a lost response. Requests still pass
// through the real ObservationApi and the queue uses the actual SQLite schema.
class AcceptedObservationLink extends Link {
  final requests = <Request>[];
  final accepted = <String, Map<String, dynamic>>{};
  bool loseFirstAcknowledgement = true;

  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    requests.add(request);
    final document = request.operation.toString();
    if (!document.contains('submitObservationSubject')) {
      return Stream.value(Response(
          errors: [const GraphQLError(message: 'attachment pending')],
          response: {}));
    }
    final monitoring = document.contains('submitObservationSubjectMonitoring');
    final mutation = monitoring
        ? 'submitObservationSubjectMonitoring'
        : 'submitObservationSubject';
    final id = request.variables['recordId'] as String;
    final resource = accepted.putIfAbsent(
        id,
        () => {
              'id': id,
              'definitionId': request.variables['definitionId'],
              'monitoringDefinitionId':
                  request.variables['monitoringDefinitionId'],
              'subjectId': request.variables['subjectId'],
              'title': 'Accepted',
              'description': '',
              'identity': id,
              'isActive': true,
              'formData': request.variables['data'],
              'monitoringRecords': <dynamic>[],
            });
    if (loseFirstAcknowledgement) {
      loseFirstAcknowledgement = false;
      return Stream.error(
          const ServerException(originalException: 'reply lost after commit'));
    }
    final data = {
      mutation: {'result': resource}
    };
    return Stream.value(Response(data: data, response: {'data': data}));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory directory;
  late DbService database;
  late ImageService images;
  late FileService files;
  late fakes.SuccessImageApi imageApi;

  setUp(() async {
    await locator.reset();
    SharedPreferences.setMockInitialValues({'first_run': false});
    directory = await Directory.systemTemp.createTemp('ohtk-outbox-sqlite-');
    await databaseFactory.setDatabasesPath(directory.path);
    database = DbService();
    await database.init();
    locator.registerSingleton<Logger>(Logger(level: Level.off));
    locator.registerSingleton<IDbService>(database);
    imageApi = fakes.SuccessImageApi();
    locator.registerSingleton<ImageApi>(imageApi);
    locator.registerSingleton<FileApi>(fakes.SuccessFileApi());
    images = ImageService();
    files = FileService();
    locator.registerSingleton<IImageService>(images);
    locator.registerSingleton<IFileService>(files);
  });
  tearDown(() async {
    await locator.reset();
    await database.db.close();
    await directory.delete(recursive: true);
  });

  Future<void> reopen() async {
    await database.db.close();
    locator.unregister<IDbService>();
    database = DbService();
    await database.init();
    locator.registerSingleton<IDbService>(database);
  }

  test(
      'actual schema retains an acknowledged parent mapping across close/reopen and cleans up media',
      () async {
    await database.db.insert('report', fakes.report('r1').toMap());
    await images
        .saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1, 2, 3])));
    final localFile = await File('${directory.path}/attachment.txt')
        .writeAsString('original attachment');
    await files.saveReportFile(ReportFile(
        'f1', 'r1', 'attachment.txt', localFile.path, 'txt', 'text/plain'));
    await images.init();
    await files.init();
    final response = fakes.validResponse('remote-report');
    final link =
        fakes.ReplyLink(Response(data: response, response: {'data': response}));
    locator.registerSingleton<ReportApi>(
        ReportApi(() => fakes.client(link))..baseLogger = null);
    final reports = ReportService();
    await reports.init();
    imageApi.failTransport = true;
    final result = await reports.submit(reports.pendingReports.single);
    expect(result, isA<ReportSubmitSuccess>());
    expect((result as ReportSubmitSuccess).pendingAttachments, 1);
    expect(result.attachmentProblems['i1']!.kind,
        SubmissionProblemKind.connection);
    expect(await database.db.query('report'), isEmpty);
    expect(await database.db.query('report_file'), isEmpty);
    expect(await localFile.exists(), false);
    expect(files.pendingReportFiles, isEmpty);
    await reopen();
    final restartedImages = ImageService();
    await restartedImages.init();
    final remaining = restartedImages.pendingImages.single;
    expect(remaining.id, 'i1');
    expect(remaining.reportId, 'r1');
    expect(remaining.effectiveParentId, 'remote-report');
    expect(remaining.image, [1, 2, 3]);
    imageApi.failTransport = false;
    final dbRead = (await restartedImages.findByReportId('r1')).single;
    expect(await restartedImages.submit(dbRead), isA<ImageSubmitSuccess>());
    expect(restartedImages.pendingImages, isEmpty);
    expect(await database.db.query('report_image'), isEmpty);
  });

  test(
      'real SQLite queue and file bytes survive hard refresh expiry, logout and restart',
      () async {
    await database.db.insert('report', fakes.report('r1').toMap());
    await images
        .saveImage(ReportImage('i1', 'r1', Uint8List.fromList([9, 8, 7])));
    final localFile =
        await File('${directory.path}/keep.txt').writeAsString('keep me');
    await files.saveReportFile(ReportFile(
        'f1', 'r1', 'keep.txt', localFile.path, 'txt', 'text/plain'));
    final storage = auth_fakes.MemorySecureStorage();
    await storage.setUserProfile(originalProfile());
    storage.map['token'] = auth_fakes.jwtWithExp(DateTime.now()
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch ~/
        1000);
    storage.map['refreshToken'] = 'expired-refresh';
    locator.registerSingleton<QueueOwnershipService>(
        QueueOwnershipService(database, 'https://original.test/graphql/'));
    final auth = auth_fakes.buildAuthService(
        storage: storage,
        authApi: auth_fakes.FakeAuthApi()
          ..refreshResult = AuthFailure(OperationException(graphqlErrors: [
            const GraphQLError(message: 'Refresh has expired')
          ])));
    await auth.init();
    expect(auth.isLogin, false);
    await auth.logout();
    await reopen();
    expect((await database.db.query('report')).single['id'], 'r1');
    expect(
        (await database.db.query('report_image')).single['image'], [9, 8, 7]);
    expect((await database.db.query('report_file')).single['id'], 'f1');
    expect(await localFile.readAsString(), 'keep me');
    final restartedOwner =
        QueueOwnershipService(database, 'https://original.test/graphql/');
    await restartedOwner.bind(originalProfile());
    final different = originalProfile()..id = 2;
    await expectLater(
        restartedOwner.bind(different), throwsA(isA<SubmissionProblem>()));
    await expectLater(restartedOwner.checkTenantChange('another.test'),
        throwsA(isA<SubmissionProblem>()));
  });

  test(
      'v12 queued rows upgrade through the existing v13/v14 migration without losing bytes or IDs',
      () async {
    await database.db.insert('report', fakes.report('r1').toMap());
    await images
        .saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1, 2, 3])));
    await database.db
        .execute('ALTER TABLE report_image DROP COLUMN parent_type');
    await database.db
        .execute('ALTER TABLE report_image DROP COLUMN remote_parent_id');
    await database.db
        .execute('ALTER TABLE report_file DROP COLUMN parent_type');
    await database.db
        .execute('ALTER TABLE report_file DROP COLUMN remote_parent_id');
    await database.db.execute('ALTER TABLE report DROP COLUMN village_id');
    await database.db.setVersion(12);
    await reopen();
    expect(await database.db.getVersion(), 14);
    final restartedImages = ImageService();
    await restartedImages.init();
    final legacy = restartedImages.pendingImages.single;
    expect(legacy.id, 'i1');
    expect(legacy.image, [1, 2, 3]);
    expect(legacy.parentType, 'incident_report');
    expect(legacy.effectiveParentId, 'r1');
    expect((await database.db.query('report')).single['id'], 'r1');
  });
  test('report authority true, false and null persist through actual SQLite',
      () async {
    for (final value in <bool?>[true, false, null]) {
      final report = fakes.report('authority-$value')
        ..incidentInAuthority = value;
      final link = fakes.ReplyLink(Response(
          errors: [const GraphQLError(message: 'temporary validation')],
          response: {}));
      if (locator.isRegistered<ReportApi>()) locator.unregister<ReportApi>();
      locator.registerSingleton<ReportApi>(
          ReportApi(() => fakes.client(link))..baseLogger = null);
      final reports = ReportService();
      final result = await reports.submit(report);
      expect(result, isA<ReportSubmitPending>());
      expect(link.calls, 1);
      final restarted = ReportService();
      await restarted.init();
      expect(
          restarted.pendingReports
              .firstWhere((e) => e.id == report.id)
              .incidentInAuthority,
          value);
    }
  });
  test(
      'direct observation upload helpers retain their routes after failure and reopen',
      () async {
    await images
        .saveImage(ReportImage('i1', 'local-subject', Uint8List.fromList([1])));
    await files.saveReportFile(ReportFile('f1', 'local-monitoring',
        'missing.txt', '${directory.path}/missing.txt', 'txt', 'text/plain',
        parentType: 'observation_monitoring'));
    expect(
        await images.submitObservationRecordImage(
            (await images.getImage('i1')), 'remote-subject', 'subject'),
        isNot(isA<ImageSubmitSuccess>()));
    await files.submitObservationRecordFile(
        await files.getReportFile('f1'), 'remote-monitoring');
    await reopen();
    final restartedImages = ImageService();
    final restartedFiles = FileService();
    await restartedImages.init();
    await restartedFiles.init();
    expect(
        restartedImages.pendingImages.single.parentType, 'observation_subject');
    expect(restartedImages.pendingImages.single.effectiveParentId,
        'remote-subject');
    expect(restartedFiles.pendingReportFiles.single.parentType,
        'observation_monitoring');
    expect(restartedFiles.pendingReportFiles.single.effectiveParentId,
        'remote-monitoring');
  });
  for (final monitoring in [false, true]) {
    test(
        'observation ${monitoring ? "monitoring" : "subject"} reuses persisted ID after lost acknowledgement and SQLite reopen',
        () async {
      const id = 'e5a70020-4fba-4d3f-963a-1f69257e01f8';
      final link = AcceptedObservationLink();
      final gqlClient = fakes.client(link);
      locator.registerSingleton<ObservationApi>(
          ObservationApi(() => gqlClient)..baseLogger = null);
      locator.unregister<ImageApi>();
      locator.registerSingleton<ImageApi>(
          ImageApi(() => gqlClient)..baseLogger = null);
      locator.unregister<FileApi>();
      locator.registerSingleton<FileApi>(
          FileApi(() => gqlClient)..baseLogger = null);

      Future<void> reloadMedia() async {
        locator.unregister<IImageService>();
        locator.unregister<IFileService>();
        images = ImageService();
        files = FileService();
        await images.init();
        await files.init();
        locator.registerSingleton<IImageService>(images);
        locator.registerSingleton<IFileService>(files);
      }

      await reloadMedia();
      await images.saveImage(
          ReportImage('observation-image', id, Uint8List.fromList([1, 2])));
      final localFile = await File('${directory.path}/observation.txt')
          .writeAsString('keep attachment');
      await files.saveReportFile(ReportFile('observation-file', id,
          'observation.txt', localFile.path, 'txt', 'text/plain'));
      final observations = ObservationRecordService();
      await observations.init();
      final date = DateTime(2026, 11, 5);
      if (monitoring) {
        final result = await observations.submitMonitoringRecord(
            MonitoringRecord(
                id: id,
                data: {'state': 1},
                recordDate: date,
                monitoringDefinitionId: 1,
                monitoringDefinitionName: 'Monitoring',
                subjectId: 'c45b7600-026a-4f09-b47e-913d1ee30437'));
        expect(result, isA<MonitoringRecordSubmitPending>());
      } else {
        final result = await observations.submitSubjectRecord(SubjectRecord(
            id: id,
            data: {'state': 1},
            recordDate: date,
            definitionId: 1,
            definitionName: 'Subject'));
        expect(result, isA<SubjectRecordSubmitPending>());
      }
      expect(link.accepted.keys, [id]);
      final table = monitoring ? 'monitoring_record' : 'subject_record';
      expect((await database.db.query(table)).single['id'], id);
      expect(
          (await database.db.query('report_image')).single['remote_parent_id'],
          isNull);
      expect(await localFile.readAsString(), 'keep attachment');

      await reopen();
      await reloadMedia();
      final restarted = ObservationRecordService();
      await restarted.init();
      if (monitoring) {
        expect(restarted.pendingMonitoringRecords.single.id, id);
        final result = await restarted
            .submitMonitoringRecord(restarted.pendingMonitoringRecords.single);
        expect(result, isA<MonitoringRecordSubmitSuccess>());
        expect(
            (result as MonitoringRecordSubmitSuccess).monitoringRecord.id, id);
        expect(result.pendingAttachments, 2);
      } else {
        expect(restarted.pendingSubjectRecords.single.id, id);
        final result = await restarted
            .submitSubjectRecord(restarted.pendingSubjectRecords.single);
        expect(result, isA<SubjectRecordSubmitSuccess>());
        expect((result as SubjectRecordSubmitSuccess).subject.id, id);
        expect(result.pendingAttachments, 2);
      }
      final parentRequests = link.requests
          .where((request) =>
              request.operation.toString().contains('submitObservationSubject'))
          .toList();
      expect(parentRequests, hasLength(2));
      expect(parentRequests.map((request) => request.variables['recordId']),
          [id, id]);
      expect(link.accepted, hasLength(1));
      expect(await database.db.query(table), isEmpty);
      for (final mediaTable in ['report_image', 'report_file']) {
        final row = (await database.db.query(mediaTable)).single;
        expect(row['remote_parent_id'], id);
        expect(row['parent_type'],
            monitoring ? 'observation_monitoring' : 'observation_subject');
      }
      expect(await localFile.readAsString(), 'keep attachment');
    });
  }
}
