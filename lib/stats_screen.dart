// TODO: Откорректировать цветовую гамму на экране (особенно вверху)
// TODO: Откорректировать отображение надписей на экране (шкалы, верхние плашки)
// TODO: Откорректировать отображение "легенд" под каждой шкалой (под разными шкалами сейчас переносятся по-разному)
// TODO: Откорректировать три верхние плашки для ПК (центральное расположение побито, эффективность поехала)
// TODO: Откорректировать три верхние плашки для мобильных устройств (выравнивание слева лучше)
// TODO: Важно! Откорректировать отображение нижней таблицы для мобильных устройств (текст располагается в колонку и нечитабелен)
// TODO: Добавить кнопку создания новой статистики

// Импорт необходимых библиотек Flutter'a
import 'package:flutter/material.dart'; // Виджеты и прочее
import 'package:provider/provider.dart';

// Импорт библиотеки для математики
import 'app_settings.dart';

// Информация о станции
String problemsInfo = 'Все показатели в норме.';
String adviseInfo = 'Ничего исправлять не нужно.';

// Список всех возможных иконок для плашки с информацией
List<IconData> icons = [
  Icons.dangerous,
  Icons.warning,
  Icons.check_circle,
  Icons.info,
];

// Список всех возможных цветов для плашки с информацией
List<Color> colors = [
  Colors.red,
  Colors.amber,
  Colors.green,
  Colors.blue,
];

// Лист для хранения пороговых значений
// Формат: [i][j][k]
// i - Код показателя, по которому нужны границы
// j - Выбор верхней или нижней границы
// k - Выбор характера конкретной границы (опасность или предупреждение)
const List<List<List<double>>> statusManagerData = [
  [
    [-15, -10],
    [35, 30]
  ],
  [
    [1.0, 2.0],
    [8.0, 6.0]
  ],
  [
    [500, 1000],
    [100000, 50000]
  ],
  [
    [10, 30],
    [80, 70]
  ],
  [
    [0, -20],
    [0, 20]
  ],
];

//
//
//
//
///
/// Класс с пороговыми значениями
class GaugeManager {
  static const double dangerTemperatureMinValue = -50;
  static const double dangerHumidityMinValue = 0;
  static const double dangerVoltageMinValue = 0;
  static const double dangerCurrentMinValue = 0;
  static const double dangerLightMinValue = 0;

  static const double warningTemperatureMinValue = -30;
  static const double warningHumidityMinValue = 20;
  static const double warningVoltageMinValue = 1.5;
  static const double warningCurrentMinValue = 0.5;
  static const double warningLightMinValue = 20000;

  static const double normalTemperatureMinValue = -10;
  static const double normalHumidityMinValue = 30;
  static const double normalVoltageMinValue = 8;
  static const double normalCurrentMinValue = 1;
  static const double normalLightMinValue = 50000;

  static const double normalTemperatureMaxValue = 30;
  static const double normalHumidityMaxValue = 80;
  static const double normalVoltageMaxValue = 12;
  static const double normalCurrentMaxValue = 2;
  static const double normalLightMaxValue = 200000;

  static const double warningTemperatureMaxValue = 50;
  static const double warningHumidityMaxValue = 90;
  static const double warningVoltageMaxValue = 15;
  static const double warningCurrentMaxValue = 2.5;
  static const double warningLightMaxValue = 300000;

  static const double dangerTemperatureMaxValue = 65;
  static const double dangerHumidityMaxValue = 100;
  static const double dangerVoltageMaxValue = 24;
  static const double dangerCurrentMaxValue = 3;
  static const double dangerLightMaxValue = 400000;
}

// Коды для удобного обращения
int codesVoltage = 0;
int codesCurrent = 1;
int codesTemperture = 2;
int codesLight = 3;
int codesHumidity = 4;
int codesRain = 5;

// Коды классы проблем
int codesOverheat = 0;
int codesOvercold = 1;
int codesOvercharge = 2;
int codesHypocharge = 3;
int codesDark = 4;

// Коды уровней информирования
int codesDanger = 0;
int codesWarning = 1;
int codesNormal = 2;
int codesInfo = 3;

int codesLow = 0;
int codesHigh = 1;

// Текущий код проблемы
int codeOfProblem = 0;
// Текущий код статуса
int statusCode = 2;

// Legends
double sizeOfEachColorBlock = 20;
double distBetweenLegendElements = 40;
double heightOfEachSection = 30;

//
//
//
//
/// Экран со статистикой станции
/// Изменяемый
class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StatsScreenState();
}

//
//
//
//
/// Состояние экрана со статистикой станции
/// Отвечает за изменение
class _StatsScreenState extends State<StatsScreen> {
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(children: [
        _buildProblemsCard(settings, theme),
        _buildAdviseCard(settings, theme),
        _buildEfficiencyCard(settings, theme),
        _buildTemperatureGauge(settings, theme),
        _buildHumidityGauge(settings, theme),
        _buildVoltageGauge(settings, theme),
        _buildCurrentGauge(settings, theme),
        _buildLightGauge(settings, theme),
        _buildTableCard(settings, theme),
        _buildAllDataTable(settings, theme)
      ])),
    );
  }

  //
  // Функция построения карточки с текущими проблемами станции
  Widget _buildProblemsCard(AppSettings settings, ThemeData theme) {
    return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icons[statusCode], size: 32, color: colors[statusCode]),
              const SizedBox(
                width: 16,
              ),
              Text(
                problemsInfo,
                style: TextStyle(color: colors[statusCode]),
              ),
            ],
          ),
        ));
  }

  //
  // Функция построения карточки с советами по решению текущих проблем
  Widget _buildAdviseCard(AppSettings settings, ThemeData theme) {
    return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusCode == codesNormal ? Icons.check : Icons.lightbulb,
                  size: 32,
                  color: statusCode == codesNormal
                      ? colors[codesNormal]
                      : colors[codesInfo]),
              const SizedBox(
                width: 16,
              ),
              Text(
                adviseInfo,
                style: TextStyle(
                    color: statusCode == codesNormal
                        ? colors[codesNormal]
                        : colors[codesInfo]),
              ),
            ],
          ),
        ));
  }

  // Текущий процент эффективности
  int percentOfEff = 0;

  // Пороговое проценты эффективности
  int percentOk = 80;
  int percentWarn = 60;
  int percentDang = 20;

  // Текущий временной диапазон
  String range = 'день';

  //
  // Функция построения карточки эффективности станции
  Widget _buildEfficiencyCard(AppSettings settings, ThemeData theme) {
    // TODO: Установить корректную функцию расчета эффективности

    percentOfEff = 85;
    late Color color;
    if (percentOfEff > percentOk) {
      color = colors[codesNormal];
    } else if (percentOfEff > percentWarn) {
      color = colors[codesWarning];
    } else if (percentOfEff > percentDang) {
      color = colors[codesDanger];
    } else {
      color = Colors.grey;
    }

    return Card(
      elevation: 4,
      child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.percent,
                color: color,
                size: 48,
              ),
              const SizedBox(width: 16),
              // В данном случае благодаря максимальному расширению на экране виджет
              // позволяет автоматически переносить текст при уменьшении размера экрана
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Текущая эффективность станции',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(color: color),
                  ),
                  Text(
                    '$percentOfEff%',
                    style:
                        theme.textTheme.headlineSmall?.copyWith(color: color),
                  ),
                ],
              )),
            ],
          )),
    );
  }

  //
  // Функция построения карточки с советами по решению текущих проблем
  // void func({required int num}) - повышает читабельность и модифицируемость
  // required гарантирует, что множество аргументов ( {} - означает множество) будет содержать n1 и n2
  Widget _buildGauge(
      {required String title,
      required String unit,
      required AppSettings settings,
      required ThemeData theme,
      required double dangerMin,
      required double dangerMax,
      required double warnMin,
      required double warnMax,
      required double normalMin,
      required double normalMax,
      required double value}) {
    final double range = (dangerMax - dangerMin);
    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    title,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                const SizedBox(height: 8),
                // Виджет для наложения всех дочерних элементов друг на друга
                // Начинают располагаться с левого верхнего угла друг на друге
                Stack(
                  children: [
                    _buildSectionOfGauge(
                      code: codesDanger,
                      width: (dangerMax - dangerMin) / range,
                      allEdgesCircullar: true,
                    ),
                    _buildSectionOfGauge(
                      code: codesWarning,
                      width: (warnMax - dangerMin) / range,
                      allEdgesCircullar: false,
                    ),
                    _buildSectionOfGauge(
                      code: codesNormal,
                      width: (normalMax - dangerMin) / range,
                      allEdgesCircullar: false,
                    ),
                    _buildSectionOfGauge(
                      code: codesWarning,
                      width: (normalMin - dangerMin) / range,
                      allEdgesCircullar: false,
                    ),
                    _buildSectionOfGauge(
                      code: codesDanger,
                      width: (warnMin - dangerMin) / range,
                      allEdgesCircullar: false,
                    ),
                    Row(
                      children: [
                        Container(
                          width: (value - dangerMin) /
                              range *
                              (MediaQuery.of(context).size.width - 40),
                        ),
                        Container(
                          width: 5,
                          height: 40,
                          decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.4), // Цвет тени
                                  spreadRadius: 1, // Распространение тени
                                  blurRadius: 5, // Размытие тени
                                  offset:
                                      const Offset(0, 3), // Смещение тени вниз
                                ),
                              ],
                              color: Colors.black,
                              borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(16),
                                  bottomRight: Radius.circular(16))),
                          child: Tooltip(
                            message: value.toStringAsFixed(1),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                Padding(
                    padding: const EdgeInsets.all(16),
                    // Виджет, позволяющий переносить дочерние элементы при уменьшении размеров экрана
                    // Удобен при фиксированных размерах содержимого (как здесь с elementOfLegend)
                    child: Wrap(
                      children: [
                        _buildElementOfLegend(
                            code: codesDanger,
                            sizeOfColorBlock: sizeOfEachColorBlock,
                            leftBound: dangerMin,
                            rightBound: warnMin,
                            unit: unit),
                        _buildElementOfLegend(
                            code: codesWarning,
                            sizeOfColorBlock: sizeOfEachColorBlock,
                            leftBound: warnMin,
                            rightBound: normalMin,
                            unit: unit),
                        _buildElementOfLegend(
                            code: codesNormal,
                            sizeOfColorBlock: sizeOfEachColorBlock,
                            leftBound: normalMin,
                            rightBound: normalMax,
                            unit: unit),
                        _buildElementOfLegend(
                            code: codesWarning,
                            sizeOfColorBlock: sizeOfEachColorBlock,
                            leftBound: normalMax,
                            rightBound: warnMax,
                            unit: unit),
                        _buildElementOfLegend(
                            code: codesDanger,
                            sizeOfColorBlock: sizeOfEachColorBlock,
                            leftBound: warnMax,
                            rightBound: dangerMax,
                            unit: unit),
                      ],
                    )),
              ],
            )));
  }

  //
  // Функция построения каждой секции шкалы
  Widget _buildSectionOfGauge(
      {required int code,
      required double width,
      required bool allEdgesCircullar}) {
    // Контейнер, позволяющий изменять свой размер в долях
    // Может занимать всё доступное пространство при widthFactor = 1
    return FractionallySizedBox(
        widthFactor: width,
        // Внутренний контейнер необходим для создания сплошного цвета и закругления углов
        child: Container(
          height: heightOfEachSection,
          // Сама декорация шкалы
          decoration: BoxDecoration(
              color: colors[code],
              borderRadius: allEdgesCircullar
                  ? const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    )),
        ));
  }

  //
  // Функция построения каждого элемента легенды
  Widget _buildElementOfLegend(
      {required int code,
      required double sizeOfColorBlock,
      required double leftBound,
      required double rightBound,
      required String unit}) {
    return Wrap(
      children: [
        Container(
          color: colors[code],
          width: sizeOfEachColorBlock,
          height: sizeOfEachColorBlock,
        ),
        SizedBox(
          width: sizeOfEachColorBlock / 2,
        ),
        Text('$leftBound до $rightBound $unit'),
        SizedBox(
          width: distBetweenLegendElements,
        ),
      ],
    );
  }

  //
  // Функция построения карточки со шкалой температуры
  Widget _buildTemperatureGauge(AppSettings settings, ThemeData theme) {
    return _buildGauge(
        title: 'Температура',
        unit: '℃',
        settings: settings,
        theme: theme,
        dangerMin: GaugeManager.dangerTemperatureMinValue,
        dangerMax: GaugeManager.dangerTemperatureMaxValue,
        warnMin: GaugeManager.warningTemperatureMinValue,
        warnMax: GaugeManager.warningTemperatureMaxValue,
        normalMin: GaugeManager.normalTemperatureMinValue,
        normalMax: GaugeManager.normalTemperatureMaxValue,
        value: settings.sensorHistory.last.temperature);
  }

  //
  // Функция построения карточки со шкалой влажности
  Widget _buildHumidityGauge(AppSettings settings, ThemeData theme) {
    return _buildGauge(
        title: 'Влажность',
        unit: '%',
        settings: settings,
        theme: theme,
        dangerMin: GaugeManager.dangerHumidityMinValue,
        dangerMax: GaugeManager.dangerHumidityMaxValue,
        warnMin: GaugeManager.warningHumidityMinValue,
        warnMax: GaugeManager.warningHumidityMaxValue,
        normalMin: GaugeManager.normalHumidityMinValue,
        normalMax: GaugeManager.normalHumidityMaxValue,
        value: settings.sensorHistory.last.humidity);
  }

  //
  // Функция построения карточки со шкалой силы тока
  Widget _buildCurrentGauge(AppSettings settings, ThemeData theme) {
    return _buildGauge(
        title: 'Сила тока',
        unit: 'А',
        settings: settings,
        theme: theme,
        dangerMin: GaugeManager.dangerCurrentMinValue,
        dangerMax: GaugeManager.dangerCurrentMaxValue,
        warnMin: GaugeManager.warningCurrentMinValue,
        warnMax: GaugeManager.warningCurrentMaxValue,
        normalMin: GaugeManager.normalCurrentMinValue,
        normalMax: GaugeManager.normalCurrentMaxValue,
        value: settings.sensorHistory.last.current);
  }

  //
  // Функция построения карточки со шкалой напряжения
  Widget _buildVoltageGauge(AppSettings settings, ThemeData theme) {
    return _buildGauge(
        title: 'Напряжение',
        unit: 'В',
        settings: settings,
        theme: theme,
        dangerMin: GaugeManager.dangerVoltageMinValue,
        dangerMax: GaugeManager.dangerVoltageMaxValue,
        warnMin: GaugeManager.warningVoltageMinValue,
        warnMax: GaugeManager.warningVoltageMaxValue,
        normalMin: GaugeManager.normalVoltageMinValue,
        normalMax: GaugeManager.normalVoltageMaxValue,
        value: settings.sensorHistory.last.voltage);
  }

  //
  // Функция построения карточки со шкалой освещенности
  Widget _buildLightGauge(AppSettings settings, ThemeData theme) {
    return _buildGauge(
        title: 'Освещенность',
        unit: 'лк',
        settings: settings,
        theme: theme,
        dangerMin: GaugeManager.dangerLightMinValue,
        dangerMax: GaugeManager.dangerLightMaxValue,
        warnMin: GaugeManager.warningLightMinValue,
        warnMax: GaugeManager.warningLightMaxValue,
        normalMin: GaugeManager.normalLightMinValue,
        normalMax: GaugeManager.normalLightMaxValue,
        value: settings.sensorHistory.last.light);
  }

  // TODO: Добавить перестравивание таблицы по новым значениям????
  //
  // Функция построения таблицы детальной статистики
  // TODO: Сделать "умную" фукцию расчета отклонений, минимуов и максимумов для дней-лет
  Widget _buildTableCard(AppSettings settings, ThemeData theme) {
    int codesName = 0;
    int codesNow = 1;
    int codesAvg = 2;
    int codesMin = 3;
    int codesMax = 4;

    late List<SensorData> data;
    switch (range) {
      case 'день':
        data = settings.sensorHistoryDay;
        break;
      case 'месяц':
        data = settings.sensorHistoryMonth;
        break;
      case 'год':
        data = settings.sensorHistoryYear;
        break;
      default:
        data = settings.sensorHistoryDay;
        break;
    }

    // TODO: Сделать правильную логику подбора максимальных и минимальных значений
    // TODO: Продумать логику обновления максимальных значений в ситуациях с днями-годами
    final List<List<String>> strings = [
      [
        'Мощность',
        data.last.power.toString(),
        (data.reduce((v1, v2) => v1 + v2).power / data.length)
            .toStringAsFixed(2),
        data.reduce((v1, v2) => v1.power > v2.power ? v1 : v2).power.toString(),
        data.reduce((v1, v2) => v1.power < v2.power ? v1 : v2).power.toString(),
      ],
      [
        'Сила тока',
        data.last.current.toString(),
        (data.reduce((v1, v2) => v1 + v2).current / data.length)
            .toStringAsFixed(2),
        data
            .reduce((v1, v2) => v1.current > v2.current ? v1 : v2)
            .current
            .toString(),
        data
            .reduce((v1, v2) => v1.current < v2.current ? v1 : v2)
            .current
            .toString(),
      ],
      [
        'Напряжение',
        data.last.voltage.toString(),
        (data.reduce((v1, v2) => v1 + v2).voltage / data.length)
            .toStringAsFixed(2),
        data
            .reduce((v1, v2) => v1.voltage > v2.voltage ? v1 : v2)
            .voltage
            .toString(),
        data
            .reduce((v1, v2) => v1.voltage < v2.voltage ? v1 : v2)
            .voltage
            .toString(),
      ],
      [
        'Температура',
        data.last.temperature.toString(),
        (data.reduce((v1, v2) => v1 + v2).temperature / data.length)
            .toStringAsFixed(2),
        data
            .reduce((v1, v2) => v1.temperature > v2.temperature ? v1 : v2)
            .temperature
            .toString(),
        data
            .reduce((v1, v2) => v1.temperature < v2.temperature ? v1 : v2)
            .temperature
            .toString(),
      ],
      [
        'Влажность',
        data.last.humidity.toString(),
        (data.reduce((v1, v2) => v1 + v2).humidity / data.length)
            .toStringAsFixed(2),
        data
            .reduce((v1, v2) => v1.humidity > v2.humidity ? v1 : v2)
            .humidity
            .toString(),
        data
            .reduce((v1, v2) => v1.humidity < v2.humidity ? v1 : v2)
            .humidity
            .toString(),
      ],
      [
        'Освещенность',
        data.last.light.toString(),
        (data.reduce((v1, v2) => v1 + v2).light / data.length)
            .toStringAsFixed(2),
        data.reduce((v1, v2) => v1.light > v2.light ? v1 : v2).light.toString(),
        data.reduce((v1, v2) => v1.light < v2.light ? v1 : v2).light.toString(),
      ]
    ];

    return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          Stack(
            children: [
              // Виджет, который центрирует дочерний элемент
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Таблица статистики',
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
              // Виджет, позволяющий установить необходимое выравнивание дочернего элемента отсносительно отцовского
              Align(
                  // В центре справа
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showDialogWindow,
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.history,
                        size: 32,
                        color: Colors.grey,
                      ),
                    ),
                  ))
            ],
          ),
          Padding(
              padding: const EdgeInsets.all(16),
              // Построение таблицы
              child: Table(
                // Установка базовой ширины каждого столбца в долях в виде карты "номер столбца <-> ширина столбца"
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                },
                children: [
                  // Построение первой строки таблицы (именование всех столбцов)
                  TableRow(
                      // Декорация каждой строки
                      decoration: const BoxDecoration(
                          // Серая граница снизу
                          border: Border(
                              bottom:
                                  BorderSide(color: Colors.grey, width: 0.5))),
                      // Ячейки в строке (должно быть столько же, сколько и столбцов)
                      children: [
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Параметр',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Текущее значение',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Среднее за $range',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Максимальное за $range',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Минимальное за $range',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ]),
                  // Используем оператор расширения на листе строк, чтобы добавить в лист еще один элемент (во Vue.js также)
                  // Затем используем map для итеративного перебора и замены всех элементов списка
                  ...strings.map((element) =>
                      // Создаем каждую строку таблицы, обрабатывая заданный массив строк
                      TableRow(
                          // Устанавливаем необходимые границы
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: strings.last == element
                                      ? BorderSide.none
                                      : const BorderSide(
                                          color: Colors.grey, width: 0.5))),
                          children: [
                            Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(element[codesName])),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(element[codesNow]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(element[codesAvg]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(element[codesMin]),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(element[codesMax]),
                            ),
                          ]))
                ],
              )),
        ]));
  }

  bool isSecondTableEnabled = false;

  //
  // Функция построения таблицы всех записей
  // TODO: Привязать построение таблицы к кнопке (сделать построние по запросу от пользователя)
  Widget _buildAllDataTable(AppSettings settings, ThemeData theme) {
    late List<SensorData> data;

    switch (range) {
      case 'день':
        data = settings.sensorHistoryDay;
        break;
      case 'месяц':
        data = settings.sensorHistoryMonth;
        break;
      case 'год':
        data = settings.sensorHistoryYear;
        break;
      default:
        data = settings.sensorHistoryDay;
        break;
    }

    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          // Строим таблицу
          child: Table(columnWidths: const {
            0: FlexColumnWidth(1),
            1: FlexColumnWidth(1),
            2: FlexColumnWidth(1),
            3: FlexColumnWidth(1),
            4: FlexColumnWidth(1),
            5: FlexColumnWidth(1),
            6: FlexColumnWidth(1),
          }, children: [
            const TableRow(children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Дата и время',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Мощность',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Напряжение',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Сила тока',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Температура',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Влажность',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Освещенность',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            ...data
                .map((element) => TableRow(
                        decoration: const BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                                    color: Colors.grey, width: 0.5))),
                        children: [
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.timestamp.toString(),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.power.toStringAsFixed(1),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.voltage.toStringAsFixed(1),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.current.toStringAsFixed(1),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.temperature.toStringAsFixed(1),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.humidity.toStringAsFixed(1),
                              )),
                          Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                element.light.toStringAsFixed(0),
                              )),
                        ]))
                .toList(),
          ]),
        ));
  }

  //
  // Функция вывода диалогового окна для запроса нового временного промежутка
  void _showDialogWindow() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Временной промежуток'),
        content: Column(
          children: [
            RadioListTile(
                title: const Text('День'),
                value: 'день',
                groupValue: range,
                onChanged: (value) => {
                      range = value as String,
                      setState(() {}),
                      Navigator.pop(context)
                    }),
            RadioListTile(
                title: const Text('Месяц'),
                value: 'месяц',
                groupValue: range,
                onChanged: (value) => {
                      range = value as String,
                      setState(() {}),
                      Navigator.pop(context)
                    }),
            RadioListTile(
                title: const Text('Год'),
                value: 'год',
                groupValue: range,
                onChanged: (value) => {
                      range = value as String,
                      setState(() {}),
                      Navigator.pop(context)
                    }),
          ],
        ),
      ),
    );
  }
}
