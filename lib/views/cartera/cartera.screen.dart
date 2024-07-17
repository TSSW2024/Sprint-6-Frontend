import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import '../home/saldo/saldo.dart';
import '../../viewmodels/profile.viewmodel.dart';
import '../cartera/moneda.dart'; // Asegúrate de tener la ruta correcta

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  @override
  Widget build(BuildContext context) {
    var profileViewModel = Provider.of<ProfileViewModel>(context);
    var dataMap = profileViewModel.profile.monedas.map((key, value) => MapEntry(
        key, value['value'].toDouble())); // Convertir a Map<String, double>
    var saldototal = profileViewModel.profile.saldototal;

    List<Color> pieColors = [
      Colors.orange,
      Colors.grey,
      Colors.blue,
    ];

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SaldoWidget(saldo: saldototal),
              const SizedBox(height: 20),
              dataMap.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          dataMap: dataMap.cast<String,
                              double>(), // Cast a Map<String, double>
                          colorList: pieColors,
                          animationDuration: const Duration(milliseconds: 800),
                        ),
                      ),
                    )
                  : const Text('No tiene saldo'),
              const SizedBox(height: 20),
              const Text(
                'Lista de monedas:',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dataMap.length,
                itemBuilder: (context, index) {
                  String key = dataMap.keys.elementAt(index);
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(
                            profileViewModel.iconMap[key] ??
                                ''), // Manejar posible nulo
                        radius: 30,
                      ),
                      title: Text(key,
                          style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonedaPage(
                                monedaNombre: key,
                                symbol: profileViewModel.profile.monedas[key]
                                        ?['symbol'] ??
                                    '', // Manejar posible nulo
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              Colors.greenAccent),
                        ),
                        child: const Text("Vender",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
