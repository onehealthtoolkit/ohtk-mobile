import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/pending_media_parent_type.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/services/api/file_api.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/file_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:sqflite/sqflite.dart';

class NoopLink extends Link {
  @override
  Stream<Response> request(Request request, [NextLink? forward]) {
    return const Stream.empty();
  }
}

class ThrowingDbService extends IDbService {
  @override
  Database get db => throw UnimplementedError();
}

class FakeImageApi extends ImageApi {
  String? incidentReportId;
  String? observationRecordId;
  String? observationRecordType;

  FakeImageApi()
      : super(
          () => GraphQLClient(
            link: NoopLink(),
            cache: GraphQLCache(),
          ),
        );

  @override
  Future<ImageSubmitResult> submit(ReportImage reportImage) async {
    incidentReportId = reportImage.effectiveParentId;
    return ImageSubmitFailure(_failure('incident image failed'));
  }

  @override
  Future<ImageSubmitResult> submitObservationRecordImage(
    ReportImage recordImage,
    String recordId,
    String recordType,
  ) async {
    observationRecordId = recordId;
    observationRecordType = recordType;
    return ImageSubmitFailure(_failure('observation image failed'));
  }
}

class FakeFileApi extends FileApi {
  String? incidentReportId;
  String? observationRecordId;

  FakeFileApi()
      : super(
          () => GraphQLClient(
            link: NoopLink(),
            cache: GraphQLCache(),
          ),
        );

  @override
  Future<FileSubmitResult> submit(ReportFile reportFile) async {
    incidentReportId = reportFile.effectiveParentId;
    return FileSubmitFailure(_failure('incident file failed'));
  }

  @override
  Future<FileSubmitResult> submitObservationRecordFile(
    ReportFile recordFile,
    String recordId,
  ) async {
    observationRecordId = recordId;
    return FileSubmitFailure(_failure('observation file failed'));
  }
}

OperationException _failure(String message) {
  return OperationException(
    graphqlErrors: [GraphQLError(message: message)],
  );
}

void main() {
  setUp(() async {
    await locator.reset();
    locator.registerSingleton<Logger>(Logger());
    locator.registerSingleton<IDbService>(ThrowingDbService());
  });

  test('legacy media rows default to incident report parents', () {
    final image = ReportImage.fromMap({
      'id': 'image-1',
      'reportId': 'local-report-1',
      'image': Uint8List.fromList([1, 2, 3]),
    });
    final file = ReportFile.fromMap({
      'id': 'file-1',
      'report_id': 'local-report-1',
      'name': 'result.pdf',
      'file_path': '/missing/result.pdf',
      'file_extension': 'pdf',
      'file_type': 'application/pdf',
    });

    expect(image.parentType, PendingMediaParentType.incidentReport);
    expect(image.effectiveParentId, 'local-report-1');
    expect(file.parentType, PendingMediaParentType.incidentReport);
    expect(file.effectiveParentId, 'local-report-1');
  });

  test('image retry routes observation subject media to observation endpoint',
      () async {
    final api = FakeImageApi();
    locator.registerSingleton<ImageApi>(api);
    final service = ImageService();
    final image = ReportImage(
      'image-1',
      'local-subject-1',
      Uint8List.fromList([1, 2, 3]),
      parentType: PendingMediaParentType.observationSubject,
      remoteParentId: 'remote-subject-1',
    );

    await service.submit(image);

    expect(api.incidentReportId, isNull);
    expect(api.observationRecordId, 'remote-subject-1');
    expect(api.observationRecordType, 'subject');
  });

  test('file retry routes observation monitoring media to observation endpoint',
      () async {
    final api = FakeFileApi();
    locator.registerSingleton<FileApi>(api);
    final service = FileService();
    final file = ReportFile(
      'file-1',
      'local-monitoring-1',
      'monitoring.pdf',
      '/missing/monitoring.pdf',
      'pdf',
      'application/pdf',
      parentType: PendingMediaParentType.observationMonitoring,
      remoteParentId: 'remote-monitoring-1',
    );

    await service.submit(file);

    expect(api.incidentReportId, isNull);
    expect(api.observationRecordId, 'remote-monitoring-1');
  });
}
