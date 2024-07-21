import 'package:ejemplo_1/views/cartera/convertircomprar.dart';
import 'package:ejemplo_1/views/market/candle_stick_chart.dart';
import 'package:flutter/material.dart';
import 'package:ejemplo_1/services/kline_service.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:math';

class MarketPage extends StatefulWidget {
  final String symbol;

  const MarketPage({required this.symbol});

  @override
  MarketPageState createState() => MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  late Future<List<Candlestick>> futureCandlestickData;
  String interval = '1d';

  @override
  void initState() {
    super.initState();
    futureCandlestickData = BinanceService()
        .fetchCandlestickData(widget.symbol.toUpperCase(), interval);
  }

  void _handleIntervalChange(String newInterval) {
    setState(() {
      interval = newInterval;
      futureCandlestickData = BinanceService()
          .fetchCandlestickData(widget.symbol.toUpperCase(), interval);
    });
  }

  String _getYAxisFormat(List<Candlestick> data) {
    final minValue = data.map((e) => e.low).reduce((a, b) => a < b ? a : b);
    final maxValue = data.map((e) => e.high).reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    int decimalPlaces = 0;

    if (range > 0) {
      double orderOfMagnitude = log(range) / log(10);
      decimalPlaces = max(0, (2 - orderOfMagnitude).ceil());
    }

    // Construye el formato del número basado en los lugares decimales calculados
    return '#,##0.${'0' * decimalPlaces}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          color: Colors.green[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Appbar personalizado que tiene el nombre de la empresa y un btón hacia atrás
              // y también la moneda actual
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Column(
                      children: [
                        const Text('UTEMTX', style: TextStyle(fontSize: 20)),
                        Text(widget.symbol),
                      ],
                    ),
                    const SizedBox(width: 50),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: CandlestickChart(
                  interval: interval,
                  futureCandlestickData: futureCandlestickData,
                  onIntervalChange: _handleIntervalChange,
                  getYAxisFormat: _getYAxisFormat,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          color: Colors.black,
          child: ComprarConvertir(monedaNombre: widget.symbol)),
    );
  }
}
