import 'package:ejemplo_1/views/cartera/convertircomprar.dart';
import 'package:ejemplo_1/views/compra/compra_view.dart';
import 'package:ejemplo_1/views/convertir/convertir_view.dart'; // Importa ConvertirView
import 'package:flutter/material.dart';
import 'package:ejemplo_1/widgets/grafico_widget.dart';
import 'package:fl_chart/fl_chart.dart';

class MonedaPage extends StatelessWidget {
  final String monedaNombre;

  const MonedaPage({
    super.key,
    required this.monedaNombre,
    required symbol,
  });

  @override
  Widget build(BuildContext context) {
    // Datos estáticos para el gráfico, reemplaza esto con tus propios datos
    final List<FlSpot> spots = [
      const FlSpot(1, 0),
      const FlSpot(2, 1.5),
      const FlSpot(3, 1),
      const FlSpot(4, 1.1),
      const FlSpot(5, 0.5),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(monedaNombre),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Lógica para el botón de notificaciones
            },
          ),
          IconButton(
            icon: const Icon(Icons.local_fire_department, color: Colors.black),
            onPressed: () {
              // Lógica para el botón de fuego
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GraficoWidget(spots: spots),
          ],
        ),
      ),
    );
  }
}
