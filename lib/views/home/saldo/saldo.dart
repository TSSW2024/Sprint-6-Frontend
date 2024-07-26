import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Importa la biblioteca intl

class SaldoWidget extends StatefulWidget {
  final double saldo;

  const SaldoWidget({super.key, required this.saldo});

  @override
  SaldoWidgetState createState() => SaldoWidgetState();
}

class SaldoWidgetState extends State<SaldoWidget> {
  bool _showSaldo = true;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(
      locale: 'es_CL', // Define la localización para CLP
      symbol: '\$', // Usa el símbolo del dólar, o cámbialo si usas otro
      decimalDigits: 2, // No mostrar decimales
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 62, 62, 58),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Saldo Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Switch(
                value: _showSaldo,
                onChanged: (value) {
                  setState(() {
                    _showSaldo = value;
                  });
                },
                activeColor: Colors.white,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _showSaldo ? formatter.format(widget.saldo) : '******',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
