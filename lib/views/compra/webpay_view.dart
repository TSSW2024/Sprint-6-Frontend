import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:ejemplo_1/views/services/transaction_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class PagarView extends StatelessWidget {
  final String cantidad;
  final String monedaName;
  const PagarView({Key? key, required this.cantidad, required this.monedaName})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double cantidadCLP = double.tryParse(cantidad) ?? 0.0;
    final double cantidadConvertida = _convertirMoneda(cantidadCLP, monedaName);

    // Crear una instancia de TransactionService
    final transactionService = TransactionService();
    final authViewModel = Provider.of<AuthViewModel>(context);
    final user = authViewModel.user!;

    final String ordenId =
        '${DateFormat("MMddHHmmss").format(DateTime.now())}${user.email.split('@').first}';
    Logger().i('Orden ID: $ordenId');

    // Recuperar el estado de la transacción al iniciar la vista
    Future<void> checkTransactionStatus() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? savedOrdenId = prefs.getString('ordenId');
      if (savedOrdenId != null) {
        final Transaction? transaction =
            await transactionService.getTransactionById(savedOrdenId, user.uid);
        if (transaction != null && transaction.status == 'success') {
          // Transacción exitosa
          showSuccessMessage(context);
          prefs.remove('ordenId'); // Remover el ordenId después de usarlo
        } else {
          // Mostrar mensaje de error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Transacción fallida o no encontrada'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }

    // Llamar a checkTransactionStatus al construir la vista
    checkTransactionStatus();

    // Si la transacción ya existe
    return FutureBuilder<Transaction?>(
      future: transactionService.getTransactionById(ordenId, user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle,
                      color: Colors.green, size: 100),
                  const SizedBox(height: 20),
                  const Text('Transacción exitosa',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Volver'),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Depositar Dinero'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(25),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Center(
                              child: Column(
                            children: [
                              Text('Metodo de pago',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              Text(ordenId)
                            ],
                          )),
                        ),
                        const SizedBox(height: 20),
                        SvgPicture.asset('assets/images/credit-card.svg',
                            height: 80),
                        const SizedBox(height: 20),
                        const Center(
                            child: Text('Monto a pagar',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500))),
                        const SizedBox(height: 10),
                        Center(
                            child: Text(
                          "\$ $cantidad CLP",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: Image.asset('assets/images/logo-webpay.png',
                              height: 150),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, color: Colors.green),
                            SizedBox(width: 5),
                            Text(
                              '$cantidadConvertida $monedaName',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            // Guardar el ordenId en SharedPreferences
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            await prefs.setString('ordenId', ordenId);

                            // Crear la transacción
                            Transaction transaction = Transaction(
                              ordenId: ordenId,
                              sessionId: user.uid, // Usa una sesión ID válida
                              monto: cantidadCLP.toInt(),
                            );

                            // Guardar la transacción usando TransactionService
                            String? redirectUrl = await transactionService
                                .saveTransaction(transaction);

                            if (redirectUrl != null) {
                              // Redirigir a la URL de Webpay
                              if (await canLaunch(redirectUrl)) {
                                await launch(redirectUrl);
                                // Esperar hasta que el usuario regrese a la aplicación
                                await Future.delayed(Duration(seconds: 5));
                                checkTransactionStatus();
                              } else {
                                throw 'Could not launch $redirectUrl';
                              }
                            } else {
                              // Mostrar mensaje de error
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error al guardar la transacción'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          child: const Text('Depositar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  double _convertirMoneda(double cantidad, String monedaName) {
    const double tasaBtc = 0.000000018689; // 1 CLP = 0.000000018689 BTC
    const double tasaEth = 0.000000346378; // 1 CLP = 0.000000346378 ETH
    const double tasalite = 0.000015904257778; // 1 CLP = 0.16155089 USD

    switch (monedaName) {
      case 'Bitcoin':
        return cantidad * tasaBtc;
      case 'Ethereum':
        return cantidad * tasaEth;
      case 'Litecoin':
        return cantidad * tasalite;
      default:
        return 0.0;
    }
  }

  void showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transacción exitosa'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
