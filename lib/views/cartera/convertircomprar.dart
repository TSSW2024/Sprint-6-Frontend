import 'package:ejemplo_1/views/compra/compra_view.dart';
import 'package:ejemplo_1/views/convertir/convertir_view.dart';
import 'package:flutter/material.dart';

class ComprarConvertir extends StatelessWidget {
  final String monedaNombre;
  const ComprarConvertir({super.key, required this.monedaNombre});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(monedaNombre,
              style: const TextStyle(fontSize: 20, color: Colors.white)),
        ),
        Row(
          children: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConvertirView(
                      monedaName: monedaNombre,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.orange),
              ),
              child: const Text('Convertir',
                  style: TextStyle(color: Colors.black)),
            ),
            const SizedBox(width: 10), // Espacio entre botones
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompraView(
                      monedaName: monedaNombre,
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
              ),
              child:
                  const Text('Comprar', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ],
    );
  }
}
