import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_subject.dart';
import 'package:podd_app/models/observation_subject_query_result.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:stacked/stacked.dart';

abstract class IObservationService with ReactiveServiceMixin {
  List<ObservationSubject> get observationSubjects;

  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();

  Future<void> fetchAllObservationSubjects(bool resetFlag, String definitionId);
}

class ObservationService extends IObservationService {
  final _dbService = locator<IDbService>();

  final ReactiveList<ObservationSubject> _observationSubjects =
      ReactiveList<ObservationSubject>();

  bool hasMoreObservationSubjects = false;
  int currentObservationSubjectNextOffset = 0;
  int observationSubjectLimit = 20;

  ObservationService() {
    listenToReactiveValues([
      _observationSubjects,
    ]);
  }

  @override
  List<ObservationSubject> get observationSubjects => _observationSubjects;

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    // TODO Query from db
    // var _db = _dbService.db;
    var result = await Future.value(getMockObservationDefinitions());
    await Future.delayed(Duration(seconds: 1));
    return result.map((item) => ObservationDefinition.fromMap(item)).toList();
  }

  @override
  Future<void> fetchAllObservationSubjects(
      bool resetFlag, String definitionId) async {
    if (resetFlag) {
      currentObservationSubjectNextOffset = 0;
    }
    // TODO Fetch api
    var result = await Future.value(getMockObservationSubjects());
    await Future.delayed(Duration(seconds: 1));

    if (resetFlag) {
      _observationSubjects.clear();
    }

    _observationSubjects.addAll(result.data);
    hasMoreObservationSubjects = result.hasNextPage;
    currentObservationSubjectNextOffset =
        currentObservationSubjectNextOffset + observationSubjectLimit;
  }
}

///
/// mock data
///
List<Map<String, dynamic>> getMockObservationDefinitions() => [
      {
        "id": "ob1",
        "name": "ข้อมูลต้นไม้",
        "register_form_definition": '''
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
''',
        "register_form_mapping": null,
        "title_template": null,
        "description_template": null,
        "identity_template": null,
      },
      {
        "id": "ob2",
        "name": "ข้อมูลบ้านs",
        "register_form_definition": '''
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
''',
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
        "title": "ต้นไม้จามจุรี"
      })
    ], false);
