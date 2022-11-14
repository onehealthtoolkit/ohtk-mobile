import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/category.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/models/report_submit_result.dart';
import 'package:podd_app/services/api/report_api.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

const zeroReportDateTimeKey = "latest_zero_report_datetime";

class ReportTypeViewModel extends BaseViewModel {
  final IReportTypeService _reportTypeService = locator<IReportTypeService>();
  final ReportApi _reportApi = locator<ReportApi>();
  final Logger _logger = locator<Logger>();

  List<CategoryAndReportType> _categories = [];

  List<CategoryAndReportType> get categories => _categories;

  ReportTypeViewModel() {
    setBusy(true);
    _reportTypeService.resetReportTypeSynced();
    fetch();
    setBusy(false);
  }

  fetch() async {
    var categories = await _reportTypeService.fetchAllCategory();
    var reportTypes = await _reportTypeService.fetchAllReportType();

    _categories = categories
        .map((c) => CategoryAndReportType(
              c,
              reportTypes
                  .where((element) => element.categoryId == c.id)
                  .toList(),
            ))
        .toList();
    notifyListeners();
  }

  Future<bool> createReport(String reportTypeId) async {
    return true;
  }

  Future<DateTime?> getLatestZeroReport() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(zeroReportDateTimeKey);
    if (millis != null) {
      return DateTime.fromMillisecondsSinceEpoch(millis);
    }
    return null;
  }

  submitZeroReport() async {
    try {
      var result = await _reportApi.submitZeroReport();

      if (result is ZeroReportSubmitSuccess) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(
            zeroReportDateTimeKey, DateTime.now().millisecondsSinceEpoch);
        notifyListeners();
      }

      if (result is ZeroReportSubmitFailure) {
        _logger.e(result.messages);
      }
    } on LinkException catch (_e) {
      _logger.e(_e);
    }
  }

  syncReportTypes() async {
    setBusy(true);
    await _reportTypeService.sync();
    await fetch();
    setBusy(false);
  }
}

class CategoryAndReportType {
  Category category;
  List<ReportType> reportTypes;
  CategoryAndReportType(this.category, this.reportTypes);
}
