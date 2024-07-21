import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'credit_provider.dart';

class Item {
  final String name;
  final double chance;
  final String imageUrl;
  final double ganancia;

  Item({
    required this.name,
    required this.chance,
    required this.imageUrl,
    required this.ganancia,
  });
}

class CryptoLootBox extends StatefulWidget {
  @override
  CryptoLootBoxState createState() => CryptoLootBoxState();
}

class CryptoLootBoxState extends State<CryptoLootBox> {
  final List<Item> items = [
    Item(
        chance: 0.1,
        name: 'Bitcoin',
        imageUrl: 'assets/images/bitcoin.png',
        ganancia: 0.112),
    Item(
        chance: 0.2,
        name: 'Ethereum',
        imageUrl: 'assets/images/etherum.png',
        ganancia: 0.232),
    Item(
        chance: 0.3,
        name: 'Litecoin',
        imageUrl: 'assets/images/litecoin.png',
        ganancia: 0.345),
    Item(
        chance: 0.1,
        name: 'Tether',
        imageUrl: 'assets/images/tether.png',
        ganancia: 0.123),
    Item(
        chance: 0.1,
        name: 'Binance Coin',
        imageUrl: 'assets/images/binance.png',
        ganancia: 0.123),
    Item(
        chance: 0.1,
        name: 'Ripple',
        imageUrl: 'assets/images/ripple.png',
        ganancia: 0.453),
    Item(
        chance: 0.05,
        name: 'Cardano',
        imageUrl: 'assets/images/cardano.png',
        ganancia: 0.663),
    Item(
        chance: 0.05,
        name: 'Dogecoin',
        imageUrl: 'assets/images/dogecoin.png',
        ganancia: 0.123),
  ];

  // int credits = 1000; // Initial credits
  Item? selectedItem;
  CarouselController buttonCarouselController = CarouselController();
  bool isSpinning = false;

  Item getRandomItem() {
    final totalWeight = items.fold(0.0, (sum, item) => sum + item.chance);
    final randomNum = Random().nextDouble() * totalWeight;

    double cumulativeChance = 0;
    for (final item in items) {
      cumulativeChance += item.chance;
      if (randomNum < cumulativeChance) {
        return item;
      }
    }
    throw Exception('Should not reach here');
  }

  void spinWheel() {
    final creditProvider = Provider.of<CreditProvider>(context, listen: false);
    if (creditProvider.credits < 200) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Créditos insuficientes'),
            content: const Text(
                'No tienes suficientes créditos para girar la ruleta.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
            ],
          );
        },
      );
      return;
    }

    final item = getRandomItem();
    setState(() {
      selectedItem = null;
      isSpinning = true;
      creditProvider.deductCredits(200);
    });

    final itemIndex = items.indexOf(item);
    final randomCycles =
        Random().nextInt(5) + 5; // Random cycles between 5 and 10
    final finalIndex = itemIndex + randomCycles * items.length;

    buttonCarouselController
        .animateToPage(
      finalIndex,
      duration: const Duration(seconds: 5),
      curve: Curves.easeOut,
    )
        .then((_) {
      setState(() {
        selectedItem = item;
        isSpinning = false;
      });
    });
  }

  void simulateSpin() {
    final item = getRandomItem();
    setState(() {
      selectedItem = null; // Hide the result while spinning
      isSpinning = true;
    });

    final itemIndex = items.indexOf(item);
    final randomCycles =
        Random().nextInt(5) + 5; // Random cycles between 5 and 10
    final finalIndex = itemIndex + randomCycles * items.length;

    buttonCarouselController
        .animateToPage(
      finalIndex,
      duration: const Duration(seconds: 5),
      curve: Curves.easeOut,
    )
        .then((_) {
      setState(() {
        selectedItem = item;
        isSpinning = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          children: [
            const SizedBox(width: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.black),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.monetization_on,
                    color: Colors.black,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  SizedBox(
                    width: 50, // Establece un ancho fijo para el texto
                    child: Flexible(
                      child: Text(
                        NumberFormat.decimalPattern().format(
                          Provider.of<CreditProvider>(context).credits,
                        ),
                        style:
                            const TextStyle(color: Colors.black, fontSize: 16),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 1),
            const Text(
              'Loot',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Spacer(flex: 1),
            IconButton(
              onPressed: () {
                //muestra un show dialog que muestra un mensaje que se ha suscrito al loot cada 8 horas
                //funcion pub/sub gcp
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Subscripción'),
                      content: const Text(
                          'Te has suscrito al loot, recibirás notificaciones cada 8 horas'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cerrar'),
                        ),
                      ],
                    );
                  },
                );
              },
              icon: const Icon(Icons.notifications),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                icon: const Icon(Icons.info),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Lista de CriptoMonedas'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: items
                              .map((item) => ListTile(
                                    leading: Image.asset(
                                      item.imageUrl,
                                      height: 50,
                                    ),
                                    title: Text(item.name),
                                    trailing: Text('${item.chance * 100}%'),
                                  ))
                              .toList(),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Cerrar'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        CarouselSlider(
          items: items.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Image.asset(item.imageUrl, fit: BoxFit.cover);
              },
            );
          }).toList(),
          carouselController: buttonCarouselController,
          options: CarouselOptions(
            height: 150.0, // Reduced height of the carousel
            initialPage: 0,
            enableInfiniteScroll: true,
            autoPlay: false,
            enlargeCenterPage: true,
            viewportFraction: 0.5,
            scrollPhysics: const NeverScrollableScrollPhysics(),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: isSpinning ? null : spinWheel,
          child: const Text('Girar Ruleta'),
        ),
        ElevatedButton(
          onPressed: isSpinning ? null : simulateSpin,
          child: const Text('Simular'),
        ),
        if (selectedItem != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  '¡Ganaste ${selectedItem!.name}!',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Ganancia: ${selectedItem!.ganancia}',
                  style: const TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
