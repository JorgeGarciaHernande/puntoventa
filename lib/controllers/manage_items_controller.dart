import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class ManageItemsController {
  // Escanea el código de barras y devuelve el resultado
  Future<String> scanBarcode() async {
    return await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", "Cancelar", true, ScanMode.BARCODE);
  }

  // Agrega un producto a Hive, retornando un valor void (solo efecto)
  Future<void> addProduct(String name, String price, String barcode) async {
    final box = await Hive.openBox('products');
    
    // Verifica si ya existe un producto con el mismo código de barras
    final existingProduct = box.values.firstWhere(
      (product) => product['barcode'] == barcode, orElse: () => null);
    
    if (existingProduct != null) {
      throw Exception("Este producto ya existe.");
    }
    
    final product = {
      'name': name,
      'price': double.tryParse(price) ?? 0.0,
      'barcode': barcode,
    };
    
    await box.add(product);
  }

  // Edita un producto
  Future<void> editProduct(BuildContext context, int index) async {
    final box = await Hive.openBox('products');
    final product = box.getAt(index);

    final nameController = TextEditingController(text: product['name']);
    final priceController = TextEditingController(text: product['price'].toString());

    String barcode = product['barcode'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            Text('Código de barras: $barcode'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              final updatedProduct = {
                'name': nameController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'barcode': barcode,
              };
              await box.putAt(index, updatedProduct);
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  // Elimina un producto
  Future<void> deleteProduct(int index) async {
    final box = await Hive.openBox('products');
    await box.deleteAt(index);
  }
}
