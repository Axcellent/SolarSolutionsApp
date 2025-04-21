import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:math';

class SolarDashboardScreen extends StatefulWidget {
  const SolarDashboardScreen({super.key});

  @override
  State<SolarDashboardScreen> createState() => _SolarDashboardScreenState();
}

class _SolarDashboardScreenState extends State<SolarDashboardScreen> {
  double currentPower = 1245.3; // Вт
  double dailyEnergy = 8.7; // кВт·ч
  double efficiency = 82.5; // %
  List<double> hourlyPower = [
    0,
    0,
    0,
    0,
    50,
    320,
    680,
    950,
    1120,
    1245,
    1180,
    1050,
    920,
    780,
    600,
    350,
    100,
    0,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Солнечная станция'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshData),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Текущая мощность (крупно)
            _buildPowerCard(),
            const SizedBox(height: 20),

            // 2. Солнечная карта (интенсивность по цветам)
            _buildSolarMap(),
            const SizedBox(height: 20),

            // 3. График выработки за день
            _buildEnergyChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Текущая мощность',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              '${currentPower.toStringAsFixed(1)} Вт',
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMetricItem(
                  'Сегодня',
                  '${dailyEnergy.toStringAsFixed(1)} кВт·ч',
                ),
                _buildMetricItem(
                  'Эффективность',
                  '${efficiency.toStringAsFixed(1)}%',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolarMap() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Интенсивность солнечного света',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.yellow, Colors.red],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_getSunIntensity().toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Обновлено: ${_getCurrentTime()}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyChart() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Выработка за сегодня',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}:00');
                        },
                        interval: 2,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()} Вт');
                        },
                        interval: 300,
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots:
                          hourlyPower.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                      isCurved: true,
                      color: Colors.amber,
                      barWidth: 4,
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.amber.withOpacity(0.2),
                      ),
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Вспомогательные методы
  double _getSunIntensity() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour <= 18) {
      return hourlyPower[hour] / hourlyPower.reduce(max) * 100;
    }
    return 0;
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
  }

  void _refreshData() {
    // Здесь будет запрос к ESP32
    setState(() {
      // Демо-обновление данных
      currentPower += 10;
      if (currentPower > 1500) currentPower = 800;
    });
  }
}
