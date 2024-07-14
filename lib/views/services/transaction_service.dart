// lib/services/transaction_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class Transaction {
  String ordenId;
  String sessionId;
  int monto;

  Transaction(
      {required this.ordenId, required this.sessionId, required this.monto});

  Map<String, dynamic> toJson() => {
        'orden_id': ordenId,
        'session_id': sessionId,
        'monto': monto,
      };
}

class TransactionService {
  Future<void> saveTransaction(Transaction transaction) async {
    var url = Uri.parse(' https://backend-webpay.tssw.cl/');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode == 200) {
      // Procesar respuesta
      print('Transacción guardada con éxito');
    } else {
      // Manejar error
      print('Error al guardar la transacción: ${response.body}');
    }
  }
}
