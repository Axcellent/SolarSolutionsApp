import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'data.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final mockData = List.generate(20, (index) {
      final time = now.subtract(Duration(seconds: 20 - index));
      return SensorData(
        voltage: 3.5 + (index % 3) * 0.2,
        temperature: 22.0 + (index % 5),
        light: 100 + (index % 7) * 50,
        timestamp: time,
      );
    });

    setState(() {
      sensorHistory = mockData;
    });
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    await Future.delayed(const Duration(seconds: 1));

    final newData = SensorData(
      voltage: 3.5 + (DateTime.now().second % 10) * 0.1,
      temperature: 22.0 + (DateTime.now().second % 5),
      light: 100 + (DateTime.now().second % 10) * 30,
      timestamp: DateTime.now(),
    );

    setState(() {
      sensorHistory = [...sensorHistory.take(19), newData];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мониторинг датчиков (Демо)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Обновить данные',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildCurrentValues(),
                  const SizedBox(height: 24),
                  _buildVoltageChart(),
                  const SizedBox(height: 24),
                  _buildTemperatureChart(),
                  const SizedBox(height: 24),
                  _buildLightChart(),
                  const SizedBox(height: 16),
                  const Text(
                    'Демонстрационный режим: используются тестовые данные',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCurrentValues() {
    if (sensorHistory.isEmpty) return const SizedBox();

    final latest = sensorHistory.last;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildValueRow('Напряжение',
                '${latest.voltage.toStringAsFixed(2)} В', Icons.bolt),
            const Divider(),
            _buildValueRow(
                'Температура',
                '${latest.temperature.toStringAsFixed(1)} °C',
                Icons.thermostat),
            const Divider(),
            _buildValueRow('Освещенность',
                '${latest.light.toStringAsFixed(0)} лк', Icons.lightbulb),
          ],
        ),
      ),
    );
  }

  Widget _buildValueRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  // Widget _buildVoltageChart() {
  //   return _buildChart(
  //     title: 'Напряжение (В)',
  //     series: [
  //       LineSeries<SensorData, DateTime>(
  //         dataSource: globals.sensorHistory,
  //         xValueMapper: (data, _) => data.timestamp,
  //         yValueMapper: (data, _) => data.voltage,
  //         color: Colors.blue,
  //         width: 3,
  //         markerSettings: const MarkerSettings(isVisible: true),
  //       ),
  //     ],
  //     minY: 3.0,
  //     maxY: 4.5,
  //   );
  // }
  Widget _buildVoltageChart() {
    return _buildChart(
      title: 'Напряжение (В)',
      series: [
        LineSeries<SensorData, DateTime>(
          dataSource: sensorHistory,
          xValueMapper: (data, _) => data.timestamp,
          yValueMapper: (data, _) => data.voltage,
          color: Colors.blue,
          width: 3,
          markerSettings: const MarkerSettings(
              shape: DataMarkerType.diamond, isVisible: true),
        ),
      ],
      minY: 3.0,
      maxY: 4.5,
    );
  }

  Widget _buildTemperatureChart() {
    return _buildChart(
      title: 'Температура (°C)',
      series: [
        LineSeries<SensorData, DateTime>(
          dataSource: sensorHistory,
          xValueMapper: (data, _) => data.timestamp,
          yValueMapper: (data, _) => data.temperature,
          color: Colors.red,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
      minY: 20,
      maxY: 30,
    );
  }

  Widget _buildLightChart() {
    return _buildChart(
      title: 'Освещенность (лк)',
      series: [
        LineSeries<SensorData, DateTime>(
          dataSource: sensorHistory,
          xValueMapper: (data, _) => data.timestamp,
          yValueMapper: (data, _) => data.light,
          color: Colors.amber,
          width: 3,
          markerSettings: const MarkerSettings(isVisible: true),
        ),
      ],
      minY: 0,
      maxY: 500,
    );
  }

  Widget _buildChart({
    required String title,
    required List<LineSeries<SensorData, DateTime>> series,
    required double minY,
    required double maxY,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.seconds,
                  labelRotation: -45,
                ),
                primaryYAxis: NumericAxis(
                  minimum: minY,
                  maximum: maxY,
                ),
                series: series,
                tooltipBehavior: TooltipBehavior(
                  header: title,
                  enable: true,
                  color: Theme.of(context).canvasColor,
                  textStyle: TextStyle(
                      color: Theme.of(context).textTheme.titleMedium?.color),
                  format: ("Дата: point.x\n" + title + ": point.y"),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
