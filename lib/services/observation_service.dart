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

  List<ObservationSubjectRecord> get subjectRecords;

  List<ObservationMonitoringRecord> get monitoringRecords;

  List<ObservationSubjectReport> get observationSubjectReports;

  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();

  Future<void> fetchAllSubjectRecords(bool resetFlag, int definitionId);

  Future<ObservationSubjectRecord> getSubject(String id);

  Future<void> fetchAllMonitoringRecords(String subjectId);

  Future<ObservationMonitoringRecord> getMonitoringRecord(String id);

  Future<void> fetchAllObservationSubjectReports(int subjectId);

  Future<SubjectRecordSubmitResult> submitSubjectRecord(SubjectRecord report);

  Future<MonitoringRecordSubmitResult> submitMonitoringRecord(
      MonitoringRecord report);

  fetchAllSubjectRecordsInBounded(int definitionId, double topLeftX,
      double topLeftY, double bottomRightX, double bottomRightY) {}
}

class ObservationService extends IObservationService {
  final _dbService = locator<IDbService>();
  final _imageApi = locator<ImageApi>();
  final _imageService = locator<IImageService>();
  final _observationApi = locator<ObservationApi>();

  final ReactiveList<ObservationSubjectRecord> _subjectRecords =
      ReactiveList<ObservationSubjectRecord>();

  final ReactiveList<ObservationMonitoringRecord> _monitoringRecords =
      ReactiveList<ObservationMonitoringRecord>();

  final ReactiveList<ObservationSubjectReport> _observationSubjectReports =
      ReactiveList<ObservationSubjectReport>();

  bool hasMoreSubjectRecords = false;
  int currentSubjectRecordNextOffset = 0;
  int subjectRecordLimit = 20;

  ObservationService() {
    listenToReactiveValues([
      _subjectRecords,
      _monitoringRecords,
      _observationSubjectReports,
    ]);
  }

  @override
  List<ObservationSubjectRecord> get subjectRecords => _subjectRecords;

  @override
  List<ObservationMonitoringRecord> get monitoringRecords => _monitoringRecords;

  @override
  List<ObservationSubjectReport> get observationSubjectReports =>
      _observationSubjectReports;

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    var result = await _observationApi.fetchObservationDefinitions();
    return result.data;
  }

  @override
  Future<void> fetchAllSubjectRecords(bool resetFlag, int definitionId) async {
    if (resetFlag) {
      currentSubjectRecordNextOffset = 0;
    }
    var result = await _observationApi.fetchSubjectRecords(definitionId);

    if (resetFlag) {
      _subjectRecords.clear();
    }

    _subjectRecords.addAll(result.data);
    hasMoreSubjectRecords = result.hasNextPage;
    currentSubjectRecordNextOffset =
        currentSubjectRecordNextOffset + subjectRecordLimit;
  }

  @override
  Future<ObservationSubjectRecord> getSubject(String id) async {
    var result = await _observationApi.getSubjectRecord(id);
    var monitoringRecords = result.data.monitoringRecords;

    _monitoringRecords.clear();
    _monitoringRecords.addAll(monitoringRecords);

    return result.data;
  }

  @override
  Future<void> fetchAllMonitoringRecords(String subjectId) async {
    var result = await _observationApi.fetchMonitoringRecords(subjectId);
    _monitoringRecords.clear();
    _monitoringRecords.addAll(result.data);
  }

  @override
  Future<ObservationMonitoringRecord> getMonitoringRecord(String id) async {
    var result = await _observationApi.getMonitoringRecord(id);
    return result.data;
  }

  @override
  Future<void> fetchAllObservationSubjectReports(int subjectId) async {
    // TODO call fetchSubjectReports api
    // _observationSubjectReports.clear();
    // _observationSubjectReports.addAll(result.data);
  }

  @override
  Future<SubjectRecordSubmitResult> submitSubjectRecord(
      SubjectRecord report) async {
    try {
      var result = await _observationApi.submitSubjectRecord(report);

      if (result is SubjectRecordSubmitSuccess) {
        // TODO delete from local db
        result.subject.images = List.of([]);

        // submit images
        var localImages = await _imageService.findByReportId(report.id);
        for (var img in localImages) {
          var submitImageResult = await _imageApi.submitObservationImage(
              img, result.subject.id, "subject");
          if (submitImageResult is ImageSubmitSuccess) {
            result.subject.images!
                .add(submitImageResult.image as ObservationRecordImage);
          }

          if (submitImageResult is ImageSubmitFailure) {
            _logger.e("Submit image error: ${submitImageResult.messages}");
          }
        }
        _subjectRecords.insert(0, result.subject);
      }

      if (result is SubjectRecordSubmitFailure) {
        // TODO save to local db
        return SubjectRecordSubmitPending();
      }
      return result;
    } on LinkException catch (_e) {
      _logger.e(_e);
      // TODO save to local db
      return SubjectRecordSubmitPending();
    }
  }

  @override
  Future<MonitoringRecordSubmitResult> submitMonitoringRecord(
      MonitoringRecord report) async {
    try {
      var result = await _observationApi.submitMonitoringRecord(report);

      if (result is MonitoringRecordSubmitSuccess) {
        // TODO delete from local db
        result.monitoringRecord.images = List.of([]);

        // submit images
        var localImages = await _imageService.findByReportId(report.id);
        for (var img in localImages) {
          var submitImageResult = await _imageApi.submitObservationImage(
              img, result.monitoringRecord.id, "monitoring");
          if (submitImageResult is ImageSubmitSuccess) {
            result.monitoringRecord.images!
                .add(submitImageResult.image as ObservationRecordImage);
          }

          if (submitImageResult is ImageSubmitFailure) {
            _logger.e("Submit image error: ${submitImageResult.messages}");
          }
        }
        _monitoringRecords.insert(0, result.monitoringRecord);
      }

      if (result is MonitoringRecordSubmitFailure) {
        // TODO save to local db
        return MonitoringRecordSubmitPending();
      }
      return result;
    } on LinkException catch (_e) {
      _logger.e(_e);
      // TODO save to local db
      return MonitoringRecordSubmitPending();
    }
  }

  @override
  Future<List<ObservationSubjectRecord>> fetchAllSubjectRecordsInBounded(
      int definitionId,
      double topLeftX,
      double topLeftY,
      double bottomRightX,
      double bottomRightY) async {
    print(
        "topLeftX: $topLeftX, topLeftY: $topLeftY, bottomRightX: $bottomRightX, bottomRightY: $bottomRightY");
    var result = await _observationApi.fetchSubjectRecordsInBounded(
        definitionId, topLeftX, topLeftY, bottomRightX, bottomRightY);
    return result;
  }
}
