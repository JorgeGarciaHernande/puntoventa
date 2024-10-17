import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProductController {
  final Box _box;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  ProductController(this._box);

  List<Map<String, dynamic>> getProducts() {
    return List<Map<String, dynamic>>.from(_box.values);
  }

  void addProduct() {
    final String name = nameController.text;
    final double price = double.tryParse(priceController.text) ?? 0.0;

    if (name.isNotEmpty && price > 0) {
      _box.add({'name': name, 'price': price});
      nameController.clear();
      priceController.clear();
    }
  }

  void editProduct(int index) {
    final String name = nameController.text;
    final double price = double.tryParse(priceController.text) ?? 0.0;

    if (name.isNotEmpty && price > 0) {
      _box.putAt(index, {'name': name, 'price': price});
    }
  }

  void deleteProduct(int index) {
    _box.deleteAt(index);
  }
}
