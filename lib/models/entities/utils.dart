cvInt(
  Map<String, dynamic> map,
  dynamic Function(Map<String, dynamic>) extract,
) {
  var value = extract(map);
  if (value is int) {
    return value;
  }
  return int.parse(value.toString());
}
