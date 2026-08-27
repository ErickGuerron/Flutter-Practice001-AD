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
  final stockController = TextEditingController();

  final ProductService productService = ProductService();
  bool _isLoading = false;

  @override
  void dispose() {
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

  bool get _hasUnsavedChanges {
    if (widget.product == null) {
      return nameController.text.trim().isNotEmpty ||
          priceController.text.trim().isNotEmpty ||
          stockController.text.trim().isNotEmpty;
    }

    return nameController.text.trim() != widget.product!.names ||
        priceController.text.trim() != widget.product!.price.toString() ||
        stockController.text.trim() != widget.product!.stock.toString();
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> saveUpdateProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final product = Product(
        id: widget.product?.id ?? 0,
        names: nameController.text.trim(),
        price: double.tryParse(priceController.text) ?? 0.0,
        stock: int.tryParse(stockController.text) ?? 0,
        version: widget.product?.version ?? 1,
      );

      if (widget.product != null) {
        final updatedProduct = await productService.updateProduct(product);
        if (mounted) {
          if (updatedProduct != null) {
            _showSuccessSnackbar('Product updated successfully');
            Navigator.pop(context, true);
          }
        }
      } else {
        await productService.createProduct(product);
        if (mounted) {
          _showSuccessSnackbar('Product saved successfully');
          Navigator.pop(context, true);
        }
      }
    } on ProductVersionConflictException catch (e) {
      if (mounted) {
        _showVersionConflictDialog(e.message);
      }
    } on ProductServiceException catch (e) {
      if (mounted) {
        _showErrorSnackbar(e.message);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackbar('An unexpected error occurred. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showVersionConflictDialog(String message) {
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Conflict'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, true);
              Navigator.pop(context, true); // Close form and refresh list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a price";
                        }
                        if (value.contains(' ')) {
                          return "Spaces are not allowed";
                        }
                        if (!RegExp(r'^\d+\.?\d{0,2}$').hasMatch(value)) {
                          return "Only numbers are allowed";
                        }
                        final price = double.tryParse(value);
                        if (price == null) {
                          return "Please enter a valid price";
                        }
                        if (price < 0) {
                          return "Price cannot be negative";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: stockController,
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        FilteringTextInputFormatter.deny(RegExp(r'[^0-9]')),
                      ],
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        alignLabelWithHint: true,
                        labelText: "Stock",
                        border: OutlineInputBorder(),
                        hintText: "Enter a whole number",
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter a stock quantity";
                        }
                        if (value.contains(' ')) {
                          return "Spaces are not allowed";
                        }
                        if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                          return "Only numbers are allowed";
                        }
                        final stock = int.tryParse(value);
                        if (stock == null) {
                          return "Please enter a valid stock quantity";
                        }
                        if (stock < 0) {
                          return "Stock cannot be negative";
                        }
                        return null;
                      },
                    ),
                  ]
                )   
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : saveUpdateProduct,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(widget.product != null ? "Update" : "Save"),
                ),
              )
            ]
          )
        )
      )
    );
  }


}