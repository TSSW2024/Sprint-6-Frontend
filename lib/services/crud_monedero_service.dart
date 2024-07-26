import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejemplo_1/models/users_model.dart';
import 'package:logger/logger.dart';

import 'dart:async';
import 'crypto_conversion_service.dart';

class Moneda {
  final int id;
  final String nombre;
  final double cantidad;

  Moneda({required this.id, required this.nombre, required this.cantidad});

  factory Moneda.fromMap(Map<String, dynamic> map) {
    return Moneda(
      id: map['id'] ?? 0,
      nombre: map['nombre'] ?? '',
      cantidad: (map['cantidad'] is int)
          ? (map['cantidad'] as int).toDouble()
          : (map['cantidad'] ?? 0.0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad % 1 == 0 ? cantidad.toInt() : cantidad,
    };
  }

  @override
  String toString() {
    return 'Moneda{id: $id, nombre: $nombre, cantidad: $cantidad}';
  }
}

class Monedero {
  final int id;
  final String usuarioID;
  final List<Moneda> monedas;

  Monedero({
    required this.id,
    required this.usuarioID,
    required this.monedas,
  });

  factory Monedero.fromMap(Map<String, dynamic> map) {
    return Monedero(
      id: map['id'] ?? 0,
      usuarioID: map['usuarioID'] ?? '',
      monedas: List<Moneda>.from(map['monedas'].map((x) => Moneda.fromMap(x))),
    );
  }

  @override
  String toString() {
    return 'Monedero{id: $id, usuarioID: $usuarioID, monedas: $monedas}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuarioID': usuarioID,
      'monedas': List<dynamic>.from(monedas.map((x) => x.toMap())),
    };
  }

  factory Monedero.empty() {
    return Monedero(
      id: 0,
      usuarioID: '',
      monedas: [],
    );
  }

  Future<double> getSaldoTotalEnCLP() async {
    final conversionService = CryptoConversionService();
    double total = 0.0;
    for (final moneda in monedas) {
      try {
        final valorEnCLP = await conversionService.convertCryptoToCLP(
            moneda.nombre, moneda.cantidad);
        total += valorEnCLP;
      } catch (e) {
        Logger().e('Error al convertir ${moneda.nombre} a CLP: $e');
      }
    }
    return total;
  }

  Future<Map<String, double>> get dataMap async {
    final Map<String, double> dataMap = {};
    final conversionService = CryptoConversionService();

    for (final moneda in monedas) {
      try {
        final valorEnCLP = await conversionService.convertCryptoToCLP(
            moneda.nombre, moneda.cantidad);
        dataMap[moneda.nombre] = valorEnCLP;
      } catch (e) {
        Logger().e('Error al convertir ${moneda.nombre} a CLP: $e');
      }
    }
    return dataMap;
  }
}

class MonederoService {
  final String baseUrl = "https://backend-transaccion.tssw.cl/";

  Future<Monedero?> createOrUpdateMonedero(UserModel user) async {
    final url = Uri.parse('${baseUrl}wallet');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'usuarioID': user.uid, // Usa el uid del UserModel
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      Logger().i('Monedero creado o actualizado exitosamente');
      Logger().i('Response body: ${response.body}');
      final result = jsonDecode(response.body);
      return Monedero.fromMap(result);
    } else {
      Logger()
          .e('Error al crear o actualizar monedero: ${response.statusCode}');
      Logger().i('Response body: ${response.body}');
      throw Exception('Error al crear o actualizar monedero');
    }
  }

  // el endpoint /wallet/moneda con POST
  // json:
  //{
  //"userId": "9gq1YfnTLdQnXk8vMH4YqnqB5u62",
  //"moneda": {
  //  "id": 7416062790,
  //  "nombre": "BTCUSDT",
  //  "cantidad": 1
  //}
  // permite agregar una moneda a un monedero
  Future<void> addMoneda(String sessionId, Map<String, dynamic> moneda) {
    final url = Uri.parse('${baseUrl}wallet/moneda');
    return http
        .post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'userId': sessionId,
        'moneda': moneda,
      }),
    )
        .then((response) {
      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger().i('Moneda agregada exitosamente');
        Logger().i('Response body: ${response.body}');
      } else {
        Logger().e('Error al agregar moneda: ${response.statusCode}');
        Logger().i('Response body: ${response.body}');
        throw Exception('Error al agregar moneda');
      }
    });
  }

  Future<Monedero?> getMonedero(UserModel user) async {
    Logger().i('Obteniendo monedero del usuario con uid: ${user.uid}');
    final url = Uri.parse('${baseUrl}wallet/${user.uid}');
    Logger().i('URL: $url');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      Logger().i('Result obtenido exitosamente: $result');
      return Monedero.fromMap(result);
    } else {
      Logger().e('Error al obtener monedero: ${response.statusCode}');
      throw Exception('Error al obtener monedero');
    }
  }

  Future<bool> doesMonederoExist(UserModel user) async {
    try {
      await getMonedero(user);
      return true;
    } catch (e) {
      return false;
    }
  }
}
