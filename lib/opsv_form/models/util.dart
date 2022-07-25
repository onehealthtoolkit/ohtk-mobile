part of opensurveillance_form;

String format(String msg, List<String> values) {
  int index = 0;
  return msg.replaceAllMapped(RegExp(r'{.*?}'), (_) {
    final value = values[index];
    index++;
    return value;
  });
}

String formatWithMap(String msg, Map<String, String> mappedValues) {
  return msg.replaceAllMapped(RegExp(r'{(.*?)}'), (match) {
    final mapped = mappedValues[match[1]];
    if (mapped == null) {
      throw ArgumentError(
          '$mappedValues does not contain the key "${match[1]}"');
    }
    return mapped;
  });
}
