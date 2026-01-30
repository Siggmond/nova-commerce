class Variant {
  const Variant({required this.color, required this.size, required this.stock});

  final String color;
  final String size;
  final int stock;

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant._fromMap(json);
  }

  static Variant? tryFromJson(Object? json) {
    if (json is! Map) return null;

    final map = <String, dynamic>{};
    for (final entry in json.entries) {
      final key = entry.key;
      if (key is String) map[key] = entry.value;
    }

    return Variant._fromMap(map);
  }

  factory Variant._fromMap(Map<String, dynamic> json) {
    return Variant(
      color: (json['color'] as String?) ?? '',
      size: (json['size'] as String?) ?? '',
      stock: _parseStock(json['stock']),
    );
  }

  static int _parseStock(Object? value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is num) return value.toInt();
    if (value is String) {
      final trimmed = value.trim();
      final asInt = int.tryParse(trimmed);
      if (asInt != null) return asInt;
      final asDouble = double.tryParse(trimmed);
      if (asDouble != null) return asDouble.toInt();
    }
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'size': size, 'stock': stock};
  }
}
