import 'dart:convert';

import 'package:ejemplo_1/views/cartera/historial_transacciones.dart';

class TransactionService {
  get http => null;

  Future<String?> saveTransaction(Transaction transaction) async {
    // Código para guardar la transacción y obtener la URL de redirección
  }

  Future<String> checkTransactionStatus(String sessionId) async {
    final response = await http
        .get(Uri.parse('https://backend-transaccion.tssw.cl/log/$sessionId'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data[
          'status']; // Asegúrate de que la respuesta contenga el campo 'status'
    } else {
      throw Exception('Error al consultar el estado de la transacción');
    }
  }
}
