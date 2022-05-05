import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/category.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/services/report_type_service.dart';
import 'package:stacked/stacked.dart';

class ReportTypeViewModel extends BaseViewModel {
  final IReportTypeService _reportTypeService = locator<IReportTypeService>();

  List<CategoryAndReportType> _categories = [];

  List<CategoryAndReportType> get categories => _categories;

  ReportTypeViewModel() {
    setBusy(true);
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
