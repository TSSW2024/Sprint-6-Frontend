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
      appBar: AppBar(
        title: Text('Market Data for ${widget.symbol.toUpperCase()}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DropdownButton<String>(
            value: interval,
            onChanged: (String? newValue) {
              if (newValue != null) {
                _handleIntervalChange(newValue);
              }
            },
            items: <String>['1m', '5m', '15m', '30m', '1h', '1d']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          FutureBuilder<List<Candlestick>>(
            future: futureCandlestickData,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No data available');
              } else {
                final yAxisFormat = _getYAxisFormat(snapshot.data!);

                return Expanded(
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: SfCartesianChart(
                        primaryXAxis: DateTimeAxis(
                          zoomPosition: 1, // Initial zoom position (optional)
                          zoomFactor: 1, // Initial zoom factor (optional)
                        ),
                        primaryYAxis: NumericAxis(
                          numberFormat: NumberFormat(yAxisFormat),
                        ),
                        zoomPanBehavior: ZoomPanBehavior(
                          enablePinching: true,
                          enablePanning: true,
                          zoomMode: ZoomMode.x,
                        ),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        series: <CartesianSeries>[
                          CandleSeries<Candlestick, DateTime>(
                            dataSource: snapshot.data!,
                            xValueMapper: (Candlestick data, _) => data.date,
                            lowValueMapper: (Candlestick data, _) => data.low,
                            highValueMapper: (Candlestick data, _) => data.high,
                            openValueMapper: (Candlestick data, _) => data.open,
                            closeValueMapper: (Candlestick data, _) =>
                                data.close,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
