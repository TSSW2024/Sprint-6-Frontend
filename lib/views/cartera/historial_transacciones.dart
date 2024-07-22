import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:provider/provider.dart';

class Transaction {
  final String description;
  final String amount;
  final String network;
  final String date;
  final String time;

  Transaction({
    required this.description,
    required this.amount,
    required this.network,
    required this.date,
    required this.time,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    String dateTime = json['transaction_date'];
    DateTime parsedDate = DateTime.parse(dateTime);
    String date = '${parsedDate.year}-${parsedDate.month}-${parsedDate.day}';
    String time =
        '${parsedDate.hour}:${parsedDate.minute}:${parsedDate.second}';

    return Transaction(
      description: json[
          'authorization_code'], // deje el codigo de autorizacion solo para diferenciar las transacciones
      amount: json['amount'].toString(),
      network: json['payment_type_code'],
      date: date,
      time: time,
    );
  }

  Object? toJson() {}
}

class TransactionScreen extends StatefulWidget {
  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  List<Transaction> transactions = [];
  late AuthViewModel authViewmodel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authViewmodel = Provider.of<AuthViewModel>(context);
    final currentUser = authViewmodel.user;

    if (currentUser != null) {
      fetchTransactions(currentUser);
    } else {
      // Handle the case where currentUser is null
      print('User is not logged in');
    }
  }

  Future<void> fetchTransactions(currentUser) async {
    final response = await http.get(Uri.parse(
        'https://backend-transaccion.tssw.cl/log/${currentUser.uid}'));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      List<Transaction> loadedTransactions = jsonResponse
          .where((trans) => trans['status'] == 'AUTHORIZED')
          .map((trans) => Transaction.fromJson(trans))
          .toList();

      setState(() {
        transactions = loadedTransactions;
      });
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transacciones'),
      ),
      body: transactions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(transactions[index].description),
                  subtitle: Text(
                      'Monto: ${transactions[index].amount} | Tipo: ${transactions[index].network}'),
                  trailing: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(transactions[index].date),
                      Text(transactions[index].time),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
