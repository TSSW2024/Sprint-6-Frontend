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
        'url_retorno': 'https://backend-webpay.tssw.cl/commit',
      };
}

class TransactionService {
  Future<String?> saveTransaction(Transaction transaction) async {
    var url = Uri.parse('https://backend-webpay.tssw.cl/save-transaction');
    var response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(transaction.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Procesar respuesta como string
      var responseData = response.body;
      print('Respuesta del servidor: $responseData');
      return 'https://backend-webpay.tssw.cl/'; // Ajusta según la estructura de tu respuesta
    } else {
      // Manejar error
      print('Error al guardar la transacción: ${response.body}');
      return null;
    }
  }
}
