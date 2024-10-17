import 'package:flutter/material.dart';
import 'manage_items_view.dart';
import 'ventaviews.dart';
import 'provedores_view.dart';
import 'caja_views.dart'; // Importar la vista de gestión de cajas

class InicioView extends StatelessWidget {
  const InicioView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby - Punto de Venta'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageItemsView()),
                );
              },
              child: const Text('Gestionar Productos'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VentaView()),
                );
              },
              child: const Text('Realizar Venta'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProveedoresView()),
                );
              },
              child: const Text('Proveedores'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GestionCajasView()), // Navegar a la vista de gestión de cajas
                );
              },
              child: const Text('Cierre de Cajas'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
