import 'package:hive/hive.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';

class VentaController {
  final List<Map<String, dynamic>> carrito = [];
  final Box productsBox;

  VentaController(this.productsBox);

  // Escanear código de barras y agregar producto al carrito
  Future<String> scanAndAddProduct() async {
    String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      "#ff6666", "Cancelar", true, ScanMode.BARCODE,
    );

    if (barcodeScanRes != '-1') {
      return agregarProductoAlCarrito(barcodeScanRes);
    }
    return 'Escaneo cancelado';
  }

  // Agregar producto al carrito si existe
  String agregarProductoAlCarrito(String barcode) {
    final producto = productsBox.values.firstWhere(
      (producto) => producto['barcode'] == barcode,
      orElse: () => null,
    );

    if (producto != null) {
      carrito.add(Map<String, dynamic>.from(producto));
      return 'Producto agregado al carrito';
    } else {
      return 'Producto no encontrado';
    }
  }

  // Eliminar producto del carrito
  void eliminarProducto(int index) {
    if (index >= 0 && index < carrito.length) {
      carrito.removeAt(index);
    }
  }

  // Getter para obtener el total de la venta actual
  double get totalVenta {
    return carrito.fold(0.0, (total, producto) => total + producto['price']);
  }

  // Procesar pago y devolver el detalle
  String procesarPago() {
    double total = totalVenta;
    String detalle = '';

    for (var producto in carrito) {
      detalle += '${producto['name']} - \$${producto['price'].toStringAsFixed(2)}\n';
    }

    carrito.clear(); // Limpiar el carrito después de procesar el pago

    return 'Productos:\n$detalle\nTotal: \$${total.toStringAsFixed(2)}';
  }
}
