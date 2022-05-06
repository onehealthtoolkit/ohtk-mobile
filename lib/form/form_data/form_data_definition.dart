import '../ui_definition/form_ui_definition.dart';
import 'form_data_definition_builder.dart';

abstract class BaseDataDefinition {
  final String name;

  BaseDataDefinition(this.name);
}

class StringDataDefinition extends BaseDataDefinition {
  StringDataDefinition(name) : super(name);
}

class IntegerDataDefinition extends BaseDataDefinition {
  IntegerDataDefinition(name) : super(name);
}

class DateDataDefinition extends BaseDataDefinition {
  DateDataDefinition(name) : super(name);
}

class BooleanDataDefinition extends BaseDataDefinition {
  BooleanDataDefinition(name) : super(name);
}

class DecimalDataDefinition extends BaseDataDefinition {
  DecimalDataDefinition(name) : super(name);
}

class ImagesDataDefinition extends BaseDataDefinition {
  ImagesDataDefinition(name) : super(name);
}

class FormDataDefinition extends BaseDataDefinition {
  final Map<String, BaseDataDefinition> properties;

  FormDataDefinition(name, this.properties) : super(name);

  FormDataDefinition.fromJson(String name, Map<String, dynamic> json)
      : properties = parseProperties(json),
        super(name);

  FormDataDefinition.fromUIDefinition(FormUIDefinition definition)
      : properties = parseFormUIDefinition(definition),
        super("root");
}

class ArrayDataDefinition extends BaseDataDefinition {
  final FormDataDefinition cols;
  ArrayDataDefinition(name, this.cols) : super(name);
}

Map<String, BaseDataDefinition> parseProperties(Map<String, dynamic> json) {
  return json.map((k, v) {
    return MapEntry(k, parseProperty(k, v));
  });
}

ArrayDataDefinition parseArray(String name, Map<String, dynamic> json) {
  var cols = json['columns'];
  return ArrayDataDefinition(name, FormDataDefinition.fromJson(name, cols));
}

BaseDataDefinition parseProperty(String name, Map<String, dynamic> json) {
  switch (json['type']) {
    case 'string':
      return StringDataDefinition(name);
    case 'int':
      return IntegerDataDefinition(name);
    case 'date':
      return DateDataDefinition(name);
    case 'bool':
      return BooleanDataDefinition(name);
    case "decimal":
      return DecimalDataDefinition(name);
    case 'object':
      return FormDataDefinition.fromJson(name, json['properties']);
    case 'array':
      return parseArray(name, json);
    case 'images':
      return ImagesDataDefinition(name);
  }
  throw Exception("not support type ${json['type']} for attribute $name");
}
