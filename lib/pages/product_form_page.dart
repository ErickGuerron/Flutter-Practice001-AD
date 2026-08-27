import 'package:app001/models/product.dart';
import 'package:app001/services/product_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductFormPage extends StatefulWidget {
  final Product? product;

  const ProductFormPage({super.key, this.product});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  bool _allowPop = false;

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController(); // Los controladores capturan la informacion.

  final ProductService productService = ProductService();

  @override
  void dispose(){
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.names;
      priceController.text = widget.product!.price.toString();
      stockController.text = widget.product!.stock.toString();
    }
  }


  bool get _hasUnsavedChanges{
      if(widget.product == null){
        return nameController.text.trim().isNotEmpty ||
          priceController.text.trim().isNotEmpty ||
          stockController.text.trim().isNotEmpty;
      }

      return nameController.text.trim() != widget.product!.names ||
          priceController.text.trim() != widget.product!.price.toString() ||
          stockController.text.trim() != widget.product!.stock.toString();
  }

  Future<void> saveUpdateProduct() async{

    if(!_formKey.currentState!.validate()){
      return;
    }

    final product = Product(
      id: widget.product?.id ?? 0,
      names: nameController.text.trim(),
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

  Future<bool> _confirmExit() async {
    final result = await showDialog<bool>(
      context:context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them and exit?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, false);
            },
            child: const Text('Cancel')
          ),
          TextButton(
            onPressed: (){
              Navigator.pop(context, true);
            },
            child: const Text('Discard')
          )
        ]
      )
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context){
    return PopScope(
      canPop: _allowPop || !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if(didPop){
          return;
        }

        final shouldExit = await _confirmExit();

        if(!shouldExit || !mounted){
          return;
        }

        setState((){
          _allowPop = true;
        });

        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: widget.product != null ? 
          Text("Edit Product"):
          Text("New Product"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                onChanged: (){
                  setState(() {});
                },
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'^\s')), 
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9 ]')),
                      ],
                      decoration: const InputDecoration(
                        alignLabelWithHint: true, 
                        labelText: "Name",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return "Please enter a name";
                        }
                        return null;
                      }
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: priceController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      decoration: const InputDecoration(
                        alignLabelWithHint: true, 
                        labelText: "Price",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: stockController,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true, 
                        labelText: "Stock",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value){
                        if(value == null || value.isEmpty){
                          return "Please enter a stock quantity";
                        }
                        final stock = int.tryParse(value);

                        if(stock == null){
                          return "Please enter a valid stock quantity";
                        }
                        if(stock <= 0){
                          return "Stock cannot be negative";
                        }
                        return null;


                      }
                    ),
                  ]
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
      )
    );
  }


}