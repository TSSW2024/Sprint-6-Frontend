import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:ejemplo_1/models/users_model.dart';

Future<void> sendUserUID(UserModel user) async {
  final url =
      Uri.parse('https://backend-transaccion.tssw.cl/log'); // URL del endpoint
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
    Logger().i('UID enviado exitosamente');
    Logger().i('Response body: ${response.body}');
  } else {
    Logger().e('Error al enviar UID: ${response.statusCode}');
    Logger().i('Response body: ${response.body}');
  }
}
