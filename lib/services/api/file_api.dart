import "package:dio/dio.dart" as dio;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/report_file.dart';
import 'package:podd_app/models/file_submit_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class FileApi extends GraphQlBaseApi {
  FileApi(ResolveGraphqlClient client) : super(client);

  Future<FileSubmitResult> submit(ReportFile reportFile) async {
    const mutation = r'''
      mutation submitUploadFile(
        $file: Upload!,
        $fileId: UUID,
        $reportId: UUID
      ) {
        submitUploadFile(file: $file, fileId: $fileId, reportId: $reportId) {
          id
          file
          fileType
          fileUrl
        }
      }
    ''';

    final fileBytes = await reportFile.localFile!.readAsBytes();
    var file = dio.MultipartFile.fromBytes(
      fileBytes,
      filename: reportFile.id,
    );

    try {
      var result = await runGqlMutation<IncidentReportFile>(
          mutation: mutation,
          parseData: (json) => IncidentReportFile.fromJson(json!),
          variables: {
            "file": file,
            "fileId": reportFile.id,
            "reportId": reportFile.reportId
          });

      return FileSubmitSuccess(result);
    } on OperationException catch (e) {
      return FileSubmitFailure(e);
    }
  }

  Future<FileSubmitResult> submitObservationRecordFile(
      ReportFile recordFile, String recordId) async {
    const mutation = r'''
      mutation submitRecordUploadFile(
        $file: Upload!,
        $fileId: UUID,
        $recordId: UUID!
      ) {
        submitRecordUploadFile(
          file: $file, 
          fileId: $fileId, 
          recordId: $recordId
        ) {
          id
          file
          fileType
          fileUrl
        }
      }
    ''';

    final fileBytes = await recordFile.localFile!.readAsBytes();
    var file = dio.MultipartFile.fromBytes(
      fileBytes,
      filename: recordFile.id,
    );

    try {
      var result = await runGqlMutation<ObservationRecordFile>(
          mutation: mutation,
          parseData: (json) => ObservationRecordFile.fromJson(json!),
          variables: {
            "file": file,
            "fileId": recordFile.id,
            "recordId": recordId,
          });

      return FileSubmitSuccess(result);
    } on OperationException catch (e) {
      return FileSubmitFailure(e);
    }
  }
}
