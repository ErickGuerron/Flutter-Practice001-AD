import 'package:app001/models/product.dart';
import 'package:app001/services/product_service.dart';
import 'package:flutter/material.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController(); // Los controladores capturan la informacion.

  final ProductService productService = ProductService();

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.names;
      priceController.text = widget.product!.price.toString();
      stockController.text = widget.product!.stock.toString();
    }
  }

  Future<void> saveUpdateProduct() async{
    final product = Product(
      id: widget.product?.id ?? 0,
      names: nameController.text,
      price: double.tryParse(priceController.text) ?? 0.0,
      stock: int.tryParse(stockController.text) ?? 0,
    );
    if( widget.product != null){
      await productService.updateProduct(product);
    } else{
      await productService.createProduct(product); 
    }
    if(mounted){
      Navigator.pop(context); // Regresa a la pagina anterior despues de guardar el producto.
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: widget.product != null ? 
        Text("Edit Product"):
        Text("New Product"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                alignLabelWithHint: true, 
                labelText: "Name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(
                alignLabelWithHint: true, 
                labelText: "Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                alignLabelWithHint: true, 
                labelText: "Stock",
                border: OutlineInputBorder(),
              )
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              child: widget.product != null ?
              Text("Update"):
              Text("Save"),
              onPressed: saveUpdateProduct,
            )
          ]
        )
      )
    );
  }


}