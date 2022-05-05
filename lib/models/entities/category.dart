import 'package:podd_app/models/entities/utils.dart';

class Category {
  int id;
  String name;
  String icon;
  int ordering;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.ordering,
  });

  Category.fromJson(Map<String, dynamic> json)
      : id = cvInt(json, (m) => m['id']),
        name = json['name'],
        icon = json['icon'],
        ordering = cvInt(json, (m) => m['ordering']);

  Category.fromMap(Map<String, Object?> map)
      : id = map['id'] as int,
        name = map['name'] as String,
        icon = map['icon'] as String,
        ordering = map['ordering'] as int;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      "id": id,
      "name": name,
      "icon": icon,
      "ordering": ordering,
    };
    return map;
  }
}
