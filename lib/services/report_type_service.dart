import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/category.dart';
import 'package:podd_app/models/entities/report_type.dart';
import 'package:podd_app/services/api/report_type_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:sqflite/sqflite.dart';

abstract class IReportTypeService {
  Future<List<ReportType>> fetchAllReportType();
  Future<List<Category>> fetchAllCategory();
  Future<void> sync();
  Future<void> removeAll();
}

class ReportTypeService extends IReportTypeService {
  final _dbService = locator<IDbService>();

  final _reportTypeApi = locator<ReportTypeApi>();

  @override
  Future<List<ReportType>> fetchAllReportType() async {
    var _db = _dbService.db;
    var results = await _db.query('report_type', orderBy: 'ordering');
    return results.map((item) => ReportType.fromMap(item)).toList();
  }

  @override
  Future<List<Category>> fetchAllCategory() async {
    var _db = _dbService.db;
    var results = await _db.query('category', orderBy: 'ordering');
    return results.map((item) => Category.fromMap(item)).toList();
  }

  @override
  sync() async {
    var _db = _dbService.db;

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
      await _db.insert(
        'category',
        category.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    // delete
    if (result.removedList.isNotEmpty) {
      await _db.delete('report_type',
          where: 'id in (?)',
          whereArgs: result.removedList.map((e) => e.id).toList());
    }

    for (var reportType in result.updatedList) {
      await _db.insert(
        'report_type',
        reportType.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  @override
  Future<void> removeAll() async {
    var _db = _dbService.db;
    await _db.delete('report_type');
  }
}
