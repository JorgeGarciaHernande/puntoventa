import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ProveedoresView extends StatefulWidget {
  const ProveedoresView({Key? key}) : super(key: key);

  @override
  _ProveedoresViewState createState() => _ProveedoresViewState();
}

class _ProveedoresViewState extends State<ProveedoresView> {
  late Box _proveedorBox;
  bool _isLoading = true;

  // Controladores para los TextFields
  final TextEditingController _empresaController = TextEditingController();
  final TextEditingController _contactoController = TextEditingController();
  final TextEditingController _productosController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _proveedorBox = await Hive.openBox('proveedores'); // Abrir la caja Hive
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _agregarProveedor() async {
    final nuevoProveedor = {
      'empresa': _empresaController.text,
      'contacto': _contactoController.text,
      'productos': _productosController.text,
    };

    if (_empresaController.text.isNotEmpty &&
        _contactoController.text.isNotEmpty &&
        _productosController.text.isNotEmpty) {
      await _proveedorBox.add(nuevoProveedor);
      setState(() {});

      // Limpiar los campos después de agregar
      _empresaController.clear();
      _contactoController.clear();
      _productosController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete todos los campos.')),
      );
    }
  }

  Future<void> _eliminarProveedor(int index) async {
    await _proveedorBox.deleteAt(index);
    setState(() {});
  }

  // Función para mostrar el formulario de edición
  void _editarProveedor(int index, Map<String, dynamic> proveedor) {
    _empresaController.text = proveedor['empresa'];
    _contactoController.text = proveedor['contacto'];
    _productosController.text = proveedor['productos'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Proveedor'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _empresaController,
              decoration: const InputDecoration(labelText: 'Nombre de Empresa'),
            ),
            TextField(
              controller: _contactoController,
              decoration: const InputDecoration(labelText: 'Contacto'),
            ),
            TextField(
              controller: _productosController,
              decoration: const InputDecoration(labelText: 'Tipo de Productos'),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              final proveedorEditado = {
                'empresa': _empresaController.text,
                'contacto': _contactoController.text,
                'productos': _productosController.text,
              };

              _proveedorBox.putAt(index, proveedorEditado); // Actualizar el proveedor
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

    // Filtrar y convertir proveedores a Map<String, dynamic> solo si es posible
    final proveedores = _proveedorBox.values
        .where((value) {
          try {
            return value is Map<String, dynamic>;
          } catch (e) {
            return false;
          }
        })
        .map((e) => e as Map<String, dynamic>)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Proveedores'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agregar Proveedor',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _empresaController,
              decoration: const InputDecoration(
                labelText: 'Nombre de Empresa',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contactoController,
              decoration: const InputDecoration(
                labelText: 'Contacto',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _productosController,
              decoration: const InputDecoration(
                labelText: 'Tipo de Productos',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _agregarProveedor,
              child: const Text('Agregar Proveedor'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Lista de Proveedores',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: proveedores.length,
                itemBuilder: (context, index) {
                  final proveedor = proveedores[index];
                  return ListTile(
                    title: Text(proveedor['empresa']),
                    subtitle: Text(
                        'Contacto: ${proveedor['contacto']}\nProductos: ${proveedor['productos']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _editarProveedor(index, proveedor),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _eliminarProveedor(index),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
