import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:stacked/stacked.dart';

abstract class IImageService with ReactiveServiceMixin {
  List<ReportImage> get pendingImages;

  Future<void> saveImage(ReportImage reportImage);

  Future<ReportImage> getImage(String id);

  Future<void> removeImage(String id);

  Future<List<ReportImage>> findByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String id);

  Future<ImageSubmitResult> submit(ReportImage image);

  Future<ImageSubmitResult> submitObservationRecordImage(
    ReportImage image,
    String recordId,
    String recordType,
  );

  Future<void> removeAllPendingImages();

  Future<void> removePendingImage(String id);
}

class ImageService extends IImageService {
  final IDbService _dbService = locator<IDbService>();
  final _imageApi = locator<ImageApi>();

  final _pendingImages = ReactiveList<ReportImage>();

  ImageService() {
    listenToReactiveValues([_pendingImages]);
    _init();
  }

  _init() async {
    var rows = await _dbService.db.query("report_image");
    rows.map((row) => ReportImage.fromMap(row)).forEach((image) {
      _pendingImages.add(image);
    });
  }

  @override
  List<ReportImage> get pendingImages => _pendingImages;

  @override
  Future<ImageSubmitResult> submit(ReportImage image) async {
    var result = await _imageApi.submit(image);
    if (result is ImageSubmitSuccess) {
      await removeImage(image.id);
      _pendingImages.remove(image);
    }
    if (result is ImageSubmitFailure) {
      _pendingImages.addIf(
          _pendingImages.indexWhere((element) => element.id == image.id) == -1,
          image);
    }
    return result;
  }

  @override
  Future<ImageSubmitResult> submitObservationRecordImage(
    ReportImage image,
    String recordId,
    String recordType,
  ) async {
    var result = await _imageApi.submitObservationRecordImage(
        image, recordId, recordType);
    if (result is ImageSubmitSuccess) {
      await removeImage(image.id);
      _pendingImages.remove(image);
    }
    if (result is ImageSubmitFailure) {
      _pendingImages.addIf(
          _pendingImages.indexWhere((element) => element.id == image.id) == -1,
          image);
    }
    return result;
  }

  @override
  Future<void> saveImage(ReportImage reportImage) async {
    var db = _dbService.db;
    await db.insert("report_image", reportImage.toMap());
  }

  @override
  Future<ReportImage> getImage(String id) async {
    var db = _dbService.db;
    var results = await db.query(
      'report_image',
      where: "id = ?",
      whereArgs: [
        id,
      ],
    );
    if (results.isNotEmpty) {
      return ReportImage.fromMap(results[0]);
    }

    throw "Image not found";
  }

  @override
  Future<void> removeImage(String id) async {
    var db = _dbService.db;
    await db.delete("report_image", where: "id = ?", whereArgs: [id]);
  }

  @override
  Future<List<ReportImage>> findByReportId(String reportId) async {
    var db = _dbService.db;
    var results = await db.query(
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
    var db = _dbService.db;
    await db.delete("report_image");
  }

  @override
  Future<void> remove(String id) async {
    var db = _dbService.db;
    await db.delete("report_image", where: "reportId = ?", whereArgs: [id]);
  }

  @override
  Future<void> removeAllPendingImages() async {
    await removeAll();
    _pendingImages.clear();
  }

  @override
  Future<void> removePendingImage(String id) async {
    await removeImage(id);
    try {
      var image = _pendingImages.firstWhere((r) => r.id == id);
      _pendingImages.remove(image);
    } catch (e) {
      /// not found
    }
  }
}
