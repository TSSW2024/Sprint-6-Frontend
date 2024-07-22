import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ejemplo_1/models/users_model.dart';
import 'package:logger/logger.dart';

class CrudServicesAgregarUsuario {
  final String baseUrl = "https://backend-transaccion.tssw.cl/";

  // Método para verificar si el usuario ya existe
  Future<bool> doesUserExist(String uid) async {
    final url = Uri.parse(
        '${baseUrl}users/$uid'); // Asume que la URL con el UID consulta el usuario
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        // Agrega más cabeceras si es necesario, como 'Authorization'
      },
    );

    if (response.statusCode == 200) {
      // El usuario existe si la respuesta es exitosa
      return true;
    } else if (response.statusCode == 404) {
      // El usuario no existe si el servidor responde con 404
      return false;
    } else {
      // Maneja otros códigos de error
      throw Exception('Error al verificar existencia del usuario');
    }
  }

  // Método para agregar un usuario si no existe
  Future<void> postUser(UserModel user) async {
    try {
      // Verificar si el usuario ya existe
      final userExists = await doesUserExist(user.uid);

      if (userExists) {
        Logger().i('El usuario ya existe');
        return; // El usuario ya existe, no hacemos nada
      }

      // Si el usuario no existe, agregarlo
      final url = Uri.parse('${baseUrl}users');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Agrega más cabeceras si es necesario, como 'Authorization'
        },
        body: jsonEncode({
          'usuarioID': user.uid,
          'nombre': user.displayName,
        }), // Solo envía uid y displayName
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // La solicitud fue exitosa
        Logger().i('Usuario agregado exitosamente');
      } else {
        // Maneja el error aquí
        Logger().e(
            'Error al agregar el usuario: ${response.statusCode} ${response.body}');
        throw Exception('Failed to post user data');
      }
    } catch (e) {
      // Maneja el error de verificación o de adición
      Logger().e('Error al manejar usuario: $e');
      throw e; // Vuelve a lanzar el error después de registrarlo
    }
  }
}
