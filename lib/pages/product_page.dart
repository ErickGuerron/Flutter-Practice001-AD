import 'package:app001/models/product.dart';
import 'package:app001/pages/product_form_page.dart';
import 'package:app001/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});
  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService productService = ProductService();

  late Future<List<Product>> productsFuture;
  @override
  void initState() {
    super.initState();
    productsFuture = productService.getProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product AM")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
          if (mounted) {
            setState(() {
              productsFuture = productService.getProducts();
            });
          }
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Product>>(
        future: productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final products = snapshot.data ?? [];
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(product.names),
                  subtitle: Text(
                    "Price: \$${product.price}\nStock: ${product.stock}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductFormPage(product: product),
                            ),
                          );
                          if (mounted) {
                            setState(() {
                              productsFuture = productService.getProducts();
                            });
                          }
                        },
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await productService.deleteProduct(product.id ?? 0);
                          setState(() {
                            productsFuture = productService.getProducts();
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
