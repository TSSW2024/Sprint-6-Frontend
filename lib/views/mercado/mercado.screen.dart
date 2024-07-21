import 'package:ejemplo_1/models/criptomonedasFetch.dart';
import 'package:ejemplo_1/views/mercado/cripto_search.dart';
import 'package:flutter/material.dart';
import 'package:ejemplo_1/services/monedas_service.dart';

import 'widgets/mercado_tab.dart';

class MercadoScreen extends StatefulWidget {
  const MercadoScreen({super.key});

  @override
  MercadoScreenState createState() => MercadoScreenState();
}

class MercadoScreenState extends State<MercadoScreen> {
  late Future<MonedasResponse> futureMonedas;

  @override
  void initState() {
    super.initState();
    futureMonedas = fetchMonedas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Mercado',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const CryptoTypeaheadWidget(),
            MercadoTab(futureMonedas: futureMonedas),
          ],
        ),
      ),
    );
  }
}
