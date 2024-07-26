import 'package:ejemplo_1/services/crud_monedero_service.dart';
import 'package:ejemplo_1/viewmodels/auth.viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:ejemplo_1/views/services/transaction_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PagarView extends StatefulWidget {
  final String precio;
  final String monedaName;
  final double cantidad;

  const PagarView(
      {super.key,
      required this.cantidad,
      required this.precio,
      required this.monedaName});

  @override
  PagarViewState createState() => PagarViewState();
}

class PagarViewState extends State<PagarView> {
  final Logger logger = Logger();
  late String ordenId;
  late String sessionId;
  bool isLoading = false;
  bool pagoExitoso = false;

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
    final int cantidadInt = widget.cantidad.toInt();
    if (cantidadInt == 0) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Depositar Dinero'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 100),
              const SizedBox(height: 20),
              const Text('No se puede depositar 0 monedas',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Volver a la página principal'),
              ),
            ],
          ),
        ),
      );
    }
    if (pagoExitoso) {
      Logger().i(
          'Pago exitoso \n aquí ya se puede agregar la lógica para agregar la nueva moneda a la lista de monedas del usuario');
      Logger().i(
          'para luego enviarla al backend, enviar la nueva lista de monedas al backend que son las antiguas más la nueva moneda');

      int now = DateTime.now().millisecondsSinceEpoch;
      Map<String, dynamic> mapMoneda = {
        'id': now,
        'nombre': widget.monedaName,
        'cantidad': widget.cantidad.toInt(),
      };

      Moneda moneda = Moneda.fromMap(mapMoneda);

      Logger().i('Payload: \n userId: $sessionId \n moneda: ${moneda.toMap()}');

      MonederoService().addMoneda(sessionId, mapMoneda);
      // Aquí se debe agregar la moneda al monedero del usuario

      return Scaffold(
        appBar: AppBar(
          title: const Text('Depositar Dinero'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 100),
              const SizedBox(height: 20),
              const Text('Su pago fue exitoso',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Volver a la página principal'),
              ),
            ],
          ),
        ),
      );
    }

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
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text('Orden ID: $ordenId',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500)),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Center(
                        child: Text('Método de pago',
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
                    "\$ ${widget.precio} CLP",
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
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 5),
                      Text(
                        '${widget.cantidad.toInt()} ${widget.monedaName}',
                        style: const TextStyle(
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
                              monto: int.parse(widget.precio),
                            );

                            try {
                              String? redirectUrl = await TransactionService()
                                  .saveTransaction(transaction);

                              if (redirectUrl != null) {
                                if (context.mounted) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => WillPopScope(
                                      onWillPop: () async {
                                        // Logica al presionar la flecha hacia atrás
                                        final bool isAprobada =
                                            await TransactionService()
                                                .existsTransaction(
                                                    ordenId, sessionId);
                                        if (isAprobada) {
                                          setState(() {
                                            pagoExitoso = true;
                                          });
                                        } else {
                                          Logger().e('Transacción no aprobada');
                                          if (context.mounted) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Transacción no aprobada o cancelada antes de finalizar'),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }
                                        }
                                        return true; // Permite la navegación hacia atrás
                                      },
                                      child: Scaffold(
                                        appBar: AppBar(
                                          title: const Text('WebView'),
                                        ),
                                        body: WebViewWidget(
                                          controller: WebViewController()
                                            ..setJavaScriptMode(
                                                JavaScriptMode.unrestricted)
                                            ..loadRequest(
                                                Uri.parse(redirectUrl))
                                            ..setNavigationDelegate(
                                              NavigationDelegate(
                                                onPageFinished:
                                                    (String url) async {
                                                  // Puedes manejar otras lógicas aquí si es necesario
                                                },
                                              ),
                                            ),
                                        ),
                                      ),
                                    ),
                                  ));
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Error al guardar la transacción'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
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
                        ? const CircularProgressIndicator()
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
}
