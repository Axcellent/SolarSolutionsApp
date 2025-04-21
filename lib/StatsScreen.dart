import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:math';
import 'data.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Рассчитываем статистику
    final stats = _calculateStats(sensorHistory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика датчиков'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
              'Текущие показатели',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  _buildGaugeAxis(
                    title: 'Напряжение',
                    value: stats.voltage.current,
                    min: stats.voltage.min,
                    max: stats.voltage.max,
                    ranges: [
                      GaugeRange(
                          startValue: 3.0, endValue: 3.6, color: Colors.red),
                      GaugeRange(
                          startValue: 3.6, endValue: 4.2, color: Colors.green),
                      GaugeRange(
                          startValue: 4.2, endValue: 5.0, color: Colors.red),
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
                    title: 'Температура',
                    value: stats.temperature.current,
                    min: stats.temperature.min,
                    max: stats.temperature.max,
                    ranges: [
                      GaugeRange(
                          startValue: -30, endValue: -20, color: Colors.red),
                      GaugeRange(
                          startValue: -20, endValue: 0, color: Colors.yellow),
                      GaugeRange(
                          startValue: 0, endValue: 25, color: Colors.green),
                      GaugeRange(
                          startValue: 25, endValue: 30, color: Colors.yellow),
                      GaugeRange(
                          startValue: 30, endValue: 40, color: Colors.red),
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
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
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
