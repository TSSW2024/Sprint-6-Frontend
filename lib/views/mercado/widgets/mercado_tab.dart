import 'package:ejemplo_1/models/criptomonedasFetch.dart';
import 'package:flutter/material.dart';
// Importar widgets internos de la tabla
import 'nuevos_tab.dart';
import 'perdedores_tab.dart';
import 'populares_tab.dart';

class MercadoTab extends StatelessWidget {
  final Future<MonedasResponse> futureMonedas;

  const MercadoTab({super.key, required this.futureMonedas});

  @override
  Widget build(BuildContext context) {
    final altoActual = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            color: Colors.transparent,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              indicatorPadding: const EdgeInsets.all(10),
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(text: 'Populares'),
                Tab(text: 'Perdedores'),
                Tab(text: 'Ganadores'),
              ],
            ),
          ),
          SizedBox(
            height: altoActual * 0.63,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: FutureBuilder<MonedasResponse>(
                future: futureMonedas,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return const Center(
                        child: Text('No hay datos disponibles'));
                  } else {
                    return TabBarView(
                      children: [
                        TopTab(monedas: snapshot.data!.populares),
                        Perdedores(monedas: snapshot.data!.perdedores),
                        Nuevos(monedas: snapshot.data!.ganadores),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
