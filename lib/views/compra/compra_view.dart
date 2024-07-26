import 'package:ejemplo_1/services/crypto_conversion_service.dart';
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
  CryptoConversionService _conversionService = CryptoConversionService();
  double? _amountInCrypto;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onAmountChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onAmountChanged() async {
    final amountText = _controller.text;
    if (amountText.isNotEmpty) {
      final amountInCLP = double.tryParse(amountText) ?? 0;
      try {
        final amountInCrypto = await _conversionService.convertCLPToCrypto(
            widget.monedaName, amountInCLP);
        setState(() {
          _amountInCrypto = amountInCrypto;
        });
      } catch (e) {
        setState(() {
          _amountInCrypto = null;
        });
      }
    } else {
      setState(() {
        _amountInCrypto = null;
      });
    }
  }

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
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 15, 100, 43),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                onPressed: () {
                  if (_amountInCrypto == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PagarView(
                              precio: _controller.text,
                              cantidad: _amountInCrypto!,
                              monedaName: moneda,
                            )),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 35.0,
                  ),
                  child: Text('Pagar', style: TextStyle(color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 20),
            if (_amountInCrypto != null)
              Text(
                'Cantidad de monedas que puedes comprar: ${_amountInCrypto!.toInt()}', // Ajusta el número de decimales según tu necesidad
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              )
            else
              Text(
                'Cantidad de monedas que puedes comprar: 0',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Quiero pagar'),
          ],
        ),
        SizedBox(height: 8),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
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
