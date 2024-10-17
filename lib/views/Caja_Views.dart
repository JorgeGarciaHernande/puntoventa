import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class GestionCajasView extends StatefulWidget {
  const GestionCajasView({Key? key}) : super(key: key);

  @override
  _GestionCajasViewState createState() => _GestionCajasViewState();
}

class _GestionCajasViewState extends State<GestionCajasView> {
  late Box _cierreBox;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeHive();
  }

  Future<void> _initializeHive() async {
    _cierreBox = await Hive.openBox('cierres'); // Abrir la caja Hive
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Verificamos que los datos sean del tipo correcto (Map<String, dynamic>)
    final cierres = _cierreBox.values
        .where((value) => value is Map<String, dynamic>) // Filtramos solo los correctos
        .map((e) => e as Map<String, dynamic>)
        .toList();

    if (cierres.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No hay cierres de caja disponibles.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Cajas'),
      ),
      body: ListView.builder(
        itemCount: cierres.length,
        itemBuilder: (context, index) {
          final caja = cierres[index];
          final fecha = caja['fecha'].toString();
          final total = (caja['total'] as double).toStringAsFixed(2);

          return ListTile(
            title: Text('Fecha: $fecha'),
            subtitle: Text('Total: \$${total}'),
            leading: const Icon(Icons.attach_money, color: Colors.green),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await _cierreBox.deleteAt(index); // Eliminar cierre
                setState(() {}); // Actualizar la UI
              },
            ),
          );
        },
      ),
    );
  }
}
