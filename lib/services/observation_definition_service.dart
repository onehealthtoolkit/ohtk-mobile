import 'package:podd_app/locator.dart';
import 'package:podd_app/models/entities/observation_definition.dart';
import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/services/api/observation_api.dart';
import 'package:podd_app/services/db_service.dart';
import 'package:sqflite/sql.dart';
import 'package:stacked/stacked.dart';

abstract class IObservationDefinitionService with ListenableServiceMixin {
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions();

  Future<ObservationDefinition?> getObservationDefinition(int id);

  Future<ObservationMonitoringDefinition?> getObservationMonitoringDefinition(
      int id);

  Future<void> sync();

  Future<void> removeAll();
}

class ObservationDefinitionService extends IObservationDefinitionService {
  final _dbService = locator<IDbService>();
  final _observationApi = locator<ObservationApi>();

  ObservationDefinitionService();

  @override
  Future<List<ObservationDefinition>> fetchAllObservationDefinitions() async {
    var db = _dbService.db;
    var monitoringDefinitionResult = await db.query('monitoring_definition');

    var result = await db.query('observation_definition');
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
  Future<ObservationDefinition?> getObservationDefinition(int id) async {
    var db = _dbService.db;
    var monitoringDefinitionResults = await db.query('monitoring_definition',
        where: 'definition_id = ?', whereArgs: [id]);

    var result = await db
        .query('observation_definition', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result
          .map((definition) => ObservationDefinition.fromMap(
              definition, monitoringDefinitionResults))
          .toList()[0];
    }
    return null;
  }

  @override
  Future<ObservationMonitoringDefinition?> getObservationMonitoringDefinition(
      int id) async {
    var db = _dbService.db;
    var result = await db
        .query('monitoring_definition', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return ObservationMonitoringDefinition.fromMap(result[0]);
    }
    return null;
  }

  @override
  sync() async {
    var db = _dbService.db;
    var oldDefinitions = await fetchAllObservationDefinitions();

    ObservationDefinitionSyncOutputType result =
        await _observationApi.syncObservationDefinitions(oldDefinitions
            .map((definition) => ObservationDefinitionSyncInputType(
                  id: definition.id.toString(),
                  updatedAt: DateTime.parse(definition.updatedAt),
                ))
            .toList());

    if (result.removedList.isNotEmpty) {
      await db.delete('observation_definition',
          where: "id in (?)", whereArgs: [result.removedList.toString()]);

      await db.delete('monitoring_definition',
          where: "definition_id in (?)",
          whereArgs: [result.removedList.toString()]);
    }

    for (var definition in result.updatedList) {
      await db.insert(
        'observation_definition',
        definition.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var monitoring in definition.monitoringDefinitions) {
        await db.insert(
          'monitoring_definition',
          monitoring.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  @override
  Future<void> removeAll() async {
    var db = _dbService.db;
    await db.delete('observation_definition');
    await db.delete('monitoring_definition');
  }
}
