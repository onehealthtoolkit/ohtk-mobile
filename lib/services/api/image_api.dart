import "package:dio/dio.dart" as dio;
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:podd_app/models/entities/incident_report.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/services/api/graph_ql_base_api.dart';

class ImageApi extends GraphQlBaseApi {
  ImageApi(ResolveGraphqlClient client) : super(client);

  Future<ImageSubmitResult> submit(ReportImage reportImage) async {
    const mutation = r'''
      mutation submitImage(
        $image: Upload!,
        $imageId: UUID,
        $reportId: UUID
      ) {
        submitImage(image: $image, imageId: $imageId, reportId: $reportId) {
          id
          file
          thumbnail
          imageUrl
        }
      }
    ''';

    var file = dio.MultipartFile.fromBytes(
      reportImage.image,
      filename: reportImage.id,
    );

    try {
      var result = await runGqlMutation<IncidentReportImage>(
          mutation: mutation,
          parseData: (json) => IncidentReportImage.fromJson(json!),
          variables: {
            "image": file,
            "imageId": reportImage.id,
            "reportId": reportImage.reportId
          });

      return ImageSubmitSuccess(result);
    } on OperationException catch (e) {
      return ImageSubmitFailure(e);
    }
  }

  Future<ImageSubmitResult> submitObservationImage(
    ReportImage reportImage,
    String observationRefId,
    String observationImageType,
  ) async {
    const mutation = r'''
      mutation submitRecordImage(
        $recordType: RecordType!,
        $image: Upload!,
        $imageId: UUID,
        $recordId: UUID!
      ) {
        submitRecordImage(
          recordType: $recordType,
          image: $image, 
          imageId: $imageId, 
          recordId: $recordId
        ) {
          id
          file
          thumbnail
          imageUrl
        }
      }
    ''';

    var file = dio.MultipartFile.fromBytes(
      reportImage.image,
      filename: reportImage.id,
    );

    try {
      var result = await runGqlMutation<ObservationRecordImage>(
          mutation: mutation,
          parseData: (json) => ObservationRecordImage.fromJson(json!),
          variables: {
            "recordType": observationImageType,
            "image": file,
            "imageId": reportImage.id,
            "recordId": observationRefId
          });

      return ImageSubmitSuccess(result);
    } on OperationException catch (e) {
      return ImageSubmitFailure(e);
    }
  }
}
