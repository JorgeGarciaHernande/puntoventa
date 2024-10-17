import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:hive/hive.dart';

class ManageItemsView extends StatefulWidget {
  const ManageItemsView({Key? key}) : super(key: key);

  @override
  _ManageItemsViewState createState() => _ManageItemsViewState();
}

class _ManageItemsViewState extends State<ManageItemsView> {
  late Box _productBox;
  late Box _proveedorBox; // Caja para los proveedores
  bool _isLoading = true;

  // Controladores para los TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _selectedProveedor; // Variable para almacenar el proveedor seleccionado
  String _scannedBarcode = ''; // Variable para almacenar el código de barras escaneado

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _productBox = await Hive.openBox('products'); // Abrir la caja de productos
    _proveedorBox = await Hive.openBox('proveedores'); // Abrir la caja de proveedores
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _scanBarcode() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", "Cancelar", true, ScanMode.BARCODE);

    if (barcodeScanRes != '-1') {
      setState(() {
        _scannedBarcode = barcodeScanRes; // Guardar el código de barras escaneado
      });
    }
  }

  Future<void> _addProduct() async {
    if (_nameController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _selectedProveedor != null &&
        _scannedBarcode.isNotEmpty) {
      final newProduct = {
        'name': _nameController.text,
        'price': double.tryParse(_priceController.text) ?? 0.0,
        'proveedor': _selectedProveedor, // Guardar el proveedor seleccionado
        'barcode': _scannedBarcode, // Guardar el código de barras escaneado
      };

      await _productBox.add(newProduct);
      setState(() {});

      // Limpiar los campos después de agregar el producto
      _nameController.clear();
      _priceController.clear();
      _selectedProveedor = null;
      _scannedBarcode = '';
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos y escanee un código de barras.')),
      );
    }
  }

  Future<void> _deleteProduct(int index) async {
    await _productBox.deleteAt(index);
    setState(() {});
  }

  // Función para editar un producto
  void _editProduct(int index, Map<String, dynamic> product) {
    // Llenar los controladores con los valores actuales
    _nameController.text = product['name'];
    _priceController.text = product['price'].toString();
    _selectedProveedor = product['proveedor'];
    _scannedBarcode = product['barcode'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Producto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre del Producto'),
            ),
            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Precio'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              value: _selectedProveedor,
              decoration: const InputDecoration(
                labelText: 'Seleccionar Proveedor',
              ),
              items: _proveedorBox.values
                  .where((value) => value is Map<String, dynamic>)
                  .map((e) => DropdownMenuItem<String>(
                        value: (e as Map<String, dynamic>)['empresa'],
                        child: Text((e as Map<String, dynamic>)['empresa']),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedProveedor = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Escanear Código de Barras'),
            ),
            Text('Código de Barras Escaneado: $_scannedBarcode'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final updatedProduct = {
                'name': _nameController.text,
                'price': double.tryParse(_priceController.text) ?? 0.0,
                'proveedor': _selectedProveedor,
                'barcode': _scannedBarcode,
              };

              _productBox.putAt(index, updatedProduct); // Guardar los cambios en Hive
              setState(() {});
              Navigator.of(ctx).pop();
            },
            child: const Text('Guardar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Aquí verificamos y convertimos los productos a Map<String, dynamic> solo si es posible
    final products = _productBox.values
        .where((value) {
          try {
            return value is Map<String, dynamic>;
          } catch (e) {
            return false;
          }
        })
        .map((e) => e as Map<String, dynamic>)
        .toList();

    // Proveedores sigue con la lógica anterior
    final proveedores = _proveedorBox.values
        .where((value) => value is Map<String, dynamic>)
        .map((e) => e['empresa'] as String)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Productos'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Agregar Producto',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Producto',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Precio',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedProveedor,
                decoration: const InputDecoration(
                  labelText: 'Seleccionar Proveedor',
                  border: OutlineInputBorder(),
                ),
                items: proveedores
                    .map((proveedor) => DropdownMenuItem<String>(
                          value: proveedor,
                          child: Text(proveedor),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedProveedor = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _scanBarcode,
                child: const Text('Escanear Código de Barras'),
              ),
              const SizedBox(height: 10),
              Text(
                'Código de Barras Escaneado: $_scannedBarcode',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addProduct,
                child: const Text('Agregar Producto'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Lista de Productos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true, // Permitir que la lista se expanda dentro del ScrollView
                physics: const NeverScrollableScrollPhysics(), // Deshabilitar el scroll dentro de la lista
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text(
                      'Precio: \$${product['price']}\nProveedor: ${product['proveedor']}\nCódigo de Barras: ${product['barcode']}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editProduct(index, product),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteProduct(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

