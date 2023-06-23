import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/category.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/services/api/report_type_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stacked/stacked.dart';

abstract class IReportTypeService with ListenableServiceMixin {
  Future<List<ReportType>> fetchAllReportType();
  Future<ReportType?> getReportType(String id);
  Future<List<Category>> fetchAllCategory();
  Future<void> sync();
  Future<void> removeAll();
  bool get isReportTypeSynced;
  resetReportTypeSynced();
}

class ReportTypeService extends IReportTypeService {
  final _dbService = locator<IDbService>();

  final _reportTypeApi = locator<ReportTypeApi>();

  final ReactiveValue<bool> _isReportTypeSynced = ReactiveValue(false);

  ReportTypeService() {
    listenToReactiveValues([
      _isReportTypeSynced,
    ]);
  }

  @override
  bool get isReportTypeSynced => _isReportTypeSynced.value;

  @override
  resetReportTypeSynced() {
    _isReportTypeSynced.value = false;
  }

  @override
  Future<List<ReportType>> fetchAllReportType() async {
    var db = _dbService.db;
    var results = await db.query('report_type', orderBy: 'ordering');
    return results.map((item) => ReportType.fromMap(item)).toList();
  }

  @override
  Future<ReportType?> getReportType(String id) async {
    var db = _dbService.db;
    var results =
        await db.query('report_type', where: "id = ?", whereArgs: [id]);
    if (results.isNotEmpty) {
      return results.map((item) => ReportType.fromMap(item)).toList()[0];
    }
    return null;
  }

  @override
  Future<List<Category>> fetchAllCategory() async {
    var db = _dbService.db;
    var results = await db.query('category', orderBy: 'ordering');
    return results.map((item) => Category.fromMap(item)).toList();
  }

  @override
  sync() async {
    var db = _dbService.db;

    var oldReportTypes = await fetchAllReportType();
    // sync from server
    ReportTypeSyncOutputType result =
        await _reportTypeApi.syncReportTypes(oldReportTypes
            .map((rt) => ReportTypeSyncInputType(
                  id: rt.id,
                  updatedAt: DateTime.parse(rt.updatedAt),
                ))
            .toList());
    for (var category in result.categoryList) {
      await db.insert(
        'category',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // delete
    if (result.removedList.isNotEmpty) {
      await db.delete(
        'report_type',
        where: 'id in (?)',
        whereArgs: [result.removedList.toString()],
      );
    }

    for (var reportType in result.updatedList) {
      await db.insert(
        'report_type',
        reportType.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    _isReportTypeSynced.value = true;
  }

  @override
  Future<void> removeAll() async {
    var db = _dbService.db;
    await db.delete('report_type');
  }
}
