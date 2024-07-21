import 'package:ejemplo_1/services/kline_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class CandlestickChart extends StatelessWidget {
  final String interval;
  final Future<List<Candlestick>> futureCandlestickData;
  final Function(String) onIntervalChange;
  final String Function(List<Candlestick>) getYAxisFormat;

  const CandlestickChart({
    super.key,
    required this.interval,
    required this.futureCandlestickData,
    required this.onIntervalChange,
    required this.getYAxisFormat,
  });

  void _handleIntervalChange(String newValue) {
    onIntervalChange(newValue);
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> intervals = [
      {'value': '1m', 'label': 'Hora'},
      {'value': '5m', 'label': 'Día'},
      {'value': '15m', 'label': 'Semana'},
      {'value': '1h', 'label': 'Mes'},
      {'value': '1d', 'label': 'Año'},
    ];
    return Column(
      children: [
        FutureBuilder<List<Candlestick>>(
          future: futureCandlestickData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: const Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('No data available');
            } else {
              final yAxisFormat = getYAxisFormat(snapshot.data!);

              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
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
                      closeValueMapper: (Candlestick data, _) => data.close,
                    ),
                  ],
                ),
              );
            }
          },
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: intervals
              .map(
                (interval) => ChoiceChip(
                  label: Text(interval['label']!),
                  selected: this.interval == interval['value'],
                  onSelected: (selected) {
                    if (selected) {
                      _handleIntervalChange(interval['value']!);
                    }
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
