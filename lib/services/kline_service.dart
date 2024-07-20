import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class BinanceService {
  Future<List<Candlestick>> fetchCandlestickData(
      String symbol, String interval) async {
    final response = await http.get(
      Uri.parse(
          'https://api.binance.com/api/v3/klines?symbol=$symbol&interval=$interval'),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      final List<Candlestick> candlestickData =
          data.map((item) => Candlestick.fromJson(item)).toList();
      Logger().i('Successfully parsed data from Binance API $candlestickData');
      return data.map((item) => Candlestick.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class Candlestick {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  Candlestick({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory Candlestick.fromJson(List<dynamic> json) {
    return Candlestick(
      date: DateTime.fromMillisecondsSinceEpoch(json[0]),
      open: double.parse(json[1]),
      high: double.parse(json[2]),
      low: double.parse(json[3]),
      close: double.parse(json[4]),
      volume: double.parse(json[5]),
    );
  }

  @override
  // toString como un JSON
  String toString() {
    return jsonEncode({
      'date': date.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    });
  }
}
