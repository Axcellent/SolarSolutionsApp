// TODO: Вынести сюда списки пороговых значений?
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math'; // Импорт библиоетки для математических функций (например, Random))
import 'dart:async'; // Импорт библиотеки для асинхронных функций (например у нас есть _timerTick)
import 'dart:convert'; // Импорт библиотеки с функцией декодирования из JSON
import 'package:http/http.dart' as http; // Импорт библиотеки с HTTP запросами

bool _debugIsOnline = false;

//
//
//
/// Класс формата данных
/// Предоставляет основной класс формата передачи и хранения данных со станции
class SensorData {
  final double power;
  final double current;
  final double voltage;
  final double temperature;
  final double humidity;
  final double light;

  final DateTime timestamp;

  //
  // Определение оператора сложения объектов классов текущего типа
  SensorData operator +(SensorData other) {
    return SensorData(
      power: power + other.power,
      current: current + other.current,
      voltage: voltage + other.voltage,
      temperature: temperature + other.temperature,
      humidity: humidity + other.humidity,
      light: light + other.light,
      timestamp: timestamp,
    );
  }

  //
  // Конструктор класса, обязывающий передать все параметры (благодаря required) в удобном формате (благодаря {})
  SensorData({
    required this.current,
    required this.voltage,
    required this.temperature,
    required this.light,
    required this.humidity,
    required this.power,
    required this.timestamp,
  });
}

class AppSettings with ChangeNotifier {
  // Список недавних показателей станции
  // Хранятся принятые со станции значения (максимум 36)
  List<SensorData> sensorHistory = [
    SensorData(
        current: 1.1,
        humidity: 78,
        temperature: 26.9,
        voltage: 4.7,
        light: 8561,
        power: 9.4,
        timestamp: DateTime(2017, 9, 1, 0, 30)),
    SensorData(
        current: 1.2,
        humidity: 74,
        temperature: 28.2,
        voltage: 5.7,
        light: 17893,
        power: 10.4,
        timestamp: DateTime(2017, 9, 2, 0, 30)),
    SensorData(
        current: 1.0,
        humidity: 70,
        temperature: 28.2,
        voltage: 5.7,
        light: 17893,
        power: 10.4,
        timestamp: DateTime(2017, 9, 2, 1, 40)),
    SensorData(
        current: 1.5,
        humidity: 79,
        temperature: 28.4,
        voltage: 4.7,
        light: 182352,
        power: 154.2,
        timestamp: DateTime(2017, 9, 2, 2, 30)),
    SensorData(
        current: 1.0,
        humidity: 78,
        temperature: 28.5,
        voltage: 12.1,
        light: 12276,
        power: 10.4,
        timestamp: DateTime(2017, 9, 2, 3, 30)),
    SensorData(
        current: 0.1,
        humidity: 97,
        temperature: -19.3,
        voltage: 0.0,
        light: 0.0,
        power: 4.1,
        timestamp: DateTime(2017, 9, 2, 5, 30)),
  ];

  // TODO: Откорректировать списки показателей (нужна логика для создания записей по месяцам, годам и тд)

  // Список показателей за час
  // Хранятся средние значения (максимум 30)
  List<SensorData> sensorHistoryHour = [
    SensorData(
        current: 1.1,
        humidity: 78,
        temperature: 26.9,
        voltage: 4.7,
        light: 8561,
        power: 9.4,
        timestamp: DateTime(2017, 9, 1, 5, 25)),
    SensorData(
        current: 0.1,
        humidity: 97,
        temperature: -19.3,
        voltage: 0.0,
        light: 0.0,
        power: 4.1,
        timestamp: DateTime(2017, 9, 2, 5, 30)),
  ];

  // Список показателей за день
  // Хранятся средние значения (максимум 24)
  List<SensorData> sensorHistoryDay = [
    SensorData(
        current: 1.1,
        humidity: 78,
        temperature: 26.9,
        voltage: 4.7,
        light: 8561,
        power: 9.4,
        timestamp: DateTime(2017, 9, 1, 5)),
    SensorData(
        current: 1.1,
        humidity: 78,
        temperature: 26.9,
        voltage: 4.7,
        light: 8561,
        power: 9.4,
        timestamp: DateTime(2017, 9, 1, 5)),
    SensorData(
        current: 0.1,
        humidity: 97,
        temperature: -19.3,
        voltage: 0.0,
        light: 0.0,
        power: 4.1,
        timestamp: DateTime(2017, 9, 2, 6)),
  ];

  // Список показателей за месяц
  // Хранятся средние значения (максимум 31)
  List<SensorData> sensorHistoryMonth = [
    SensorData(
        current: 1.1,
        humidity: 78,
        temperature: 26.9,
        voltage: 4.7,
        light: 8561,
        power: 9.4,
        timestamp: DateTime(2017, 9, 1)),
    SensorData(
        current: 0.1,
        humidity: 97,
        temperature: -19.3,
        voltage: 0.0,
        light: 0.0,
        power: 4.1,
        timestamp: DateTime(2017, 9, 2)),
  ];

  // Список показателей за год
  // Хранятся средние значения (максимум 12)
  List<SensorData> sensorHistoryYear = [
    SensorData(
        current: 0.1,
        humidity: 97,
        temperature: -19.3,
        voltage: 0.0,
        light: 0.0,
        power: 4.1,
        timestamp: DateTime(2017, 9)),
  ];

  // Списки для кВт*ч
  List<double> totalProduction = [12.6, 17.9, 352.1];
  List<double> avrgProduction = [3.5, 4.1, 4.2];
  List<double> co2Savings = [1.0, 24.2, 178.6];

  // Все настройки приложения
  bool _isDarkMode = false;
  int _refreshInterval = 3;
  String _espIpAddress = '192.168.1.100';
  double _textScaleFactor = 1.0;
  bool _showSavings = true;
  bool _showCO2Reduction = true;
  double _costPerKWh = 0.15;
  bool _showLightChart = true;
  bool _showTempChart = true;
  bool _showHumidityChart = true;
  bool _showRainIndicator = true;
  bool _useCelsius = true;
  String _alertLevel = 'warning'; // 'danger', 'warning', 'info'
  bool _showTroubleshootingTips = true;
  bool _showHumidityStats = true;
  bool _manualControl = true;
  double _horizontalRotation = 0.0;
  double _verticalRotation = 0.0;
  bool _isOtherEnabled = true;
  String _powerTimeRange = 'day'; // 'day', 'month', 'year'
  String _productionTimeRange = 'day';
  String _co2TimeRange = 'day';
  String _savingsTimeRange = 'day';

  // Геттеры параметров
  bool get isDarkMode => _isDarkMode;
  int get refreshInterval => _refreshInterval;
  String get espIpAddress => _espIpAddress;
  double get textScaleFactor => _textScaleFactor;
  bool get showSavings => _showSavings;
  bool get showCO2Reduction => _showCO2Reduction;
  double get costPerKWh => _costPerKWh;
  bool get showLightChart => _showLightChart;
  bool get showTempChart => _showTempChart;
  bool get showHumidityChart => _showHumidityChart;
  bool get showRainIndicator => _showRainIndicator;
  bool get useCelsius => _useCelsius;
  String get alertLevel => _alertLevel;
  bool get showTroubleshootingTips => _showTroubleshootingTips;
  bool get showHumidityStats => _showHumidityStats;
  bool get manualControl => _manualControl;
  double get horizontalRotation => _horizontalRotation;
  double get verticalRotation => _verticalRotation;
  bool get isOtherEnabled => _isOtherEnabled;
  String get powerTimeRange => _powerTimeRange;
  String get productionTimeRange => _productionTimeRange;
  String get co2TimeRange => _co2TimeRange;
  String get savingsTimeRange => _savingsTimeRange;

  // Флаг определения дождя для последней записи (в его пользе сомневаюсь)
  bool _isRaining = true;

  bool get isRaining => _isRaining;

  // Сеттеры временных параметров экранов
  void setIsRaining(bool value) {
    // Устанавливаем новое значение
    _isRaining = value;
    // Уведомляем все зависящие виджеты (перерисовываем их)
    notifyListeners();
  }

  void setPowerTimeRange(String value) {
    _powerTimeRange = value;
    notifyListeners();
  }

  void setProductionTimeRange(String value) {
    _productionTimeRange = value;
    notifyListeners();
  }

  void setCo2TimeRange(String value) {
    _co2TimeRange = value;
    notifyListeners();
  }

  void setSavingsTimeRange(String value) {
    _savingsTimeRange = value;
    notifyListeners();
  }

  // TODO: Возможно, ускорить сохранение и загрузку данных из настроек
  // Сохранения параметров по значениям ключа и данных (асинхронное)
  Future<void> _saveToPrefs(String key, var value) async {
    // Получаем экземпляр общих настреок приложения
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // Сохраняем в нем значение по переданному ключу (строковый формат для универсальности)
    await prefs.setString(key, value.toString());
  }

  // "Сеттеры" общих параметров приложения
  // Методы сохранения
  Future<void> toggleDarkMode(bool value) async {
    // Изменяем значение
    _isDarkMode = value;
    // Вызываем асинхронный запрос на сохранение нового значения параметра
    await _saveToPrefs('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setTextScaleFactor(double value) async {
    _textScaleFactor = value;
    await _saveToPrefs('textScaleFactor', value);
    notifyListeners();
  }

  Future<void> setShowSavings(bool value) async {
    _showSavings = value;
    await _saveToPrefs('showSavings', value);
    notifyListeners();
  }

  Future<void> setShowCO2Reduction(bool value) async {
    _showCO2Reduction = value;
    await _saveToPrefs('showCO2Reduction', value);
    notifyListeners();
  }

  Future<void> setCostPerKWh(double value) async {
    _costPerKWh = value;
    await _saveToPrefs('costPerKWh', value);
    notifyListeners();
  }

  Future<void> setShowLightChart(bool value) async {
    _showLightChart = value;
    await _saveToPrefs('showLightChart', value);
    notifyListeners();
  }

  Future<void> setShowTempChart(bool value) async {
    _showTempChart = value;
    await _saveToPrefs('showTempChart', value);
    notifyListeners();
  }

  Future<void> setShowHumidityChart(bool value) async {
    _showHumidityChart = value;
    await _saveToPrefs('showHumidityChart', value);
    notifyListeners();
  }

  Future<void> setShowRainIndicator(bool value) async {
    _showRainIndicator = value;
    await _saveToPrefs('showRainIndicator', value);
    notifyListeners();
  }

  Future<void> setUseCelsius(bool value) async {
    _useCelsius = value;
    await _saveToPrefs('useCelsius', value);
    notifyListeners();
  }

  Future<void> setAlertLevel(String value) async {
    _alertLevel = value;
    await _saveToPrefs('alertLevel', value);
    notifyListeners();
  }

  Future<void> setShowTroubleshootingTips(bool value) async {
    _showTroubleshootingTips = value;
    await _saveToPrefs('showTroubleshootingTips', value);
    notifyListeners();
  }

  Future<void> setShowHumidityStats(bool value) async {
    _showHumidityStats = value;
    await _saveToPrefs('showHumidityStats', value);
    notifyListeners();
  }

  Future<void> setManualControl(bool value) async {
    _manualControl = value;
    await _saveToPrefs('manualControl', value);
    notifyListeners();
  }

  Future<void> setHorizontalRotation(double value) async {
    _horizontalRotation = value;
    await _saveToPrefs('horizontalRotation', value);
    notifyListeners();
  }

  Future<void> setVerticalRotation(double value) async {
    _verticalRotation = value;
    await _saveToPrefs('verticalRotation', value);
    notifyListeners();
  }

  Future<void> setEspIpAddress(String value) async {
    _espIpAddress = value;
    await _saveToPrefs('espIpAddress', value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int value) async {
    _refreshInterval = value;
    await _saveToPrefs('refreshInterval', value);
    notifyListeners();
  }

  Future<void> setIsOtherEnabled(bool value) async {
    _isOtherEnabled = value;
    await _saveToPrefs('isOtherEnabled', value);
    notifyListeners();
  }

  // TODO: Откорректировать загрузку настроек (чтобы все грузились)
  Future<void> loadSettings() async {
    // Получаем экземпляр класса Общих настроек (хранятся на устройстве в виде записей "ключ: значение")
    final prefs = await SharedPreferences.getInstance();

    // Получаем строковое значение для параметра настроек isDarkMode и конвертируем в логическое
    // С остальными аналогичным образом
    _isDarkMode = ((prefs.getString('isDarkMode') ?? "false") == "true");
    _refreshInterval = prefs.getInt('refreshInterval') ?? 5;
    _espIpAddress = prefs.getString('espIpAddress') ?? '192.168.1.100';
    _textScaleFactor =
        double.parse(prefs.getString('textScaleFactor') ?? "1.0");
    _showSavings = ((prefs.getString('showSavings') ?? "false") == "true");
  }

  // Объект-таймер, позволяет асинхронно выполнять операции с периодичностью
  Timer? timer;
  // Логическое значение текущей загрузки данных с esp32
  final bool _isLoading = false;
  // Сообщение об ошибке в цикле получения данных с esp, должно где-нибудь отображаться
  // TODO: Подключить показ _errorMessage на экранах (например, проверять переменную: если не пуста - рендерить только текст ошибки в центре)
  String errorMessage = '';

  //
  // Функция работы таймера
  void runTimer() {
    // Выключаем прошлый таймер (если был)
    timer?.cancel();
    // Создаем новый
    timer = Timer.periodic(
      // Периодичность
      Duration(seconds: _refreshInterval),
      // Какая функция будет выполняться
      (value) => _timerTick(),
    );
  }

  //
  // Функция остановки таймера
  void stopTimer() {
    // Выключаем
    timer?.cancel();
    // Ссылку удаляем
    timer = null;
  }

  Future<void> _timerTick() async {
    // Проверка на наличие загрузки может пригодится, но вряд ли
    if (_isLoading) return;

    if (_debugIsOnline) {
      try {
        // Выполнение GET-запроса по заданному http-адресу с максимальным ожиданием в 3 секунды
        late http.Response response;
        try {
          response = await http
              .get(Uri.parse('http://$espIpAddress:80/sensors'))
              .timeout(const Duration(seconds: 3));
        } catch (exception) {
          errorMessage = exception.toString();
        }

        // Если запрос выполнен успешно и пришел ответ
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          final newData = SensorData(
            // TODO: Принимать с ESP32 время (тяжелая задача)
            timestamp: DateTime.now(),
            power: data['power'].toDouble(),
            voltage: data['voltage'].toDouble(),
            current: data['current'].toDouble(),
            temperature: data['temperature'].toDouble(),
            humidity: data['humidity'].toDouble(),
            light: data['light'].toDouble(),
          );

          // Создаем новый список из элементов старого (оператор расширения списка до элементов "...") и newData
          sensorHistory = [...sensorHistory, newData];
          // Если элементов много - надо уменьшить их число
          if (sensorHistory.length > 10) {
            // Берем подсписок с началом с элемента "sensorHistory.length - 10"
            sensorHistory = sensorHistory.sublist(sensorHistory.length - 10);
          }

          // Оповещаем слушателей
          notifyListeners();
        }
      }
      // Иначе возникло исключение, которое надо показать пользователю
      catch (exception) {
        if (exception.toString().contains('connection failed')) {
          // Нужны рекомендации по исправлению проблемы
          errorMessage = "Проверьте подключение";
        }
      } finally {}
    } else {
      final r = Random();

      final newData = SensorData(
        // TODO: Принимать с ESP32 время (тяжелая задача)
        timestamp: DateTime.now(),
        power: r.nextDouble(),
        voltage: r.nextDouble(),
        current: r.nextDouble(),
        temperature: r.nextDouble() * 30,
        humidity: r.nextDouble() * 100,
        light: r.nextDouble() * 100000,
      );

      sensorHistory = [...sensorHistory, newData];
      if (sensorHistory.length > 10) {
        sensorHistory = sensorHistory.sublist(sensorHistory.length - 10);
      }
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // При выхода объекта из зоны управления таймер должен также закрыться
    timer?.cancel();
    super.dispose();
  }
}
