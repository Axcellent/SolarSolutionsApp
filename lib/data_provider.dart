import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'app_settings.dart';

class DataProvider with ChangeNotifier {
  List<SensorData> _sensorHistory = [];
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _timer;

  List<SensorData> get sensorHistory => _sensorHistory;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchData(AppSettings settings) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http
          .get(Uri.parse('http://${settings.espIpAddress}/sensors'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newData = SensorData(
          current: data['current'].toDouble(),
          humidity: data['humidity'].toDouble(),
          voltage: data['voltage'].toDouble(),
          temperature: data['temperature'].toDouble(),
          light: data['light'].toDouble(),
          power: data['power'].toDouble(),
          timestamp: DateTime.now(),
        );

        // Сохраняем только последние 100 записей
        _sensorHistory = [..._sensorHistory, newData];
        if (_sensorHistory.length > 100) {
          _sensorHistory = _sensorHistory.sublist(_sensorHistory.length - 100);
        }

        // Сохраняем в SharedPreferences
        await _saveToPrefs();
        _errorMessage = '';
      } else {
        _errorMessage = 'Ошибка сервера: ${response.statusCode}';
      }
    } catch (e) {
      _handleError(e);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void setState(VoidCallback fn) {
    fn();
    notifyListeners();
  }

  void _handleError(dynamic e) {
    if (e.toString().toLowerCase().contains('failed to connect') ||
        e.toString().toLowerCase().contains('connection failed')) {
      _errorMessage = 'Вы не подключены к Wi-Fi сети станции. Проверьте:'
          '\n1. Подключение к правильной Wi-Fi сети'
          '\n2. IP адрес станции в настройках'
          '\n3. Состояние станции (питание, индикаторы)';
    } else if (e.toString().toLowerCase().contains('timeout') ||
        e.toString().toLowerCase().contains('future not completed')) {
      _errorMessage = 'Таймаут соединения. Проверьте:'
          '\n• Доступность станции'
          '\n• Сигнал Wi-Fi'
          '\n• Правильность IP-адреса';
    } else {
      _errorMessage = 'Неизвестная ошибка: ${e.toString()}';
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = _sensorHistory
        .map((data) => jsonEncode({
              'voltage': data.voltage,
              'temperature': data.temperature,
              'light': data.light,
              'power': data.power,
              'timestamp': data.timestamp.toIso8601String(),
            }))
        .toList();
    prefs.setStringList('sensorHistory', historyJson);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('sensorHistory') ?? [];
    _sensorHistory = historyJson.map((jsonString) {
      final data = jsonDecode(jsonString);
      return SensorData(
        current: data['current'].toDouble(),
        humidity: data['humidity'].toDouble(),
        voltage: data['voltage'].toDouble(),
        temperature: data['temperature'].toDouble(),
        light: data['light'].toDouble(),
        power: data['power'].toDouble(),
        timestamp: DateTime.parse(data['timestamp']),
      );
    }).toList();
    notifyListeners();
  }

  void startAutoRefresh(AppSettings settings) {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: settings.refreshInterval),
      (timer) => fetchData(settings),
    );
  }

  void stopAutoRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
