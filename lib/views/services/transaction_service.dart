import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class Transaction {
  String ordenId;
  String sessionId;
  int monto;
  String status = "";

  Transaction(
      {required this.ordenId,
      required this.sessionId,
      required this.monto,
      this.status = ''});

  Map<String, dynamic> toJson() => {
        'orden_id': ordenId,
        'session_id': sessionId,
        'monto': monto,
        'url_retorno': 'https://backend-webpay.tssw.cl/commit',
      };

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      ordenId: json['number_order'] ?? '',
      sessionId: json['id_session'] ?? '',
      monto: json['amount'] ?? 0,
      status: json['status'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Transaction{ordenId: $ordenId, sessionId: $sessionId, monto: $monto}';
  }

  // constructor empty
  factory Transaction.empty() {
    return Transaction(
      ordenId: '',
      sessionId: '',
      monto: 0,
    );
  }

  // is empty
  bool get isEmpty => ordenId.isEmpty && sessionId.isEmpty && monto == 0;
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

  Future<List<Transaction>> getLoggedUserTransactions(String sessionId) async {
    Logger()
        .i('Obteniendo transacciones del usuario con sessionId: $sessionId');
    var url = Uri.parse('https://backend-transaccion.tssw.cl/log/$sessionId');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      // Procesar respuesta como lista de objetos
      final List<dynamic> data = json.decode(response.body);
      Logger().i('Transacciones obtenidas: $data');
      List<Transaction> transactions =
          data.map((e) => Transaction.fromJson(e)).toList();
      return transactions;
    } else {
      // Manejar error
      print('Error al obtener las transacciones: ${response.body}');
      return [];
    }
  }

  Future<Transaction?> getTransactionById(
      String orderId, String sessionId) async {
    //usuar la funcion getLoggedUserTransactions para obtener las transacciones del usuario
    // y luego buscar la transaccion por orderId

    List<Transaction> transactions = await getLoggedUserTransactions(sessionId);
    Logger().i('Transacciones del usuario: $transactions');

    Transaction? transaction = transactions.firstWhere(
        (element) => element.ordenId == orderId,
        orElse: () => Transaction.empty());

    if (transaction.isEmpty) {
      return null;
    } else {
      return transaction;
    }
  }

  Future<bool> existsTransaction(String orderId, String sessionId) async {
    Transaction? transaction = await getTransactionById(
        orderId, sessionId); //usar la funcion getTransactionById
    return transaction != null;
  }
}
