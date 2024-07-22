import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './loot.coin.dart';

class Loot extends StatelessWidget {
  const Loot({super.key});

  Row _buildAppbar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
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
    final String? endpoint = ModalRoute.of(context)?.settings.arguments as String?;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildAppbar(context),
            const SizedBox(height: 10),
            CryptoLootBox(
              isPremium: endpoint?.contains('caja2') ?? false,
              endpoint: endpoint ?? 'https://api-loot.tssw.cl/caja1',
            ),
          ],
        ),
      ),
    );
  }
}
