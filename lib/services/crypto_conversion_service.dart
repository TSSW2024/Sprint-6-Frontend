import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class CryptoConversionService {
  final String binanceBaseUrl = 'https://api.binance.com';
  final String exchangeRateApiUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  Future<double> getCryptoPrice(String symbol) async {
    final response = await http
        .get(Uri.parse('$binanceBaseUrl/api/v3/ticker/price?symbol=$symbol'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return double.parse(data['price']);
    } else {
      throw Exception('Error al obtener el precio de $symbol');
    }
  }

  Future<double> getUSDTToCLPRate() async {
    final response = await http.get(Uri.parse(exchangeRateApiUrl));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['rates']['CLP'];
    } else {
      throw Exception('Error al obtener la tasa de cambio USDT a CLP');
    }
  }

  Future<double> convertCryptoToCLP(String symbol, double amount) async {
    Logger().i('Convirtiendo $amount $symbol a CLP');
    try {
      final cryptoPriceInUSDT = await getCryptoPrice(symbol);
      final usdtToClpRate = await getUSDTToCLPRate();

      final amountInUSDT = cryptoPriceInUSDT * amount;
      final amountInCLP = amountInUSDT * usdtToClpRate;

      Logger().i('Conversion exitosa: $amount $symbol = $amountInCLP CLP');

      return amountInCLP;
    } catch (e) {
      throw Exception('Error al convertir $symbol a CLP: $e');
    }
  }

  Future<double> convertCLPToCrypto(String symbol, double amount) async {
    Logger().i('Convirtiendo $amount CLP a $symbol');
    try {
      final usdtToClpRate = await getUSDTToCLPRate();
      final cryptoPriceInUSDT = await getCryptoPrice(symbol);
      Logger().i('Precio de $symbol en USDT: $cryptoPriceInUSDT');

      final amountInUSDT = amount / usdtToClpRate;
      Logger().i('Amount in USDT: $amountInUSDT');
      final amountInCrypto = amountInUSDT / cryptoPriceInUSDT;

      Logger().i('Conversion exitosa: $amount CLP = $amountInCrypto $symbol');

      return amountInCrypto;
    } catch (e) {
      throw Exception('Error al convertir CLP a $symbol: $e');
    }
  }
}
