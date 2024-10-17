import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'views/inicio_view.dart';
import 'views/manage_items_view.dart';
import 'views/ventaviews.dart';

void main() async {
  // Asegúrate de inicializar Hive correctamente antes de iniciar la app
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Hive
  await Hive.initFlutter();

  // Abre la caja 'products' que usas en tu aplicación
  await Hive.openBox('products');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Punto de Venta',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const InicioView(), // Vista de inicio
    );
  }
}
