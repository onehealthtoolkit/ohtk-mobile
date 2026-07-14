import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/pending_media_parent_type.dart';
import 'package:podd_app/models/entities/report_image.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:stacked/stacked.dart';

abstract class IImageService with ListenableServiceMixin {
  List<ReportImage> get pendingImages;

  Future<void> saveImage(ReportImage reportImage);

  Future<ReportImage> getImage(String id);

  Future<void> removeImage(String id);

  Future<List<ReportImage>> findByReportId(String reportId);

  Future<void> removeAll();

  Future<void> remove(String reportId);

  Future<ImageSubmitResult> submit(ReportImage image);

  Future<List<ReportImage>> markForRemoteParent({
    required String localParentId,
    required String parentType,
    required String remoteParentId,
  });

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
  }

  init() async {
    var rows = await _dbService.db.query("report_image");
    rows.map((row) => ReportImage.fromMap(row)).forEach((image) {
      _pendingImages.add(image);
    });
  }

  @override
  List<ReportImage> get pendingImages => _pendingImages;

  @override
  Future<ImageSubmitResult> submit(ReportImage image) async {
    final recordType = PendingMediaParentType.recordTypeFor(image.parentType);
    final result = recordType == null
        ? await _imageApi.submit(image)
        : await _imageApi.submitObservationRecordImage(
            image,
            image.effectiveParentId,
            recordType,
          );
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
    await db.insert(
      "report_image",
      reportImage.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final pendingIndex =
        _pendingImages.indexWhere((image) => image.id == reportImage.id);
    if (pendingIndex != -1) {
      _pendingImages[pendingIndex] = reportImage;
    }
  }

  @override
  Future<List<ReportImage>> markForRemoteParent({
    required String localParentId,
    required String parentType,
    required String remoteParentId,
  }) async {
    final images = await findByReportId(localParentId);
    for (final image in images) {
      final updated = image.withRemoteParent(
        parentType: parentType,
        remoteParentId: remoteParentId,
      );
      await saveImage(updated);
    }
    return findByReportId(localParentId);
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
  Future<void> remove(String reportId) async {
    var images = await findByReportId(reportId);
    for (var image in images) {
      await removePendingImage(image.id);
    }
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
