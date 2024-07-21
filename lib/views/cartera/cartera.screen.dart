import 'package:ejemplo_1/models/moneda.dart';
import 'package:ejemplo_1/views/market/market_page.dart';
import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import '../home/saldo/saldo.dart';
import '../../viewmodels/profile.viewmodel.dart';
// Asegúrate de tener la ruta correcta

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  @override
  Widget build(BuildContext context) {
    var profileViewModel = Provider.of<ProfileViewModel>(context);
    final List<Moneda> monedas = profileViewModel.profile.monedas;

    var saldototal = profileViewModel.profile.saldototal;

    List<Color> pieColors = [
      Colors.orange,
      Colors.grey,
      Colors.blue,
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SaldoWidget(saldo: saldototal),
                const SizedBox(height: 20),
                PieChart(
                  dataMap: {
                    for (var moneda in monedas) moneda.symbol: moneda.value
                  },
                  colorList: pieColors,
                  chartRadius: MediaQuery.of(context).size.width / 2.7,
                  chartType: ChartType.ring,
                  centerText: "Monedas",
                  legendOptions: const LegendOptions(
                    showLegendsInRow: false,
                    legendPosition: LegendPosition.right,
                    showLegends: true,
                    legendTextStyle: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  chartValuesOptions: const ChartValuesOptions(
                    showChartValueBackground: true,
                    showChartValues: true,
                    showChartValuesInPercentage: true,
                    showChartValuesOutside: false,
                    decimalPlaces: 2,
                  ),
                ),
                const Text(
                  'Lista de monedas:',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
                // ListView Builder
                // Moneda(symbol, icon, value)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: monedas.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(monedas[index].icon),
                      ),
                      title: Text(monedas[index].symbol),
                      subtitle: Text('Valor: \$${monedas[index].value}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MarketPage(
                              symbol: monedas[index].symbol,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
