import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/entities/observation_subject_report.dart';
import 'package:podd_app/models/image_submit_result.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/services/api/image_api.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:podd_app/services/image_service.dart';
import 'package:stacked/stacked.dart';

abstract class IObservationService with ReactiveServiceMixin {
  final _logger = locator<Logger>();

  List<ObservationSubject> get observationSubjects;

  List<ObservationSubjectMonitoring> get observationSubjectMonitorings;

  List<ObservationSubjectReport> get observationSubjectReports;

  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();

  Future<void> fetchAllObservationSubjects(bool resetFlag, int definitionId);

  Future<ObservationSubject> getObservationSubject(int id);

  Future<void> fetchAllObservationSubjectMonitorings(int subjectId);

  Future<ObservationSubjectMonitoring> getObservationSubjectMonitoring(int id);

  Future<void> fetchAllObservationSubjectReports(int subjectId);

  Future<ObservationSubjectSubmitResult> submitReportSubject(
      ObservationReportSubject report);

  Future<ObservationMonitoringRecordSubmitResult> submitReportMonitoringRecord(
      ObservationReportMonitoringRecord report);

  fetchAllObservationSubjectsInBounded(int definitionId, double topLeftX,
      double topLeftY, double bottomRightX, double bottomRightY) {}
}

class ObservationService extends IObservationService {
  final _dbService = locator<IDbService>();
  final _imageApi = locator<ImageApi>();
  final _imageService = locator<IImageService>();
  final _observationApi = locator<ObservationApi>();

  final ReactiveList<ObservationSubject> _observationSubjects =
      ReactiveList<ObservationSubject>();

  final ReactiveList<ObservationSubjectMonitoring>
      _observationSubjectMonitorings =
      ReactiveList<ObservationSubjectMonitoring>();

  final ReactiveList<ObservationSubjectReport> _observationSubjectReports =
      ReactiveList<ObservationSubjectReport>();

  bool hasMoreObservationSubjects = false;
  int currentObservationSubjectNextOffset = 0;
  int observationSubjectLimit = 20;

  ObservationService() {
    listenToReactiveValues([
      _observationSubjects,
      _observationSubjectMonitorings,
      _observationSubjectReports,
    ]);
  }

  @override
  List<ObservationSubject> get observationSubjects => _observationSubjects;

  @override
  List<ObservationSubjectMonitoring> get observationSubjectMonitorings =>
      _observationSubjectMonitorings;

  @override
  List<ObservationSubjectReport> get observationSubjectReports =>
      _observationSubjectReports;

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    var result = await _observationApi.fetchObservationDefinitions();
    return result.data;
  }

  @override
  Future<void> fetchAllObservationSubjects(
      bool resetFlag, int definitionId) async {
    if (resetFlag) {
      currentObservationSubjectNextOffset = 0;
    }
    var result = await _observationApi.fetchObservationSubjects(definitionId);

    if (resetFlag) {
      _observationSubjects.clear();
    }

    _observationSubjects.addAll(result.data);
    hasMoreObservationSubjects = result.hasNextPage;
    currentObservationSubjectNextOffset =
        currentObservationSubjectNextOffset + observationSubjectLimit;
  }

  @override
  Future<ObservationSubject> getObservationSubject(int id) async {
    var result = await _observationApi.getObservationSubject(id);
    var monitoringRecords = result.data.monitoringRecords;

    _observationSubjectMonitorings.clear();
    _observationSubjectMonitorings.addAll(monitoringRecords);

    return result.data;
  }

  @override
  Future<void> fetchAllObservationSubjectMonitorings(int subjectId) async {
    var result =
        await _observationApi.fetchObservationMonitoringRecords(subjectId);
    _observationSubjectMonitorings.clear();
    _observationSubjectMonitorings.addAll(result.data);
  }

  @override
  Future<ObservationSubjectMonitoring> getObservationSubjectMonitoring(
      int id) async {
    var result = await _observationApi.getObservationMonitoringRecord(id);
    return result.data;
  }

  @override
  Future<void> fetchAllObservationSubjectReports(int subjectId) async {
    // TODO call fetchSubjectReports api
    // _observationSubjectReports.clear();
    // _observationSubjectReports.addAll(result.data);
  }

  @override
  Future<ObservationSubjectSubmitResult> submitReportSubject(
      ObservationReportSubject report) async {
    try {
      var result = await _observationApi.submitReportSubject(report);

      if (result is ObservationSubjectSubmitSuccess) {
        // TODO delete from local db
        result.subject.images = List.of([]);

        // submit images
        var localImages = await _imageService.findByReportId(report.id);
        for (var img in localImages) {
          var submitImageResult = await _imageApi.submitObservationImage(
              img, result.subject.id, "subject");
          if (submitImageResult is ImageSubmitSuccess) {
            result.subject.images!
                .add(submitImageResult.image as ObservationReportImage);
          }

          if (submitImageResult is ImageSubmitFailure) {
            _logger.e("Submit image error: ${submitImageResult.messages}");
          }
        }
        _observationSubjects.insert(0, result.subject);
      }

      if (result is ObservationSubjectSubmitFailure) {
        // TODO save to local db
        return ObservationSubjectSubmitPending();
      }
      return result;
    } on LinkException catch (_e) {
      _logger.e(_e);
      // TODO save to local db
      return ObservationSubjectSubmitPending();
    }
  }

  @override
  Future<ObservationMonitoringRecordSubmitResult> submitReportMonitoringRecord(
      ObservationReportMonitoringRecord report) async {
    try {
      var result = await _observationApi.submitReportMonitoringRecord(report);

      if (result is ObservationMonitoringRecordSubmitSuccess) {
        // TODO delete from local db
        result.monitoringRecord.images = List.of([]);

        // submit images
        var localImages = await _imageService.findByReportId(report.id);
        for (var img in localImages) {
          var submitImageResult = await _imageApi.submitObservationImage(
              img, result.monitoringRecord.id, "monitoring");
          if (submitImageResult is ImageSubmitSuccess) {
            result.monitoringRecord.images!
                .add(submitImageResult.image as ObservationReportImage);
          }

          if (submitImageResult is ImageSubmitFailure) {
            _logger.e("Submit image error: ${submitImageResult.messages}");
          }

          _observationSubjectMonitorings.insert(0, result.monitoringRecord);
        }
      }

      if (result is ObservationMonitoringRecordSubmitFailure) {
        // TODO save to local db
        return ObservationMonitoringRecordSubmitPending();
      }
      return result;
    } on LinkException catch (_e) {
      _logger.e(_e);
      // TODO save to local db
      return ObservationMonitoringRecordSubmitPending();
    }
  }

  @override
  Future<List<ObservationSubject>> fetchAllObservationSubjectsInBounded(
      int definitionId,
      double topLeftX,
      double topLeftY,
      double bottomRightX,
      double bottomRightY) async {
    print(
        "topLeftX: $topLeftX, topLeftY: $topLeftY, bottomRightX: $bottomRightX, bottomRightY: $bottomRightY");
    var result = await _observationApi.fetchObservationSubjectsInBounded(
        definitionId, topLeftX, topLeftY, bottomRightX, bottomRightY);
    return result;
  }
}
