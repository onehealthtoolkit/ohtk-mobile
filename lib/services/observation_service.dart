import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:stacked/stacked.dart';

abstract class IObservationService with ReactiveServiceMixin {
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();
}

class ObservationService extends IObservationService {
  final _dbService = locator<IDbService>();

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    // TODO Query from db
    // var _db = _dbService.db;
    var result = await Future.value(<Map<String, dynamic>>[
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
    ]);
    return result.map((item) => ObservationDefinition.fromMap(item)).toList();
  }
}
