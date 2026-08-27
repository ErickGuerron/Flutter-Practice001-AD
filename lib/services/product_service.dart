import 'dart:convert';

import 'package:app001/models/product.dart';
import 'package:http/http.dart' as http;

class ProductService {
  final String url = "http://localhost:5050/api/Product";
  Future<List<Product>> getProducts() async{
    final response = await http.get(Uri.parse(url));

    if(response.statusCode == 200){
      List datos = jsonDecode(response.body);
      return datos.map((item)=> Product.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<void> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode(product.toJson()),
    );
    if(response.statusCode != 201 && response.statusCode != 200){
      throw Exception('Failed to create product');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response  = await http.put(
      Uri.parse('$url/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body:jsonEncode(product.toJson())
    );
    if(response.statusCode != 204 && response.statusCode != 200){
      throw Exception('Failed to edit product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$url/$id')
    );
    if(response.statusCode != 204 && response.statusCode != 200){
      throw Exception('Failed to delete product');
    }
  }

}