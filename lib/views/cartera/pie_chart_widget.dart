import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

class PieChartWidget extends StatelessWidget {
  final Future<Map<String, double>> dataMapFuture;

  const PieChartWidget({super.key, required this.dataMapFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, double>>(
      future: dataMapFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        final dataMap = snapshot.data!;
        return Row(
          children: [
            Expanded(
              child: PieChart(
                dataMap: dataMap,
                animationDuration: const Duration(milliseconds: 800),
                chartLegendSpacing: 32,
                chartRadius: MediaQuery.of(context).size.width / 3.2,
                colorList: const [
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.yellow,
                ],
                initialAngleInDegree: 0,
                chartType: ChartType.disc,
                ringStrokeWidth: 32,
                legendOptions: const LegendOptions(
                  showLegendsInRow: false,
                  showLegends: false, // Disable default legends
                ),
                chartValuesOptions: const ChartValuesOptions(
                  showChartValueBackground: true,
                  showChartValues: true,
                  showChartValuesInPercentage: true,
                  showChartValuesOutside: false,
                  decimalPlaces: 2,
                  chartValueStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildLegendTable(dataMap),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendTable(Map<String, double> dataMap) {
    final total = dataMap.values.reduce((a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1),
          2: FlexColumnWidth(1),
        },
        border: TableBorder.all(color: Colors.black, width: 1),
        children: [
          const TableRow(
            children: [
              TableCell(
                child: Center(
                  child: Text(
                    'Nombre',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Text(
                    'Valor',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              TableCell(
                child: Center(
                  child: Text(
                    'Porcentaje',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          ...dataMap.entries.map((entry) {
            final percentage = (entry.value / total * 100).toStringAsFixed(2);
            return TableRow(
              children: [
                TableCell(child: Center(child: Text(entry.key))),
                TableCell(
                  child: Center(child: Text(entry.value.toStringAsFixed(2))),
                ),
                TableCell(
                  child: Center(child: Text('$percentage%')),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
