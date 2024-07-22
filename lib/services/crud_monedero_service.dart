import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejemplo_1/models/users_model.dart';
import 'package:logger/logger.dart';

class Moneda {
  final int id;
  final String nombre;
  final double cantidad;

  Moneda({required this.id, required this.nombre, required this.cantidad});

  factory Moneda.fromMap(Map<String, dynamic> map) {
    return Moneda(
      id: map['id'] ?? 0,
      nombre: map['nombre'] ?? '',
      cantidad: map['cantidad'] ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'cantidad': cantidad,
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

  Monedero({required this.id, required this.usuarioID, required this.monedas});

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

  // factory empty

  factory Monedero.empty() {
    return Monedero(
      id: 0,
      usuarioID: '',
      monedas: [],
    );
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

  Future<Monedero?> getMonedero(UserModel user) async {
    final url = Uri.parse('${baseUrl}wallet/$user.uid');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      return Monedero.fromMap(result);
    } else {
      throw Exception('Error al obtener monedero');
    }
  }

  Future<bool> doesMonederoExist(UserModel user) async {
    //utiliza getmonedero si falla devuelve el bool
    //si no falla devuelve true

    try {
      await getMonedero(user);
      return true;
    } catch (e) {
      return false;
    }
  }
}
