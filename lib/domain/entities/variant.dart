class Variant {
  const Variant({required this.color, required this.size, required this.stock});

  final String color;
  final String size;
  final int stock;

  factory Variant.fromJson(Map<String, dynamic> json) {
    return Variant(
      color: (json['color'] as String?) ?? '',
      size: (json['size'] as String?) ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'color': color, 'size': size, 'stock': stock};
  }
}
