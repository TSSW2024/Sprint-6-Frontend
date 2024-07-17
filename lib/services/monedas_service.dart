import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejemplo_1/models/criptomonedasFetch.dart';

Future<MonedasResponse> fetchMonedas() async {
  final response = await http.get(Uri.parse('https://backend-market.tssw.cl/'));

  if (response.statusCode == 200) {
    return MonedasResponse.fromJson(json.decode(response.body));
  } else {
    throw Exception('Error al cargar las monedas');
  }
}
