import 'package:podd_app/models/entities/observation_monitoring_definition.dart';
import 'package:podd_app/models/entities/utils.dart';

class ObservationDefinition {
  int id;
  String name;
  String registerFormDefinition;
  bool isActive;
  String? registerFormMapping;
  String? titleTemplate;
  String? descriptionTemplate;
  String? identityTemplate;
  String? imageUrl;

  List<ObservationMonitoringDefinition> monitoringDefinitions;

  ObservationDefinition({
    required this.id,
    required this.name,
    required this.registerFormDefinition,
    required this.isActive,
    this.registerFormMapping,
    this.titleTemplate,
    this.descriptionTemplate,
    this.identityTemplate,
    this.imageUrl,
    this.monitoringDefinitions = const [],
  });

  ObservationDefinition.fromJson(Map<String, dynamic> jsonMap)
      : id = cvInt(jsonMap, (m) => m['id']),
        name = jsonMap['name'],
        registerFormDefinition = jsonMap['registerFormDefinition'],
        isActive = jsonMap['isActive'],
        registerFormMapping = jsonMap['registerFormMapping'],
        titleTemplate = jsonMap['titleTemplate'],
        descriptionTemplate = jsonMap['descriptionTemplate'],
        identityTemplate = jsonMap['identityTemplate'],
        imageUrl = jsonMap['imageUrl'],
        monitoringDefinitions = jsonMap['monitoringDefinitions'] != null
            ? (jsonMap['monitoringDefinitions'] as List)
                .map((item) => ObservationMonitoringDefinition.fromJson(item))
                .toList()
            : [];
}
