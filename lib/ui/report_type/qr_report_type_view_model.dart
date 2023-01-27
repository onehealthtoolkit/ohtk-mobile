import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:stacked/stacked.dart';

class QrReportTypeViewModel extends BaseViewModel {
  final _reportTypeService = locator<IReportTypeService>();
  final _logger = locator<Logger>();

  Future<ReportType?> getReportType(String id) async {
    setBusy(true);
    var result = await _reportTypeService.getReportType(id);
    _logger.d("scan result: report type id=${result?.id}");
    setBusy(false);
    return result;
  }
}
