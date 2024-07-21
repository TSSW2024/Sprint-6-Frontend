import 'package:ejemplo_1/views/Loot/drops.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './loot.coin.dart';

class Loot extends StatelessWidget {
  const Loot({super.key});

  // Un Row que representa un Appbar con un icono al asset // SvgPicture.asset('assets/images/LogoP.svg') que es el logo de la empresa
  // con un título UTEMTX y un botón hacia atrás

  Row _buildAppbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        // Botón de retroceso
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Lógica para el botón de retroceso
            Navigator.pop(context);
          },
        ),
        Row(
          children: [
            SvgPicture.asset(
              'assets/images/LogoP.svg',
              height: 50,
              width: 50,
            ),
            const SizedBox(width: 10),
            const Text(
              'UTEMTX',
              style: TextStyle(fontSize: 20),
            ),
          ],
        ),
        const SizedBox(width: 50),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        children: [
          _buildAppbar(context),
          const SizedBox(height: 10),
          Column(
            children: [
              const DropsWidget(),
              CryptoLootBox(),
            ],
          ),
        ],
      ),
    ));
  }
}
