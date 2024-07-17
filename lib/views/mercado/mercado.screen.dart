import 'package:ejemplo_1/models/criptomonedasFetch.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cripto_search.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'invitacion.dart';
import 'package:ejemplo_1/services/monedas_service.dart';

final List _monedas = [
  {
    "moneda": "BTC",
    "value": 69350.08,
    "ratio": -1.0900,
    "icon": "assets/images/bitcoin.png"
  },
  {
    "moneda": "ETH",
    "value": 2350.67,
    "ratio": 0.7600,
    "icon": "assets/images/etherum.png"
  },
  {
    "moneda": "LTC",
    "value": 182.54,
    "ratio": 2.1500,
    "icon": "assets/images/litecoin.png"
  },
];

class MercadoScreen extends StatefulWidget {
  const MercadoScreen({super.key});

  @override
  _MercadoScreenState createState() => _MercadoScreenState();
}

class _MercadoScreenState extends State<MercadoScreen> {
  late Future<MonedasResponse> futureMonedas;

  @override
  void initState() {
    super.initState();
    futureMonedas = fetchMonedas();
  }

  @override
  Widget build(BuildContext context) {
    final altoActual = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 1, // 1 tabs: Mercado
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            bottom: const TabBar(
              tabs: [
                Tab(
                  child: Text("Mercado", style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          children: [
            MercadoTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => InvitacionScreen()),
            );
          },
          backgroundColor: Colors.yellowAccent,
          child: SvgPicture.asset(
            'assets/images/gift-svgrepo-com (2).svg',
            width: 50,
            height: 50,
          ),
        ),
      ),
    );
  }
}

class MercadoTab extends StatelessWidget {
  final Future<MonedasResponse> futureMonedas;

  const MercadoTab({super.key, required this.futureMonedas});

  @override
  Widget build(BuildContext context) {
    final altoActual = MediaQuery.of(context).size.height;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(width: 10), // Espacio entre los elementos
              Expanded(
                child: CryptoTypeaheadWidget(),
              ),
            ],
          ),
          Container(
            color: Colors.transparent,
            child: TabBar(
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.grey, width: 2),
              ),
              indicatorPadding: const EdgeInsets.all(10),
              overlayColor: MaterialStateProperty.all(Colors.transparent),
              tabs: [
                Tab(text: 'Populares'),
                Tab(text: 'Perdedores'),
                Tab(text: 'Ganadores'),
              ],
            ),
          ),
          SizedBox(
            height: altoActual * 0.5,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: FutureBuilder<MonedasResponse>(
                future: futureMonedas,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    return Center(child: Text('No hay datos disponibles'));
                  } else {
                    return TabBarView(
                      children: [
                        TopTab(monedas: snapshot.data!.populares),
                        Perdedores(monedas: snapshot.data!.perdedores),
                        Nuevos(monedas: snapshot.data!.ganadores),
                      ],
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopTab extends StatefulWidget {
  final List<Moneda> monedas;

  const TopTab({super.key, required this.monedas});

  @override
  _TopTabState createState() => _TopTabState();
}

class _TopTabState extends State<TopTab> {
  Map<String, bool> likes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.monedas.length,
      itemBuilder: (context, index) {
        String moneda = widget.monedas[index].name;
        bool isLiked = likes[moneda] ?? false;

        return Container(
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
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      widget.monedas[index].price,
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(widget.monedas[index].change24h),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.star : Icons.star_border,
                  color: isLiked ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    likes[moneda] = !isLiked;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class Perdedores extends StatefulWidget {
  final List<Moneda> monedas;

  const Perdedores({super.key, required this.monedas});

  @override
  _PerdedoresState createState() => _PerdedoresState();
}

class _PerdedoresState extends State<Perdedores> {
  Map<String, bool> likes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.monedas.length,
      itemBuilder: (context, index) {
        String moneda = widget.monedas[index].name;
        bool isLiked = likes[moneda] ?? false;

        return Container(
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
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      widget.monedas[index].price,
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(widget.monedas[index].change24h),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.star : Icons.star_border,
                  color: isLiked ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    likes[moneda] = !isLiked;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class Nuevos extends StatefulWidget {
  final List<Moneda> monedas;

  const Nuevos({super.key, required this.monedas});

  @override
  _NuevosState createState() => _NuevosState();
}

class _NuevosState extends State<Nuevos> {
  Map<String, bool> likes = {};

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.monedas.length,
      itemBuilder: (context, index) {
        String moneda = widget.monedas[index].name;
        bool isLiked = likes[moneda] ?? false;

        return Container(
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
                flex: 1,
                child: Column(
                  children: [
                    Text(
                      widget.monedas[index].price,
                      style: const TextStyle(color: Colors.green),
                    ),
                    Text(widget.monedas[index].change24h),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isLiked ? Icons.star : Icons.star_border,
                  color: isLiked ? Colors.yellow : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    likes[moneda] = !isLiked;
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
