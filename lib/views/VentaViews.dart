import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../controllers/venta_controller.dart';

class VentaView extends StatefulWidget {
  const VentaView({Key? key}) : super(key: key);

  @override
  _VentaViewState createState() => _VentaViewState();
}

class _VentaViewState extends State<VentaView> {
  VentaController? _ventaController;
  bool _isLoading = true;
  double cierreDeCaja = 0.0;
  late Box _cierreBox; // Caja Hive para almacenar cierres de caja

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    final box = await Hive.openBox('products'); // Caja de productos
    _cierreBox = await Hive.openBox('cierres'); // Caja para los cierres
    setState(() {
      _ventaController = VentaController(box);
      _isLoading = false;
    });
  }

  void _agregarProducto(String message) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _mostrarDetallePago() {
    if (_ventaController == null) return;

    final totalVenta = _ventaController!.totalVenta;
    print('Total Venta: $totalVenta');

    setState(() {
      cierreDeCaja += totalVenta;
      print('Cierre de Caja Actualizado: $cierreDeCaja');
    });

    final detalle = _ventaController!.procesarPago();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Detalle de la Venta'),
        content: Text(detalle),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarCierreCaja() async {
    final fecha = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());
    final nuevoCierre = {
      'fecha': fecha,
      'total': cierreDeCaja,
    };

    await _cierreBox.add(nuevoCierre); // Guardar el cierre en Hive
    print('Cierre de caja guardado: $nuevoCierre');

    setState(() {
      cierreDeCaja = 0.0; // Reiniciar el cierre de caja
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cierre de caja registrado')),
    );
  }

  void _mostrarCierreDeCaja() {
    final fecha = DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cierre de Caja'),
        content: Text(
          'Total acumulado: \$${cierreDeCaja.toStringAsFixed(2)}\nFecha: $fecha',
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _guardarCierreCaja(); // Guardar el cierre
              Navigator.of(ctx).pop();
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                final message = await _ventaController!.scanAndAddProduct();
                _agregarProducto(message);
              },
              child: const Text('Escanear Producto'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Productos en el Carrito:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _ventaController!.carrito.length,
                itemBuilder: (context, index) {
                  final product = _ventaController!.carrito[index];
                  return ListTile(
                    title: Text(product['name']),
                    subtitle: Text('Precio: \$${product['price']}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _ventaController!.eliminarProducto(index);
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _mostrarDetallePago,
              child: const Text('Pagar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _mostrarCierreDeCaja,
              child: const Text('Cierre de Caja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
