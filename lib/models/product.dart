class Product {
  final int? id;
  final String names;
  final double price;
  final int stock;
  final int version;

  Product({
    this.id,
    required this.names,
    required this.price,
    required this.stock,
    this.version = 1,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      names: json['names'] as String,
      price: (json['price'] as num).toDouble(),
      stock: json['stock'] as int,
      version: json['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id ?? 0,
      'names': names,
      'price': price,
      'stock': stock,
      'version': version,
    };
  }

  Product copyWith({
    int? id,
    String? names,
    double? price,
    int? stock,
    int? version,
  }) {
    return Product(
      id: id ?? this.id,
      names: names ?? this.names,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      version: version ?? this.version,
    );
  }
}