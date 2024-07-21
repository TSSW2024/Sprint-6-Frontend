import 'package:ejemplo_1/models/criptomonedasFetch.dart';
import 'package:ejemplo_1/views/market/market_page.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class TopTab extends StatefulWidget {
  final List<Moneda> monedas;

  const TopTab({super.key, required this.monedas});

  @override
  TopTabState createState() => TopTabState();
}

class TopTabState extends State<TopTab> {
  Map<String, bool> likes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.monedas.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            final String symbol = '${widget.monedas[index].name}USDT';

            Logger().i('Tapped on $symbol');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketPage(symbol: symbol),
              ),
            );
          },
          child: Container(
            height: 60,
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  flex: 1,
                  child: Image.network(
                    widget.monedas[index].image,
                    width: 50,
                    height: 50,
                  ),
                ),
                Flexible(
                  flex: 3,
                  fit: FlexFit.tight,
                  child: Text(
                    widget.monedas[index].name,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Column(
                    children: [
                      Text(
                        widget.monedas[index].price,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0)),
                      ),
                      Text(
                        widget.monedas[index].change24h,
                        style: widget.monedas[index].change24h.contains('-')
                            ? const TextStyle(
                                color: Color.fromARGB(255, 206, 51, 12))
                            : const TextStyle(
                                color: Color.fromARGB(255, 30, 187, 64)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
