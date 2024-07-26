import 'package:ejemplo_1/models/moneda.dart';
import 'package:ejemplo_1/services/crud_monedero_service.dart';
import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:ejemplo_1/views/market/market_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import '../home/saldo/saldo.dart';
import 'pie_chart_widget.dart'; // Asegúrate de tener la ruta correcta

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<AuthViewModel>(context).user;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Usuario no autenticado'),
        ),
      );
    }

    final cartera = MonederoService().getMonedero(currentUser);

    return FutureBuilder(
      future: cartera,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error :(: ${snapshot.error}'),
          );
        }

        final monedero = snapshot.data as Monedero;

        return FutureBuilder<double>(
          future: monedero.getSaldoTotalEnCLP(),
          builder: (context, saldoSnapshot) {
            if (saldoSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (saldoSnapshot.hasError) {
              return Center(
                child: Text(
                    'Error al calcular el saldo total: ${saldoSnapshot.error}'),
              );
            }

            final saldoTotal = saldoSnapshot.data ?? 0.0;
            Logger().i('Saldo total: $saldoTotal');

            if (monedero.monedas.isEmpty) {
              return const Scaffold(
                body: Center(
                  child: Text('No tienes monedas'),
                ),
              );
            }

            return Scaffold(
              body: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SaldoWidget(saldo: saldoTotal),
                      const SizedBox(height: 16),
                      const Text(
                        'Monedas',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PieChartWidget(dataMapFuture: monedero.dataMap),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
