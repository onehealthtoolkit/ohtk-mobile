import 'package:podd_app/locator.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/image_service.dart';

abstract class IReportService {
  Future<ReportSubmitResult> submit({
    required String reportId,
    required String reportTypeId,
    required Map<String, dynamic> data,
    required DateTime incidentDate,
    String? gpsLocation,
  });
}

class ReportService extends IReportService {
  final _reportApi = locator<ReportApi>();
  final _imageApi = locator<ImageApi>();
  final _imageService = locator<IImageService>();

  @override
  submit({
    required String reportId,
    required String reportTypeId,
    required Map<String, dynamic> data,
    required DateTime incidentDate,
    String? gpsLocation,
  }) async {
    var result = await _reportApi.submit(
        reportId, reportTypeId, data, incidentDate, gpsLocation);
    if (result is ReportSubmitSuccess) {
      // submit images
      var images = await _imageService.findByReportId(reportId);
      for (var image in images) {
        _imageApi.submit(image);
      }
    }

    return result;
  }
}
