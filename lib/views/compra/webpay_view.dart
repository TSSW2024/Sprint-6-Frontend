import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PagarView extends StatelessWidget {

  final String cantidad; 
  final String monedaName;
  const PagarView( {Key? key, required this.cantidad, required this.monedaName}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final double cantidadCLP = double.tryParse(cantidad) ?? 0.0;
    final double cantidadConvertida = _convertirMoneda(cantidadCLP, monedaName);

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
                   "\$ $cantidad CLP",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Image.asset('assets/images/logo-webpay.png', height: 150),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 5),
                      Text(
                        '$cantidadConvertida $monedaName',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
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
}

double _convertirMoneda(double cantidad, String monedaName) {
  const double tasaBtc = 0.000000018689; // 1 CLP = 0.000000018689 BTC  
  const double tasaEth = 0.000000346378 ; // 1 CLP = 0.000000346378 ETH
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
