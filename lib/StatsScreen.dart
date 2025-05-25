import 'package:esp32_sensor_monitor/data.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:math';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    print(sensorHistory.length);
    if (sensorHistory.isEmpty) {
      return Scaffold(
          appBar: AppBar(
            title: const Text('Статистика датчиков'),
            centerTitle: false,
          ),
          body: Center(
              child: Text('Для начала нажмите на кнопку получения данных.')));
    }

    final stats = _calculateStats(sensorHistory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика датчиков'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildAdviceCard(stats),
            const SizedBox(height: 20),
            _buildSummaryCard(stats),
            const SizedBox(height: 20),
            _buildGaugeSection(stats),
            const SizedBox(height: 20),
            _buildDetailedStats(stats),
          ],
        ),
      ),
    );
  }

  Widget _buildAdviceCard(SensorStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              _getAnalys(stats),
              style: TextStyle(
                  color: stats.voltage.deviation > 3
                      ? Colors.red
                      : Colors.primaries.first,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }

  String _getAnalys(SensorStats stats) {
    String res = '';
    if (stats.voltage.deviation > 3.5) {
      res += 'Внимание! Скачки напряжения!\n';
      if (stats.voltage.average < 2) {
        res += 'Внимание! Неисправность станции!\n';
      }
    }
    if (stats.voltage.current < 2) {
      res += 'Низкое напряжение.\n';
    } else if (stats.voltage.current > 6) {
      res += 'Высокое напряжение.\n';
    }

    if (stats.temperature.deviation > 10) {
      res += 'Внимание! Серьёзные климатические изменения!\n';
    }
    if (stats.temperature.current < -20) {
      res += 'Низкая температура.\n';
    } else if (stats.temperature.current > 30) {
      res += 'Высокая температура.\n';
    }

    if (stats.light.current < 1000 && stats.light.deviation > 5000) {
      res += 'Внимание! Потерян доступ к свету!\n';
    }
    if (stats.light.current < 100) {
      res += 'Плохая освещенность.\n';
    }

    return res;
  }

  Widget _buildSummaryCard(SensorStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Общая статистика',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Период',
                    '${stats.periodStart.hour}:${stats.periodStart.minute} - '
                        '${stats.periodEnd.hour}:${stats.periodEnd.minute}'),
                _buildStatItem('Записей', stats.totalReadings.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGaugeSection(SensorStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Текущие значения на шкалах',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  _buildGaugeAxis(
                    title: 'В',
                    value: stats.voltage.current,
                    min: 0,
                    max: 8,
                    ranges: [
                      GaugeRange(
                          startValue: 0.0, endValue: 1.5, color: Colors.red),
                      GaugeRange(
                          startValue: 1.5, endValue: 2.5, color: Colors.yellow),
                      GaugeRange(
                          startValue: 2.5, endValue: 5.5, color: Colors.green),
                      GaugeRange(
                          startValue: 5.5, endValue: 6.5, color: Colors.yellow),
                      GaugeRange(
                          startValue: 6.5, endValue: 8.0, color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  _buildGaugeAxis(
                    title: '°C',
                    value: stats.temperature.current,
                    min: -40,
                    max: 40,
                    ranges: [
                      GaugeRange(
                          startValue: -40, endValue: -30, color: Colors.red),
                      GaugeRange(
                          startValue: -30, endValue: -20, color: Colors.yellow),
                      GaugeRange(
                          startValue: -20, endValue: 25, color: Colors.green),
                      GaugeRange(
                          startValue: 25, endValue: 30, color: Colors.yellow),
                      GaugeRange(
                          startValue: 30, endValue: 40, color: Colors.red),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  _buildGaugeAxis(
                    title: 'Лк',
                    value: stats.light.current,
                    min: 0,
                    max: 50000,
                    ranges: [
                      GaugeRange(
                          startValue: 0, endValue: 1000, color: Colors.red),
                      GaugeRange(
                          startValue: 1000,
                          endValue: 10000,
                          color: Colors.yellow),
                      GaugeRange(
                          startValue: 10000,
                          endValue: 50000,
                          color: Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  RadialAxis _buildGaugeAxis({
    required String title,
    required double value,
    required double min,
    required double max,
    required List<GaugeRange> ranges,
  }) {
    return RadialAxis(
      minimum: min,
      maximum: max,
      ranges: ranges,
      pointers: <GaugePointer>[
        NeedlePointer(
          value: value,
          enableAnimation: true,
        ),
      ],
      annotations: <GaugeAnnotation>[
        GaugeAnnotation(
          widget: Text(
            '$title\n${value.toStringAsFixed(2)}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          angle: 90,
          positionFactor: 0.5,
        ),
      ],
    );
  }

  Widget _buildDetailedStats(SensorStats stats) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Детальная статистика',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            _buildSensorStatsTable('Напряжение', stats.voltage, 'В'),
            const Divider(height: 30),
            _buildSensorStatsTable('Температура', stats.temperature, '°C'),
            const Divider(height: 30),
            _buildSensorStatsTable('Освещенность', stats.light, 'лк'),
          ],
        ),
      ),
    );
  }

  Widget _buildSensorStatsTable(String name, SensorStat stat, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
          },
          children: [
            _buildTableRow(
                'Текущее', '${stat.current.toStringAsFixed(2)} $unit'),
            _buildTableRow(
                'Среднее', '${stat.average.toStringAsFixed(2)} $unit'),
            _buildTableRow('Минимум', '${stat.min.toStringAsFixed(2)} $unit'),
            _buildTableRow('Максимум', '${stat.max.toStringAsFixed(2)} $unit'),
            _buildTableRow(
                'Отклонение', '±${stat.deviation.toStringAsFixed(2)} $unit'),
          ],
        ),
      ],
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  SensorStats _calculateStats(List<SensorData> data) {
    if (data.isEmpty) return SensorStats.empty();

    final voltageValues = data.map((d) => d.voltage).toList();
    final tempValues = data.map((d) => d.temperature).toList();
    final lightValues = data.map((d) => d.light).toList();

    return SensorStats(
      periodStart: data.first.timestamp,
      periodEnd: data.last.timestamp,
      totalReadings: data.length,
      voltage: _calculateSensorStat(voltageValues, data.last.voltage),
      temperature: _calculateSensorStat(tempValues, data.last.temperature),
      light: _calculateSensorStat(lightValues, data.last.light),
    );
  }

  SensorStat _calculateSensorStat(List<double> values, double current) {
    final avg = values.reduce((a, b) => a + b) / values.length;
    final variance =
        values.map((x) => pow(x - avg, 2)).reduce((a, b) => a + b) /
            values.length;
    final deviation = sqrt(variance);

    return SensorStat(
      current: current,
      average: avg,
      min: values.reduce(min),
      max: values.reduce(max),
      deviation: deviation,
    );
  }
}

class SensorStats {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int totalReadings;
  final SensorStat voltage;
  final SensorStat temperature;
  final SensorStat light;

  SensorStats({
    required this.periodStart,
    required this.periodEnd,
    required this.totalReadings,
    required this.voltage,
    required this.temperature,
    required this.light,
  });

  factory SensorStats.empty() => SensorStats(
        periodStart: DateTime.now(),
        periodEnd: DateTime.now(),
        totalReadings: 0,
        voltage: SensorStat.empty(),
        temperature: SensorStat.empty(),
        light: SensorStat.empty(),
      );
}

class SensorStat {
  final double current;
  final double average;
  final double min;
  final double max;
  final double deviation;

  SensorStat({
    required this.current,
    required this.average,
    required this.min,
    required this.max,
    required this.deviation,
  });

  factory SensorStat.empty() => SensorStat(
        current: 0,
        average: 0,
        min: 0,
        max: 0,
        deviation: 0,
      );
}
