import 'package:esp32_sensor_monitor/data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'package:intl/intl.dart';

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
    _setupAutoRefresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setupAutoRefresh() {
    final settings = Provider.of<AppSettings>(context, listen: false);
  }

  Future<void> _fetchData() async {
    final settings = Provider.of<AppSettings>(context, listen: false);

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('http://${settings.espIpAddress}/sensors'))
          .timeout(Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newData = SensorData(
          voltage: data['voltage'].toDouble(),
          temperature: data['temperature'].toDouble(),
          light: data['light'].toDouble(),
          timestamp: DateTime.now(),
        );

        setState(() {
          sensorHistory =
              sensorHistory.sublist(sensorHistory.length > 19 ? 1 : 0);
          sensorHistory.add(newData);
        });
      }
    } catch (e) {
      if (e.toString().toLowerCase().contains('failed to connect') ||
          e.toString().toLowerCase().contains('connection failed')) {
        setState(() {
          _errorMessage = 'Вы не подключены к Wi-Fi сети станции. Проверьте:'
              '\n1. Подключение к правильной Wi-Fi сети'
              '\n2. IP адрес станции в настройках'
              '\n3. Состояние станции (питание, индикаторы)';
        });
      } else if (e.toString().toLowerCase().contains('timeout') ||
          e.toString().toLowerCase().contains('future not completed')) {
        setState(() {
          _errorMessage = 'Таймаут соединения. Проверьте:'
              '\n• Доступность станции'
              '\n• Сигнал Wi-Fi'
              '\n• Правильность IP-адреса';
        });
      } else {
        setState(() {
          _errorMessage = 'Неизвестная ошибка: ${e.toString()}';
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(
      builder: (context, settings, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Мониторинг датчиков'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchData,
                tooltip: 'Обновить данные',
              ),
            ],
          ),
          body: _buildBody(settings),
        );
      },
    );
  }

  Widget _buildBody(AppSettings settings) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (sensorHistory.isEmpty) {
      return Center(
          child: Text(_isLoading
              ? 'Пожалуйста, подождите...'
              : 'Для начала нажмите на кнопку для получения данных.'));
    }

    return SingleChildScrollView(
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
        ],
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
      minY: 0.0,
      maxY: 8.0,
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
      minY: 0,
      maxY: 40,
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
      maxY: 50000,
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
            const SizedBox(height: 10),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(
                  intervalType: DateTimeIntervalType.auto,
                  labelRotation: -45,
                  dateFormat: DateFormat('dd.MM.yyyy HH:mm'),
                ),
                primaryYAxis: NumericAxis(
                  minimum: minY,
                  maximum: maxY,
                ),
                series: series,
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: title,
                  format:
                      'Дата: {point.x}\n$title: {point.y}', // Use placeholders
                  color: Theme.of(context).canvasColor,
                  textStyle: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                  canShowMarker: true,
                  builder: (dynamic data, dynamic point, dynamic series,
                      int pointIndex, int seriesIndex) {
                    final sensorData = data as SensorData;
                    return Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                          const SizedBox(height: 0),
                          Text(
                            'Дата: ${DateFormat('dd.MM.yyyy').format(sensorData.timestamp)}',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                            ),
                          ),
                          Text(
                            'Время: ${DateFormat('HH:mm:ss').format(sensorData.timestamp)}',
                          ),
                          Text(
                            'Значение: ${point.y.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
