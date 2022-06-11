enum ConditionOperator { equal }

Map<String, ConditionOperator> conditionMap = {"=": ConditionOperator.equal};

class ConditionDefinition {
  String name;
  ConditionOperator operator;
  String value;

  ConditionDefinition(
      {required this.name, required this.operator, required this.value});

  factory ConditionDefinition.fromJson(Map<String, dynamic> json) {
    return ConditionDefinition(
      name: json['name'],
      operator: conditionMap[json['operator']]!,
      value: json['value'],
    );
  }
}

ConditionDefinition? parseCondition(Map<String, dynamic> json, String name) {
  if (json[name] != null) {
    return ConditionDefinition.fromJson(json[name]);
  }
  return null;
}
