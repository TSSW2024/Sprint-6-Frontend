import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejemplo_1/models/users_model.dart';
import 'package:logger/logger.dart';

Future<void> createOrUpdateMonedero(
    UserModel user, List<Map<String, dynamic>> monedas) async {
  final url = Uri.parse('https://backend-transaccion.tssw.cl/wallet'); // URL
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'usuarioID': user.uid, // Usa el uid del UserModel
      'monedas':
          monedas, // Asegúrate de que esta estructura coincida con tu modelo
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    Logger().i('Monedero creado o actualizado exitosamente');
    Logger().i('Response body: ${response.body}');
  } else {
    Logger().e('Error al crear o actualizar monedero: ${response.statusCode}');
    Logger().i('Response body: ${response.body}');
  }
}
