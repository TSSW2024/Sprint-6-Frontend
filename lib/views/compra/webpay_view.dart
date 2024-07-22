import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ejemplo_1/views/services/transaction_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PagarView extends StatefulWidget {
  final String cantidad;
  final String monedaName;

  const PagarView(
      {super.key, required this.cantidad, required this.monedaName});

  @override
  PagarViewState createState() => PagarViewState();
}

class PagarViewState extends State<PagarView> {
  final Logger logger = Logger();
  late String ordenId;
  late String sessionId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthViewModel>(context, listen: false).user;
    final userEmail = user!.email;
    sessionId = user.uid;
    final now = DateFormat('MMddHHmmss').format(DateTime.now());
    ordenId = '${now}_${userEmail.split("@").first}';
  }

  @override
  Widget build(BuildContext context) {
    final double cantidadCLP = double.tryParse(widget.cantidad) ?? 0.0;
    final double cantidadConvertida =
        _convertirMoneda(cantidadCLP, widget.monedaName);

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
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                        child: Text('Metodo de pago',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold))),
                  ),
                  const SizedBox(height: 20),
                  SvgPicture.asset('assets/images/credit-card.svg', height: 80),
                  const SizedBox(height: 20),
                  const Center(
                      child: Text('Monto a pagar',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w500))),
                  const SizedBox(height: 10),
                  Center(
                      child: Text(
                    "\$ ${widget.cantidad} CLP",
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
                        '$cantidadConvertida ${widget.monedaName}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            setState(() {
                              isLoading = true;
                            });

                            Transaction transaction = Transaction(
                              ordenId: ordenId,
                              sessionId: sessionId,
                              monto: cantidadCLP.toInt(),
                            );

                            try {
                              String? redirectUrl = await TransactionService()
                                  .saveTransaction(transaction);

                              if (redirectUrl != null) {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => Scaffold(
                                    appBar: AppBar(title: Text('WebView')),
                                    body: WebViewWidget(
                                      controller: WebViewController()
                                        ..setJavaScriptMode(
                                            JavaScriptMode.unrestricted)
                                        ..loadRequest(Uri.parse(redirectUrl))
                                        ..setNavigationDelegate(
                                          NavigationDelegate(
                                            onPageFinished: (String url) {
                                              setState(() {
                                                isLoading = false;
                                              });
                                            },
                                          ),
                                        ),
                                    ),
                                  ),
                                ));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Error al guardar la transacción'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Error al procesar la transacción'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          },
                    child: isLoading
                        ? CircularProgressIndicator()
                        : const Text('Depositar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
}
