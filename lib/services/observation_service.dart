import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_report_monitoring_record.dart';
import 'package:podd_app/models/entities/observation_report_subject.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/entities/observation_subject_monitoring.dart';
import 'package:podd_app/models/entities/observation_subject_report.dart';
import 'package:podd_app/models/observation_monitoring_record_submit_result.dart';
import 'package:podd_app/models/observation_subject_monitoring_query_result.dart';
import 'package:podd_app/models/observation_subject_query_result.dart';
import 'package:podd_app/models/observation_subject_report_query_result.dart';
import 'package:podd_app/models/observation_subject_submit_result.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/db_service.dart';
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
}

class ObservationService extends IObservationService {
  final _dbService = locator<IDbService>();
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
    var result = getMockObservationSubjectReports();
    await Future.delayed(Duration(seconds: 1));

    _observationSubjectReports.clear();
    _observationSubjectReports.addAll(result.data);
  }

  @override
  Future<ObservationSubjectSubmitResult> submitReportSubject(
      ObservationReportSubject report) async {
    try {
      var result = await _observationApi.submitReportSubject(report);

      if (result is ObservationSubjectSubmitSuccess) {
        // TODO submit images
        // TODO delete from local db
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
        // TODO submit images
        // TODO delete from local db
        _observationSubjectMonitorings.insert(0, result.monitoringRecord);
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
}

///
/// mock data
///
var definition1 = '''
{
  "sections": [
    {
      "label": "ทั่วไป ",
      "questions": [
        {
          "label": "general info",
          "description": "",
          "fields": [
            {
              "id": "common",
              "label": "common",
              "name": "common",
              "type": "text",
              "required": true,
              "tags": "name"
            },
            {
              "id": "species",
              "label": "species",
              "name": "species",
              "type": "text",
              "required": false
            },
            {
              "id": "state",
              "label": "state",
              "name": "state",
              "type": "singlechoices",
              "required": false,
              "options": [
                {
                  "label": "good",
                  "value": "good"
                },
                {
                  "label": "bad",
                  "value": "bad"
                },
                {
                  "label": "ok",
                  "value": "ok"
                }
              ]
            },
            {
              "id": "surrounding",
              "label": "surrounding",
              "name": "surrounding",
              "type": "multiplechoices",
              "required": false,
              "options": [
                {
                  "label": "car",
                  "value": "car"
                },
                {
                  "label": "home",
                  "value": "home"
                },
                {
                  "label": "store",
                  "value": "store"
                },
                {
                  "label": "children",
                  "value": "children"
                },
                {
                  "label": "dog",
                  "value": "dog"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
''';

var definition2 = '''
{
  "sections": [
    {
      "label": "ทั่วไป ",
      "questions": [
        {
          "label": "general info",
          "description": "",
          "fields": [
            {
              "id": "style",
              "label": "style",
              "name": "style",
              "type": "text",
              "required": true,
              "tags": "name"
            },
            {
              "id": "material",
              "label": "material",
              "name": "material",
              "type": "text",
              "required": false
            },
            {
              "id": "condition",
              "label": "condition",
              "name": "condition",
              "type": "singlechoices",
              "required": false,
              "options": [
                {
                  "label": "good",
                  "value": "good"
                },
                {
                  "label": "bad",
                  "value": "bad"
                },
                {
                  "label": "ok",
                  "value": "ok"
                }
              ]
            },
            {
              "id": "surrounding",
              "label": "surrounding",
              "name": "surrounding",
              "type": "multiplechoices",
              "required": false,
              "options": [
                {
                  "label": "car",
                  "value": "car"
                },
                {
                  "label": "home",
                  "value": "home"
                },
                {
                  "label": "store",
                  "value": "store"
                },
                {
                  "label": "children",
                  "value": "children"
                },
                {
                  "label": "dog",
                  "value": "dog"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
''';

List<Map<String, dynamic>> getMockObservationDefinitions() => [
      {
        "id": "ob1",
        "name": "ข้อมูลต้นไม้",
        "register_form_definition": definition1,
        "register_form_mapping": null,
        "title_template": null,
        "description_template": null,
        "identity_template": null,
      },
      {
        "id": "ob2",
        "name": "ข้อมูลบ้าน",
        "register_form_definition": definition2,
        "register_form_mapping": null,
        "title_template": null,
        "description_template": null,
        "identity_template": null,
      }
    ];

ObservationSubjectQueryResult getMockObservationSubjects() =>
    ObservationSubjectQueryResult([
      ObservationSubject.fromJson({
        "id": "osub1",
        "definitionId": "ob1",
        "authorityId": 2,
        "formData": {
          "common": "จามจุรี",
          "state": "good",
          "species": "larvee",
        },
        "title": "ต้นไม้จามจุรี",
        "formDefinition": definition1,
      })
    ], false);

ObservationSubjectMonitoringQueryResult
    getMockObservationSubjectMonitorings() =>
        ObservationSubjectMonitoringQueryResult([
          ObservationSubjectMonitoring.fromJson({
            "id": "osubmon1",
            "definitionId": "ob1",
            "subjectId": "osub1",
            "monitoringId": "obmon1",
            "formData": {
              "common": "ดูแลจามจุรี",
              "state": "โอเค good",
              "species": "larvee",
            },
            "title": "monitor ต้นไม้จามจุรี"
          }),
          ObservationSubjectMonitoring.fromJson({
            "id": "osubmon2",
            "definitionId": "ob1",
            "subjectId": "osub1",
            "monitoringId": "obmon1",
            "formData": {
              "common": "ดูแลจามจุรี2",
              "state": "โอเค ok",
              "species": "larvee2",
            },
            "title": "monitor ต้นไม้จามจุรี2"
          })
        ]);

ObservationSubjectReportQueryResult getMockObservationSubjectReports() =>
    ObservationSubjectReportQueryResult([
      ObservationSubjectReport.fromJson({
        "id": "osubrep1",
        "subjectId": "osub1",
        "reportId": "rep-01-now",
        "reportTypeId": "5",
        "reportTypeName": "ต้นไม้ในกทม",
        "incidentDate": "2022-11-11",
        "formData": {
          "common": "ต้นจามจุรี",
          "state": "โอเค good",
          "species": "larvee",
        },
        "description": "report ต้นไม้จามจุรี"
      }),
    ]);

List<Map<String, dynamic>> getMockObservationMonitoringDefinitions() => [
      {
        "id": "obmon1",
        "name": "ดูแลต้นไม้ monitor",
        "form_definition": '''
{
  "sections": [
    {
      "label": "monitor ทั่วไป ",
      "questions": [
        {
          "label": "general info",
          "description": "",
          "fields": [
            {
              "id": "พื้นฐาน",
              "label": "พื้นฐาน",
              "name": "พื้นฐาน",
              "type": "text",
              "required": true,
              "tags": "name"
            },
            {
              "id": "สปีชี่",
              "label": "สปีชี่",
              "name": "สปีชี่",
              "type": "text",
              "required": false
            },
            {
              "id": "สถานภาพ",
              "label": "สถานภาพ",
              "name": "สถานภาพ",
              "type": "singlechoices",
              "required": false,
              "options": [
                {
                  "label": "good",
                  "value": "good"
                },
                {
                  "label": "bad",
                  "value": "bad"
                },
                {
                  "label": "ok",
                  "value": "ok"
                }
              ]
            },
            {
              "id": "surrounding",
              "label": "surrounding",
              "name": "surrounding",
              "type": "multiplechoices",
              "required": false,
              "options": [
                {
                  "label": "car",
                  "value": "car"
                },
                {
                  "label": "home",
                  "value": "home"
                },
                {
                  "label": "store",
                  "value": "store"
                },
                {
                  "label": "children",
                  "value": "children"
                },
                {
                  "label": "dog",
                  "value": "dog"
                }
              ]
            }
          ]
        }
      ]
    }
  ]
}
''',
        "definition_id": "ob1",
        "title_template": null,
        "description_template": null,
      },
    ];