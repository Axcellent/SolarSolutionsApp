// TODO: Откорректировать отображение показателя освещенности (при высоком показателе нчинает ехать вниз)
// TODO: Добавить возможность отображения на графиках показателей по минутам/часам/дням/месяцам
// TODO: Откорректировать временную ось на графиках для компактного и удобного отображения (для информации на год можно показывать только месяца)
// TODO: Добавить мобильный режим просмотра графиков с возможностью их перелистывания в одном виджете
// TODO: Возможно, добавить опцию зума графика для более детального анализа недавних показателей
// TODO: Откорректировать цветовую гамму на экране (слишком много цветов и цвета тёмные и прохладные даже в "горячей" тёмной теме)
// TODO: Откорректировать текстовые поля на экране (выравнивание, толщина, размер, я пока на глаз сделал (как и везде, впрочем))
// TODO: Откорректировать диапазоны на графиках (сейчас просто на глаз взяты, надо из инета выкрасть)

// Импорт необходимых библиотек Flutter'a
import 'package:esp32_sensor_monitor/app_settings.dart';
import 'package:flutter/material.dart'; // Виджеты и прочее
import 'package:provider/provider.dart'; // Для связиста-поисковика
import 'package:syncfusion_flutter_charts/charts.dart'; // Библиотека для создания графиков
import 'package:intl/intl.dart'; // Время и дата

// Лист иконок
const List<IconData> icons = [
  Icons.bolt,
  Icons.electric_meter,
  Icons.thermostat,
  Icons.sunny,
  Icons.water_drop,
  Icons.water_damage
];

List<String> unitsBySensors = ['В', 'А', '℃', 'Лк', '%', '', '℉'];
const List<String> namesOfSensors = [
  'Напряжение',
  'Сила тока',
  'Температура',
  'Освещенность',
  'Влажность',
  'Дождь'
];

// Лист цветов
List<Color?> colors = [
  Colors.cyan[800],
  Colors.cyan[400],
  Colors.red[700],
  Colors.yellow,
  Colors.blue[200],
  Colors.blue[700],
];

// Коды для удобного обращения
int codesVoltage = 0;
int codesCurrent = 1;
int codesTemperture = 2;
int codesLight = 3;
int codesHumidity = 4;
int codesRain = 5;

//
//
//
//
/// Экран с показателями с датчиков
/// Изменяемый
class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SensorScreenState();
}

//
//
//
//
/// Состояние экрана с показателями датчиков
/// Отвечает за изменение
class _SensorScreenState extends State<SensorScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final theme = Theme.of(context);

    return Scaffold(
        body: SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.sensors,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'Показатели',
                                      style: theme.textTheme.headlineLarge
                                          ?.copyWith(
                                              color: theme.colorScheme.primary),
                                    )),
                              ]),
                        ])))
          ]),
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                      child: _buildSensorCard(
                          codesVoltage,
                          settings.sensorHistory.last.voltage,
                          theme,
                          settings)),
                  Expanded(
                      child: _buildSensorCard(
                          codesCurrent,
                          settings.sensorHistory.last.current,
                          theme,
                          settings)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: _buildSensorCard(
                          codesTemperture,
                          settings.sensorHistory.last.temperature,
                          theme,
                          settings)),
                  Expanded(
                      child: _buildSensorCard(
                          codesHumidity,
                          settings.sensorHistory.last.humidity,
                          theme,
                          settings)),
                ],
              ),
              Row(
                children: [
                  Expanded(
                      child: _buildSensorCard(codesLight,
                          settings.sensorHistory.last.light, theme, settings)),
                  if (settings.showRainIndicator)
                    // TODO: Сделать "умную" функцию проверки на дождь
                    // Дождевой идентификатор
                    Expanded(
                        child: _buildSensorCard(
                            codesRain,
                            settings.sensorHistory.last.light < 10000 &&
                                    settings.sensorHistory.last.humidity > 88
                                ? 1
                                : 0,
                            theme,
                            settings)),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 32,
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Expanded(
                child: Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 64,
                            color: theme.colorScheme.primary,
                          ),
                          Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                    padding: const EdgeInsets.all(32),
                                    child: Text(
                                      'Графики',
                                      style: theme.textTheme.headlineLarge
                                          ?.copyWith(
                                              color: theme.colorScheme.primary),
                                    )),
                              ]),
                        ])))
          ]),
          _buildPowerChart(settings),
          _buildVoltageChart(settings),
          _buildCurrentChart(settings),
          if (settings.showTempChart) _buildTemperatureChart(settings),
          if (settings.showHumidityChart) _buildLightChart(settings),
          if (settings.showHumidityChart) _buildHumidityChart(settings),
          _buildRainChart(settings),
        ],
      ),
    ));
  }

  //
  // Функция для построения карточки текущих данных каждого сенсора
  Widget _buildSensorCard(
      int codeOfSensor, double value, ThemeData theme, AppSettings settings) {
    if (!settings.useCelsius) value = value * 9 / 5 + 32;
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
              // Установление выравнивания по центру для вторичной оси (в данном случае - по горизонтали)
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  icons[codeOfSensor],
                  size: 48,
                  color: colors[codeOfSensor],
                ),
                Text(
                  '${codeOfSensor == codesRain ? (value == 1 ? "Да" : 'Нет') : (codeOfSensor == codesLight ? value.toStringAsFixed(0) : value.toStringAsFixed(1))} ${codeOfSensor == codesTemperture && !settings.useCelsius ? unitsBySensors.last : unitsBySensors[codeOfSensor]}',
                  style: theme.textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors[codeOfSensor],
                  ),
                ),
                Text(
                  namesOfSensors[codeOfSensor],
                  style: const TextStyle().copyWith(color: Colors.grey),
                ),
              ]),
        ));
  }

  //
  // Функция для построения карточки каждого графика
  Widget _buildChart(
    // Настройки, откуда будем брать сохраненные данные
    AppSettings settings,
    // Название текущего графика
    String title,
    // Массив массивов точек для формирования графиков (графиков может быть много)
    List<LineSeries<SensorData, DateTime>> series,
    // Минимум по оси ординат
    double minY,
    // Максимум по оси ординат
    double maxY,
  ) {
    return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () =>
                    _showDialog(context, 'Выберите временной промежуток'),
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              SfCartesianChart(
                // Передача серий точек
                series: series,
                // Включения анимации при прорисовке
                //enableAxisAnimation: true,
                tooltipBehavior: TooltipBehavior(
                  header: title,
                  enable: true,
                  format:
                      'Дата: point.x\n$title: point.y', // Формат всплывающей подсказки
                ),
                // Кастомизация оси абцисс: временная ось
                primaryXAxis: DateTimeAxis(
                  intervalType: groupv == 'day'
                      ? DateTimeIntervalType.days
                      : DateTimeIntervalType.minutes,
                  // Установка поворота для всех надписей
                  labelRotation: -45,
                  // В каком формате будут выводится дата и время
                  dateFormat: groupv == 'day'
                      ? DateFormat('dd.MM.yyyy')
                      : DateFormat('hh.mm'),
                ),
                // Кастомизация оси ординат: числовая ось
                primaryYAxis: NumericAxis(
                  // Максимальное количество надписей на оси ординат
                  maximumLabels: 10,
                  // Установка минимума и максимума
                  minimum: minY,
                  maximum: maxY,
                ),
              ),
            ],
          ),
        ));
  }

  //
  // Функция для построения графика освещенности
  Widget _buildLightChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Освещенность',
        // Передаем все графики
        [
          // На деле график только один
          // Настройка отображения конкретного графика, формируемого settings.sensorHistory (в данном случае)
          LineSeries<SensorData, DateTime>(
            // Источник точек
            dataSource: settings.sensorHistory,
            // Передача функции xValueMapper лямбда-функции, переводящей каждую пару элементов (точку) в конкретную часть элемента (отображает одну координату: x)
            xValueMapper: (data, _) => data.timestamp,
            // Передача функции yValueMapper лямбда-функции, переводящей каждую пару элементов (точку) в конкретную часть элемента (отображает одну координату: y)
            yValueMapper: (data, _) => data.light,
            // Установка цвета линии графика
            color: Colors.amber,
            // Установка толщины линии графика
            width: 3,
            // Маркеры должны быть видимы всегда
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        200000);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildHumidityChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Влажность',
        [
          LineSeries<SensorData, DateTime>(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) => data.humidity,
            color: Colors.lightBlue,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        100);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildTemperatureChart(
    AppSettings settings,
  ) {
    return _buildChart(
        settings,
        'Температура',
        [
          LineSeries(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) => data.temperature,
            color: Colors.red,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        -60,
        60);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildPowerChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Мощность',
        [
          LineSeries(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) => data.power,
            color: Colors.purple,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        60);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildCurrentChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Сила тока',
        [
          LineSeries(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) => data.current,
            color: Colors.cyan,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        2);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildVoltageChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Напряжение',
        [
          LineSeries(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) => data.voltage,
            color: Colors.indigo,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        10);
  }

  //
  // Функция для построения графика освещенности
  Widget _buildRainChart(AppSettings settings) {
    return _buildChart(
        settings,
        'Дождь',
        [
          LineSeries(
            dataSource: settings.sensorHistory,
            xValueMapper: (data, _) => data.timestamp,
            yValueMapper: (data, _) =>
                data.light < 10000 && data.humidity > 88 ? 1 : 0,
            color: Colors.blue,
            width: 3,
            markerSettings: const MarkerSettings(isVisible: true),
          )
        ],
        0,
        1);
  }

  String groupv = 'minutes';

  //
  // Функция для вывода диалога с пользователем о временном промежутке на графиках
  void _showDialog(BuildContext context, String value) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(value),
                    RadioListTile(
                        title: const Text('День'),
                        value: 'day',
                        groupValue: groupv,
                        onChanged: (value) => {
                              groupv = value as String,
                              setState(() => {}),
                              Navigator.pop(context)
                            }),
                    RadioListTile(
                        title: const Text('Минуты'),
                        value: 'minutes',
                        groupValue: groupv,
                        onChanged: (value) => {
                              groupv = value as String,
                              setState(() => {}),
                              Navigator.pop(context)
                            })
                  ],
                ),
              ),
            ));
  }
}
