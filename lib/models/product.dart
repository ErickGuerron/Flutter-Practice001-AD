class Product {
  final int? id;
  final String names;
  final double price;
  final int stock;

  Product({
    this.id,
    required this.names,
    required this.price,
    required this.stock,
  });

  factory Product.fromJson(Map<String,dynamic> json) {
    return Product(
      id: json['id'] as int,
      names: json['names'] as String,
      price: json['price'] as double,
      stock: json['stock'] as int,
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': int.parse(id.toString() ?? '0'),
      'names': names,
      'price': price,
      'stock': stock,
    };
  }
}