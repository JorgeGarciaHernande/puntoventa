import 'package:hive/hive.dart';

class CierreCajaController {
  final List<Map<String, dynamic>> _cierres = []; // Lista en memoria
  final Box _cierreBox; // Caja Hive para persistencia

  CierreCajaController(this._cierreBox) {
    _loadCierres(); // Cargar los cierres existentes al iniciar
  }

  // Cargar los cierres almacenados en Hive
  void _loadCierres() {
    final storedCierres = _cierreBox.values.toList();
    print('Cierres cargados desde Hive: $storedCierres'); // Depuración
    _cierres.addAll(storedCierres.cast<Map<String, dynamic>>());
  }

  // Obtener todos los cierres ordenados por fecha
  List<Map<String, dynamic>> get cierresOrdenados {
    final List<Map<String, dynamic>> sortedCierres = List.from(_cierres)
      ..sort((a, b) => b['fecha'].compareTo(a['fecha']));
    return sortedCierres;
  }

  // Agregar un nuevo cierre de caja
  Future<void> agregarCierreCaja(double total) async {
    final nuevoCierre = {
      'fecha': DateTime.now(),
      'total': total,
    };
    _cierres.add(nuevoCierre);
    await _cierreBox.add(nuevoCierre); // Guardar en Hive
    print('Nuevo cierre agregado: $nuevoCierre'); // Depuración
  }

  // Eliminar un cierre de caja por índice
  Future<void> eliminarCierreCaja(int index) async {
    if (index >= 0 && index < _cierres.length) {
      _cierres.removeAt(index);
      await _cierreBox.deleteAt(index); // Eliminar de Hive
    }
  }
}
