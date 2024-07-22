import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

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
  final String endpoint;
  final bool isPremium;

  CryptoLootBox({required this.endpoint, required this.isPremium});

  @override
  CryptoLootBoxState createState() => CryptoLootBoxState();
}

class CryptoLootBoxState extends State<CryptoLootBox> {
  List<Item> items = [];
  Item? selectedItem;
  CarouselController buttonCarouselController = CarouselController();
  bool isSpinning = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse(widget.endpoint));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        items = data.map<Item>((json) => Item(
          name: json['Nombre'],
          chance: json['Probabilidad'],
          imageUrl: json['Icono'],
          ganancia: json['Ganancia'],
        )).toList();
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

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
    if (items.isEmpty) return; // Asegurarse de que haya ítems antes de girar

    final item = getRandomItem();
    setState(() {
      selectedItem = null;
      isSpinning = true;
    });

    final itemIndex = items.indexOf(item);
    final randomCycles = Random().nextInt(5) + 5; // Random cycles between 5 and 10
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
    if (items.isEmpty) return; // Asegurarse de que haya ítems antes de simular

    final item = getRandomItem();
    setState(() {
      selectedItem = null; // Hide the result while spinning
      isSpinning = true;
    });

    final itemIndex = items.indexOf(item);
    final randomCycles = Random().nextInt(5) + 5; // Random cycles between 5 and 10
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
            const Spacer(flex: 1),
            const Text(
              'Caja de Botín',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Spacer(flex: 1),
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Subscripción'),
                      content: const Text(
                          'Te has suscrito a la Caja de Botín, recibirás notificaciones cada 8 horas'),
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
                                    leading: Image.network(
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
                return Image.network(item.imageUrl, fit: BoxFit.cover);
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
        const SizedBox(height: 110),
        ElevatedButton(
          onPressed: isSpinning ? null : spinWheel,
          child: const Text(
            'Girar Ruleta',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.yellow[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 25),
        ElevatedButton(
          onPressed: isSpinning ? null : simulateSpin,
          child: const Text('Simular', style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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