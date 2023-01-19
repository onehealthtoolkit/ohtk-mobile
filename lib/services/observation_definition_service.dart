import 'package:logger/logger.dart';
import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:sqflite/sql.dart';
import 'package:stacked/stacked.dart';

abstract class IObservationDefinitionService with ReactiveServiceMixin {
  final _logger = locator<Logger>();

  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();

  Future<void> sync();
}

class ObservationDefinitionService extends IObservationDefinitionService {
  final _dbService = locator<IDbService>();
  final _observationApi = locator<ObservationApi>();

  ObservationDefinitionService();

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    var _db = _dbService.db;
    var monitoringDefinitionResult = await _db.query('monitoring_definition');

    var result = await _db.query('observation_definition');
    return result
        .map(
          (definition) => ObservationDefinition.fromMap(
            definition,
            monitoringDefinitionResult
                .where((monitoring) =>
                    monitoring["definition_id"] == definition["id"])
                .toList(),
          ),
        )
        .toList();
  }

  @override
  sync() async {
    var _db = _dbService.db;
    var oldDefinitions = await fetchAllObservationDefinitions();

    ObservationDefinitionSyncOutputType result =
        await _observationApi.syncObservationDefinitions(oldDefinitions
            .map((definition) => ObservationDefinitionSyncInputType(
                  id: definition.id.toString(),
                  updatedAt: DateTime.parse(definition.updatedAt),
                ))
            .toList());

    if (result.removedList.isNotEmpty) {
      await _db.delete('observation_definition',
          where: "id in (?)", whereArgs: result.removedList);

      await _db.delete('monitoring_definition',
          where: "definition_id in (?)", whereArgs: result.removedList);
    }

    for (var definition in result.updatedList) {
      await _db.insert(
        'observation_definition',
        definition.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var monitoring in definition.monitoringDefinitions) {
        await _db.insert(
          'monitoring_definition',
          monitoring.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }
}
