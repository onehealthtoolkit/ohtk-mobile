import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/services/db_service.dart';

abstract class IImageService {
  Future<void> saveImage(ReportImage reportImage);

  Future<ReportImage> getImage(String id);

  Future<void> removeImage(String id);

  Future<List<ReportImage>> findByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String id);
}

class ImageService extends IImageService {
  final IDbService _dbService = locator<IDbService>();

  @override
  Future<void> saveImage(ReportImage reportImage) async {
    var _db = _dbService.db;
    await _db.insert("report_image", reportImage.toMap());
  }

  @override
  Future<ReportImage> getImage(String id) async {
    var _db = _dbService.db;
    var results = await _db.query(
      'report_image',
      where: "id = ?",
      whereArgs: [
        id,
      ],
    );
    if (results.isNotEmpty) {
      return ReportImage.fromMap(results[0]);
    }

    throw "import not found";
  }

  @override
  Future<void> removeImage(String id) async {
    var _db = _dbService.db;
    await _db.delete("report_image", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ReportImage>> findByReportId(String reportId) async {
    var _db = _dbService.db;
    var results = await _db.query(
      'report_image',
      where: "reportId = ?",
      whereArgs: [
        reportId,
      ],
    );
    return results.map((row) => ReportImage.fromMap(row)).toList();
  }

  @override
  Future<void> removeAll() async {
    var _db = _dbService.db;
    await _db.delete("report_image");
  }

  @override
  Future<void> remove(String id) async {
    var _db = _dbService.db;
    await _db.delete("report_image", where: "reportId = ?", whereArgs: [id]);
  }
}
