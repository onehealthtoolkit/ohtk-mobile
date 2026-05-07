class AnimalSpecies {
  final int id;
  final String code;
  final String name;
  final bool active;
  final int sortOrder;

  const AnimalSpecies({
    required this.id,
    required this.code,
    required this.name,
    this.active = true,
    this.sortOrder = 0,
  });

  factory AnimalSpecies.fromJson(Map<String, dynamic> json) => AnimalSpecies(
        id: json['id'] is int ? json['id'] as int : int.parse('${json['id']}'),
        code: json['code']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        active: json['active'] as bool? ?? true,
        sortOrder: json['sortOrder'] as int? ?? 0,
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'active': active,
      'sortOrder': sortOrder,
    };
  }

  String get displayName {
    if (code.isEmpty) {
      return name;
    }
    return '$code - $name';
  }
}
