import 'package:podd_app/services/auth_service.dart';
import 'dart:io';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/login_result.dart';
import 'auth_service_test.dart' as auth_fakes;
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:podd_app/services/bounded_request_link.dart';
import 'package:podd_app/services/queue_ownership_service.dart';
import 'package:podd_app/models/submission_problem.dart';
import 'package:podd_app/models/user_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/report_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/observation_record_service.dart';
import 'package:podd_app/ui/resubmit/resubmit_view_model.dart';
import 'package:sqflite/sqflite.dart';

class MemoryDb implements Database {
  final tables = <String, List<Map<String, Object?>>>{};
  bool failWrites = false;
  List<Map<String, Object?>> rows(String table) =>
      tables.putIfAbsent(table, () => []);
  @override
  dynamic noSuchMethod(Invocation i) {
    final table = i.positionalArguments.first as String;
    final args = i.namedArguments[#whereArgs] as List?;
    bool matches(Map row) =>
        args == null ||
        row[(i.namedArguments[#where] as String).split(' ').first] ==
            args.first;
    if (i.memberName == #query) {
      return Future<List<Map<String, Object?>>>.value(rows(table)
          .where(matches)
          .map((r) => Map<String, Object?>.from(r))
          .toList());
    }
    if (i.memberName == #delete) {
      rows(table).removeWhere(matches);
      return Future<int>.value(1);
    }
    if (i.memberName == #insert) {
      if (failWrites) return Future<int>.error(StateError("disk full"));
      final row = Map<String, Object?>.from(i.positionalArguments[1] as Map);
      rows(table).removeWhere((r) => r['id'] == row['id']);
      rows(table).add(row);
      return Future<int>.value(1);
    }
    if (i.memberName == #update) {
      for (final row in rows(table).where(matches)) {
        row.addAll(Map<String, Object?>.from(i.positionalArguments[1] as Map));
      }
      return Future<int>.value(1);
    }
    return super.noSuchMethod(i);
  }
}

class TestDb extends IDbService {
  @override
  final MemoryDb db = MemoryDb();
}

class ReplyLink extends Link {
  final Response reply;
  int calls = 0;
  ReplyLink(this.reply);
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    calls++;
    return Stream.value(reply);
  }
}

class SlowReplyLink extends ReplyLink {
  final accepted = Completer<void>();
  SlowReplyLink(super.reply);
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    calls++;
    return Future<Response>.delayed(const Duration(milliseconds: 120), () {
      accepted.complete();
      return reply;
    }).asStream();
  }
}

class FailingLink extends Link {
  int calls = 0;
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    calls++;
    return Stream.error(const ServerException(originalException: 'offline'));
  }
}

class GatedLink extends ReplyLink {
  final Future<Response> replyFuture;
  GatedLink(this.replyFuture) : super(Response(response: {}));
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    calls++;
    return replyFuture.asStream();
  }
}

GraphQLClient client(Link link) => GraphQLClient(
    link: BoundedRequestLink(const Duration(milliseconds: 80)).concat(link),
    cache: GraphQLCache(),
    queryRequestTimeout: null);
final noop = ReplyLink(Response(data: {}, response: {}));

class SuccessImageApi extends ImageApi {
  bool failTransport = false;
  int calls = 0;
  SuccessImageApi() : super(() => client(noop));
  @override
  Future<ImageSubmitResult> submit(ReportImage image) async {
    calls++;
    if (failTransport) {
      throw const ServerException(
          originalException: 'network lost during upload');
    }
    return ImageSubmitSuccess(IncidentReportImage.fromJson(
        {'id': image.id, 'file': '', 'imageUrl': '', 'thumbnail': ''}));
  }
}

class SuccessFileApi extends FileApi {
  SuccessFileApi() : super(() => client(noop));
  @override
  Future<FileSubmitResult> submit(ReportFile file) async =>
      FileSubmitSuccess(IncidentReportFile.fromJson(
          {'id': file.id, 'file': '', 'fileType': '', 'fileUrl': ''}));
}

class LoginReplies extends auth_fakes.FakeAuthApi {
  UserProfile profile;
  LoginReplies(this.profile);
  @override
  Future<AuthResult> tokenAuth(String username, String password) async =>
      AuthSuccess(
          token: auth_fakes.jwtWithExp(DateTime.now()
                  .add(const Duration(hours: 1))
                  .millisecondsSinceEpoch ~/
              1000),
          refreshToken: 'new-refresh',
          refreshExpiresIn: 0);
  @override
  Future<UserProfile> getUserProfile() async => profile;
}

class ObservationReplies extends ObservationApi {
  ObservationReplies() : super(() => client(noop));
  @override
  Future<SubjectRecordSubmitResult> submitSubjectRecord(
          SubjectRecord record) async =>
      SubjectRecordSubmitSuccess(ObservationSubjectRecord(
          id: 'remote-subject',
          definitionId: 1,
          isActive: true,
          title: 'subject',
          description: '',
          identity: 'subject',
          files: []));
  @override
  Future<MonitoringRecordSubmitResult> submitMonitoringRecord(
          MonitoringRecord record) async =>
      MonitoringRecordSubmitSuccess(ObservationMonitoringRecord(
          id: 'remote-monitoring',
          subjectId: 'remote-subject',
          monitoringDefinitionId: 1,
          title: 'monitoring',
          description: '',
          isActive: true,
          files: []));
}

class EmptyRecords extends IObservationRecordService {
  @override
  List<SubjectRecord> get pendingSubjectRecords => [];
  @override
  List<MonitoringRecord> get pendingMonitoringRecords => [];
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class TestConnectivity extends ConnectivityPlatform {
  final changes = StreamController<List<ConnectivityResult>>.broadcast();
  int checks = 0;
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => changes.stream;
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    checks++;
    return [ConnectivityResult.wifi];
  }
}

Report report(String id) => Report(
    id: id,
    data: {},
    reportTypeId: 'type-1',
    incidentDate: DateTime(2026, 11, 5),
    incidentInAuthority: true,
    testFlag: false);
Map<String, dynamic> validResponse(String id) => {
      'submitIncidentReport': {
        'result': {
          'id': id,
          'rendererData': 'summary',
          'incidentDate': '2026-11-05',
          'createdAt': '2026-11-05T00:00:00Z',
          'updatedAt': '2026-11-05T00:00:00Z',
          'reportType': {'id': 'type-1', 'name': 'Test', 'isFollowable': false},
          'testFlag': false,
        }
      }
    };
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late TestDb db;
  late ImageService images;
  late FileService files;
  late SuccessImageApi imageApi;
  late TestConnectivity connectivity;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await locator.reset();
    locator.registerSingleton<Logger>(Logger(level: Level.off));
    db = TestDb();
    locator.registerSingleton<IDbService>(db);
    imageApi = SuccessImageApi();
    locator.registerSingleton<ImageApi>(imageApi);
    locator.registerSingleton<FileApi>(SuccessFileApi());
    images = ImageService();
    files = FileService();
    locator.registerSingleton<IImageService>(images);
    locator.registerSingleton<IFileService>(files);
    locator.registerSingleton<IObservationRecordService>(EmptyRecords());
    connectivity = TestConnectivity();
    ConnectivityPlatform.instance = connectivity;
  });
  tearDown(() async {
    await connectivity.changes.close();
    await locator.reset();
  });
  Future<ReportService> service(ReplyLink link, List<Report> queue) async {
    locator.registerSingleton<ReportApi>(
        ReportApi(() => client(link))..baseLogger = null);
    for (final r in queue) {
      db.db.rows('report').add(r.toMap());
    }
    final s = ReportService();
    await s.init();
    locator.registerSingleton<IReportService>(s);
    return s;
  }

  test('server validation cause remains visible and the item stays durable',
      () async {
    final link = ReplyLink(Response(errors: [
      const GraphQLError(message: 'village is not assigned to reporter')
    ], response: {}));
    final s = await service(link, [report('r1')]);
    final vm = ReSubmitViewModel();
    await vm.submitAllPendings();
    expect(s.pendingReports.length, 1);
    expect(vm.submissionStates['r1'], Progress.fail);
    expect(vm.isSubmittingAll, false);
    expect(vm.submissionProblems['r1']!.kind, SubmissionProblemKind.validation);
    expect(vm.pendingReports.single.problem!.message,
        'village is not assigned to reporter');
    await vm.submitAllPendings();
    expect(link.calls, 2);
    expect(db.db.rows('report').length, 1);
    vm.dispose();
  });
  test('malformed response fails its row and the batch continues', () async {
    final data = validResponse('r1');
    ((data['submitIncidentReport'] as Map)['result'] as Map)
        .remove('rendererData');
    final link = ReplyLink(Response(data: data, response: {'data': data}));
    await service(link, [report('r1'), report('r2')]);
    final vm = ReSubmitViewModel();
    await vm.submitAllPendings();
    expect(vm.isSubmittingAll, false);
    expect(vm.submissionStates['r1'], Progress.fail);
    expect(vm.submissionStates['r2'], Progress.fail);
    expect(link.calls, 2);
    vm.dispose();
  });
  test(
      'accepted parent is removed while a failed image keeps its durable remote mapping',
      () async {
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    imageApi.failTransport = true;
    final data = validResponse('r1');
    final link = ReplyLink(Response(data: data, response: {'data': data}));
    final s = await service(link, [report('r1')]);
    final result = await s.submit(s.pendingReports.single);
    expect(result, isA<ReportSubmitSuccess>());
    expect(link.calls, 1);
    expect(db.db.rows('report'), isEmpty);
    expect(s.pendingReports, isEmpty);
    expect(images.pendingImages.single.id, 'i1');
    expect(db.db.rows('report_image').single['remote_parent_id'], 'r1');
  });
  test('successful DB-loaded image disappears from both queues', () async {
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    await images.init();
    await images.markForRemoteParent(
        localParentId: 'r1',
        parentType: 'incident_report',
        remoteParentId: 'r1');
    final loaded = (await images.findByReportId('r1')).single;
    expect(identical(loaded, images.pendingImages.single), false);
    expect(await images.submit(loaded), isA<ImageSubmitSuccess>());
    expect(db.db.rows('report_image'), isEmpty);
    expect(images.pendingImages, isEmpty);
  });
  test('successful DB-loaded file disappears from both queues', () async {
    await files.saveReportFile(ReportFile(
        'f1', 'r1', 'f.txt', '/nonexistent-audit/f.txt', 'txt', 'text/plain'));
    await files.init();
    await files.markForRemoteParent(
        localParentId: 'r1',
        parentType: 'incident_report',
        remoteParentId: 'r1');
    final loaded = (await files.findAllReportFilesByReportId('r1')).single;
    expect(await files.submit(loaded), isA<FileSubmitSuccess>());
    expect(db.db.rows('report_file'), isEmpty);
    expect(files.pendingReportFiles, isEmpty);
  });
  test(
      'initial connectivity check enables manual resend without a stream event',
      () async {
    final data = validResponse('r1');
    final link = ReplyLink(Response(data: data, response: {'data': data}));
    await service(link, [report('r1')]);
    final vm = ReSubmitViewModel();
    await Future<void>.delayed(Duration.zero);
    expect(vm.isOffline, false);
    expect(connectivity.checks, 1);
    connectivity.changes.add([ConnectivityResult.wifi]);
    await Future<void>.delayed(Duration.zero);
    expect(vm.isOffline, false);
    expect(link.calls, 0);
    vm.dispose();
  });
  test('bounded deadline preserves the report and ignores a late reply',
      () async {
    final data = validResponse('r1');
    final link = SlowReplyLink(Response(data: data, response: {'data': data}));
    final s = await service(link, [report('r1')]);
    final done = Completer<void>();
    final lateErrors = <Object>[];
    runZonedGuarded(() async {
      try {
        final watch = Stopwatch()..start();
        expect(await s.submit(s.pendingReports.single),
            isA<ReportSubmitPending>());
        expect(watch.elapsedMilliseconds, greaterThanOrEqualTo(70));
        expect(link.accepted.isCompleted, false);
        await link.accepted.future;
        await Future<void>.delayed(const Duration(milliseconds: 50));
        done.complete();
      } catch (error, stack) {
        done.completeError(error, stack);
      }
    }, (error, stack) {
      lateErrors.add(error);
    });
    await done.future;
    expect(lateErrors, isEmpty);
    expect(s.pendingReports.length, 1);
    expect(db.db.rows('report').length, 1);
  });
  test(
      'standalone image transport error settles its row and preserves the image',
      () async {
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    await images.init();
    imageApi.failTransport = true;
    await service(noop, []);
    final vm = ReSubmitViewModel();
    await vm.submitAllPendings();
    expect(vm.isSubmittingAll, false);
    expect(vm.submissionStates['i1'], Progress.fail);
    expect(vm.pendingImages.single.problem!.kind,
        SubmissionProblemKind.connection);
    expect(images.pendingImages.length, 1);
    vm.dispose();
  });
  test(
      'new report is saved before the API starts and concurrent submissions coalesce',
      () async {
    final data = validResponse('r1');
    final gate = Completer<Response>();
    final link = GatedLink(gate.future);
    final s = await service(link, []);
    final first = s.submit(report('r1'));
    final second = s.submit(report('r1'));
    await Future<void>.delayed(Duration.zero);
    expect(db.db.rows('report').single['id'], 'r1');
    expect(link.calls, 1);
    gate.complete(Response(data: data, response: {'data': data}));
    expect(await first, isA<ReportSubmitSuccess>());
    expect(await second, isA<ReportSubmitSuccess>());
    expect(link.calls, 1);
    expect(db.db.rows('report'), isEmpty);
  });
  test('parent failure retains attached media and survives service restart',
      () async {
    final link = ReplyLink(Response(
        errors: [const GraphQLError(message: 'invalid village')],
        response: {}));
    final s = await service(link, []);
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    expect(await s.submit(report('r1')), isA<ReportSubmitPending>());
    final restarted = ReportService();
    await restarted.init();
    expect(restarted.pendingReports.single.id, 'r1');
    expect(db.db.rows('report_image').single['id'], 'i1');
  });
  test(
      'owner persists across service restart and blocks another user/tenant with queued data',
      () async {
    final owner = QueueOwnershipService(db, 'https://original.test/graphql/');
    final user =
        UserProfile.fromJson({'id': 1, 'username': 'first', 'authorityId': 1});
    await owner.bind(user);
    db.db.rows('report').add(report('r1').toMap());
    final restarted =
        QueueOwnershipService(db, 'https://original.test/graphql/');
    await restarted.bind(user);
    await expectLater(
        restarted.bind(UserProfile.fromJson(
            {'id': 2, 'username': 'second', 'authorityId': 1})),
        throwsA(isA<SubmissionProblem>()));
    await expectLater(restarted.checkTenantChange('another.test'),
        throwsA(isA<SubmissionProblem>()));
    await restarted.checkTenantChange('original.test');
    expect(db.db.rows('report'), hasLength(1));
  });
  test(
      'legacy queue requires the original cached identity before a new login can adopt it',
      () async {
    db.db.rows('report').add(report('r1').toMap());
    final owner = QueueOwnershipService(db, 'https://original.test/graphql/');
    final user =
        UserProfile.fromJson({'id': 1, 'username': 'first', 'authorityId': 1});
    await expectLater(owner.bind(user), throwsA(isA<SubmissionProblem>()));
    await owner.bind(user, adoptLegacyQueue: true);
    await owner.bind(user);
    db.db.rows('report').clear();
    await owner.bind(UserProfile.fromJson(
        {'id': 2, 'username': 'second', 'authorityId': 1}));
  });
  test(
      'failed durable write does not claim a new report is queued or contact the server',
      () async {
    final link = ReplyLink(Response(response: {}));
    final s = await service(link, []);
    db.db.failWrites = true;
    final result = await s.submit(report('r1'));
    expect(result, isA<ReportSubmitFailure>());
    expect((result as ReportSubmitFailure).problem!.kind,
        SubmissionProblemKind.storage);
    expect(link.calls, 0);
    expect(s.pendingReports, isEmpty);
  });
  test(
      'real local file read failure stays visible and successful upload deletes the file',
      () async {
    final directory =
        await Directory.systemTemp.createTemp('ohtk-resend-test-');
    addTearDown(() => directory.delete(recursive: true));
    final path = '${directory.path}/attachment.txt';
    final attachment =
        ReportFile('f1', 'r1', 'attachment.txt', path, 'txt', 'text/plain');
    final reply = ReplyLink(Response(data: {
      'submitUploadFile': {
        'id': 'f1',
        'file': '',
        'fileType': 'text/plain',
        'fileUrl': ''
      }
    }, response: {}));
    locator.unregister<FileApi>();
    locator.registerSingleton<FileApi>(
        FileApi(() => client(reply))..baseLogger = null);
    final realFiles = FileService();
    await realFiles.saveReportFile(attachment);
    await realFiles.init();
    final missing = await realFiles.submit(attachment);
    expect(missing, isA<FileSubmitFailure>());
    expect((missing as FileSubmitFailure).problem!.kind,
        SubmissionProblemKind.localFile);
    expect(reply.calls, 0);
    expect(db.db.rows('report_file'), hasLength(1));
    await File(path).writeAsString('test attachment');
    expect(await realFiles.submit(attachment), isA<FileSubmitSuccess>());
    expect(await File(path).exists(), false);
    expect(db.db.rows('report_file'), isEmpty);
    expect(realFiles.pendingReportFiles, isEmpty);
  });
  test(
      'automatic refresh expiry preserves report and media across same-account recovery',
      () async {
    final storage = auth_fakes.MemorySecureStorage();
    final profile = UserProfile(
        id: 1,
        username: 'first',
        firstName: '',
        lastName: '',
        authorityName: '',
        authorityId: 1);
    storage.map['token'] = auth_fakes.jwtWithExp(DateTime.now()
            .subtract(const Duration(minutes: 1))
            .millisecondsSinceEpoch ~/
        1000);
    storage.map['refreshToken'] = 'expired-refresh';
    await storage.setUserProfile(profile);
    SharedPreferences.setMockInitialValues({'first_run': false});
    final owner = QueueOwnershipService(db, 'https://original.test/graphql/');
    locator.registerSingleton<QueueOwnershipService>(owner);
    db.db.rows('report').add(report('r1').toMap());
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    final api = auth_fakes.FakeAuthApi()
      ..refreshResult = AuthFailure(OperationException(
          graphqlErrors: [const GraphQLError(message: 'Refresh has expired')]));
    final auth = auth_fakes.buildAuthService(storage: storage, authApi: api);
    await auth.init();
    expect(auth.isLogin, false);
    expect(storage.map, isEmpty);
    expect(db.db.rows('report'), hasLength(1));
    expect(db.db.rows('report_image'), hasLength(1));
    // A fresh service/owner instance reads durable identity, with no old session.
    final restartedOwner =
        QueueOwnershipService(db, 'https://original.test/graphql/');
    await restartedOwner.bind(profile);
    await expectLater(
        restartedOwner.bind(UserProfile(
            id: 2,
            username: 'second',
            firstName: '',
            lastName: '',
            authorityName: '',
            authorityId: 1)),
        throwsA(isA<SubmissionProblem>()));
    await auth.logout();
    expect(db.db.rows('report'), hasLength(1));
    expect(db.db.rows('report_image'), hasLength(1));
  });
  test(
      'subject and monitoring acknowledgements persist distinct media routing after restart',
      () async {
    locator.registerSingleton<ObservationApi>(ObservationReplies());
    locator.unregister<IObservationRecordService>();
    final observations = ObservationRecordService();
    await observations.init();
    final subject = SubjectRecord(
        id: 'local-subject',
        data: {},
        definitionId: 1,
        definitionName: 'Subject',
        recordDate: DateTime(2026));
    final monitoring = MonitoringRecord(
        id: 'local-monitoring',
        data: {},
        subjectId: 'remote-subject',
        monitoringDefinitionId: 1,
        monitoringDefinitionName: 'Monitoring',
        recordDate: DateTime(2026));
    await images
        .saveImage(ReportImage('is', subject.id, Uint8List.fromList([1])));
    await images
        .saveImage(ReportImage('im', monitoring.id, Uint8List.fromList([1])));
    // The observation API in this test rejects uploads; only parents succeed.
    expect(await observations.submitSubjectRecord(subject),
        isA<SubjectRecordSubmitSuccess>());
    expect(await observations.submitMonitoringRecord(monitoring),
        isA<MonitoringRecordSubmitSuccess>());
    expect(db.db.rows('subject_record'), isEmpty);
    expect(db.db.rows('monitoring_record'), isEmpty);
    final restartedImages = ImageService();
    await restartedImages.init();
    expect(restartedImages.pendingImages.map((e) => e.effectiveParentId),
        containsAll(['remote-subject', 'remote-monitoring']));
    expect(restartedImages.pendingImages.map((e) => e.parentType),
        containsAll(['observation_subject', 'observation_monitoring']));
  });
  test(
      'batch pauses on connection failure and retains untouched rows without spinners',
      () async {
    final link = ReplyLink(Response(errors: [], response: {}));
    final s = await service(link, [report('r1'), report('r2')]);
    // A transport failure, rather than a per-report validation error.
    locator.unregister<ReportApi>();
    locator.unregister<IReportService>();
    final failing = FailingLink();
    locator.registerSingleton<ReportApi>(
        ReportApi(() => client(failing))..baseLogger = null);
    final retryService = ReportService();
    await retryService.init();
    locator.registerSingleton<IReportService>(retryService);
    final vm = ReSubmitViewModel();
    await vm.submitAllPendings();
    expect(failing.calls, 1);
    expect(vm.submissionStates['r1'], Progress.fail);
    expect(vm.submissionStates['r2'], isNull);
    expect(vm.batchProblem!.kind, SubmissionProblemKind.connection);
    expect(vm.isSubmittingAll, false);
    expect(s.pendingReports, hasLength(2));
    expect(db.db.rows('report'), hasLength(2));
    vm.dispose();
  });
  test(
      'a failed attachment is visible without being retried twice in its parent batch',
      () async {
    await images.saveImage(ReportImage('i1', 'r1', Uint8List.fromList([1])));
    imageApi.failTransport = true;
    final data = validResponse('r1');
    await service(ReplyLink(Response(data: data, response: {'data': data})),
        [report('r1')]);
    final vm = ReSubmitViewModel();
    await vm.submitAllPendings();
    expect(imageApi.calls, 1);
    expect(vm.pendingReports, isEmpty);
    expect(vm.pendingImages.single.state, Progress.fail);
    expect(vm.pendingImages.single.problem!.kind,
        SubmissionProblemKind.connection);
    expect(vm.isSubmittingAll, false);
    vm.dispose();
  });
  test(
      'actual login rejects a different owner and same-owner login can drain the preserved queue',
      () async {
    final profile = UserProfile(
        id: 1,
        username: 'original',
        firstName: '',
        lastName: '',
        authorityName: '',
        authorityId: 1);
    final owner = QueueOwnershipService(db, 'https://original.test/graphql/');
    locator.registerSingleton<QueueOwnershipService>(owner);
    await owner.bind(profile);
    db.db.rows('report').add(report('r1').toMap());
    final api = LoginReplies(profile);
    final auth = auth_fakes.buildAuthService(
        storage: auth_fakes.MemorySecureStorage(), authApi: api);
    locator.registerSingleton<IAuthService>(auth);
    await auth.authenticate('original', 'test');
    await auth.logout();
    expect(db.db.rows('report'), hasLength(1));
    api.profile = UserProfile(
        id: 2,
        username: 'other',
        firstName: '',
        lastName: '',
        authorityName: '',
        authorityId: 1);
    await expectLater(
        auth.authenticate('other', 'test'), throwsA(isA<SubmissionProblem>()));
    expect(auth.isLogin, false);
    expect(auth.accessToken, isNull);
    expect(db.db.rows('report'), hasLength(1));
    api.profile = profile;
    await auth.authenticate('original', 'test');
    expect(auth.isLogin, true);
    final data = validResponse('r1');
    final reports = await service(
        ReplyLink(Response(data: data, response: {'data': data})), []);
    expect(await reports.submit(reports.pendingReports.single),
        isA<ReportSubmitSuccess>());
    expect(db.db.rows('report'), isEmpty);
  });
}
