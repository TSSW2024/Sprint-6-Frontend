import 'package:ejemplo_1/models/criptomonedasFetch.dart';
import 'package:ejemplo_1/views/mercado/cripto_search.dart';
import 'package:flutter/material.dart';
import 'package:ejemplo_1/services/monedas_service.dart';
import 'package:logger/logger.dart';
import 'dart:async';

import 'widgets/mercado_tab.dart';

class MercadoScreen extends StatefulWidget {
  const MercadoScreen({super.key});

  @override
  MercadoScreenState createState() => MercadoScreenState();
}

class MercadoScreenState extends State<MercadoScreen> {
  late Future<MonedasResponse> futureMonedas;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    futureMonedas = fetchMonedas();
    _startFetchingMonedas();
  }

  void _startFetchingMonedas() {
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      setState(() {
        Logger().i('Fetching monedas');
        futureMonedas = fetchMonedas();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
