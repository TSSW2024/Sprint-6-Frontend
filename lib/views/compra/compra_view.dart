import 'package:ejemplo_1/views/compra/webpay_view.dart';
import 'package:flutter/material.dart';
import '../../widgets/numeric_keyboard.dart';
import '../../widgets/quick_buttons.dart';


class CompraView extends StatefulWidget {
  final String monedaName;

  const CompraView({Key? key, required this.monedaName}) : super(key: key);

  @override
  _CompraViewState createState() => _CompraViewState();
}

class _CompraViewState extends State<CompraView> {
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final String moneda = widget.monedaName;
    return Scaffold(
      appBar: AppBar(
        title: Text('Compra de $moneda'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPriceBar(),
            SizedBox(height: 20),
            QuickButtons(
              controller: _controller,
            ),
            SizedBox(height: 20),
            NumericKeyboard(
              controller: _controller,
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // naveegar a la pantalla de pago
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PagarView(
                              cantidad: _controller.text,
                              monedaName: moneda,
                            )),
                  );
                },
                child: Text('Pagar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quiero pagar'),
            ElevatedButton(
              onPressed: () {
                // Lógica para "Por monto"
              },
              child: Text('Por monto'),
            ),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Ingresar la cantidad',
            suffixText: 'CLP',
          ),
          onChanged: (value) {
            // Validación numérica
            if (!RegExp(r'^\d+$').hasMatch(value)) {
              _controller.text = value.replaceAll(RegExp(r'[^\d]'), '');
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: _controller.text.length),
              );
            }
          },
        ),
      ],
    );
  }
}
