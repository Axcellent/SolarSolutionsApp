// TODO: Откорректировать отображение цветов текста и иконок в темной теме (побитые цвета)
// TODO: Откорректировать отображение "дополнительной" строки со сбережениями и CO2 (текст едет за границы)
// TODO: Откорректировать цветовую гамму для экрана (много цветов)
// TODO: Создать дизайнерский вариант для мобильных устройств (проблема в широкой дополнительной строке - надо на мобилках на две разбить, плюс выравнивание слева мб лучше)
// TODO: Откорректировать размеры иконок для ПК (вверху мелко)
// TODO: Откорректировать размещение GestureDetector (переместить на надписи с "день" и т.д)

// Импорт необходимых библиотек Flutter'a
import 'package:flutter/material.dart'; // Виджеты и прочее
import 'package:provider/provider.dart'; // Для связиста-поисковика

// Импорт класса с настройками приложения
import 'app_settings.dart';

// Лист для хранения пороговых значений статуса
// Формат: [i][j][k]
// i - Код показателя, по которому нужны границы статуса
// j - Выбор верхней или нижней границы статуса
// k - Выбор характера конкретного статуса (опасность или предупреждение)
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

// Лист для хранения всплывающих подсказок
// Формат: [i][j]
// i - Код показателя, по которому нужно получить всплывающую подсказку
// j - Выбор классификации подсказки
List<List<String>> tooltips = [
  ['Опасная температура!', 'Проблемы с температурой', 'Температура в норме'],
  ['Нестабильное напряжение!', 'Проблемы с напряжением', 'Температура в норме'],
  ['Низкая освещенность!', 'Проблемы с освещенностью', 'Температура в норме'],
  ['Высокая влажность!', 'Повышенная влажность', 'Температура в норме'],
  ['Дождь!', ' ', 'Дождя нет'],
];

// Лист иконок панели статусов для удобного редактирования
const List<IconData> iconsOfStatusBar = [
  Icons.thermostat,
  Icons.bolt,
  Icons.wb_sunny,
  Icons.water_drop,
  Icons.water_damage
];

// Лист цветов иконок панели статусов для удобного редактирования
const List<Color> colorsByStatus = [
  Colors.red,
  Colors.orange,
  Colors.green,
  Colors.grey
];

// Лист размеров иконок панели статусов для удобного редактирования
const List<double> sizesByStatus = [32, 24, 16];

// Коды для удобного обращения
int codesTemperture = 0;
int codesVoltage = 1;
int codesLight = 2;
int codesHumidity = 3;
int codesRain = 4;

int codesDanger = 0;
int codesWarning = 1;
int codesOk = 2;

int codesLowBound = 0;
int codesHighBound = 1;

//
//
//
//
/// Экран с основными показателями
/// Изменяемый
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<StatefulWidget> createState() => _DashboardScreenState();
}

//
//
//
//
/// Состояние экрана с основными показателями
/// Отвечает за изменение
class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    // Локальная переменная с классом статических настроек
    final settings = Provider.of<AppSettings>(context);
    // Локальная переменная с текущей темой приложения
    final theme = Theme.of(context);

    // Строительные подмостки для формирования экрана
    return Scaffold(
      // Виджет для создания возможности прокрутки всех дочерних элементов
      body: SingleChildScrollView(
          // Задание внутренних отступов со всех сторон
          padding: const EdgeInsets.all(16),
          child: settings.errorMessage.isEmpty
              ? Column(
                  children: [
                    // SizedBox(width: double.infinity) - контейнер, который занимает всю доступную ширину

                    // Плашка с иконками статуса панели и отступ
                    SizedBox(
                        width: double.infinity,
                        child: _buildStatusBar(settings)),
                    const SizedBox(
                      height: 16,
                    ),

                    // Плашка с текущей мощностью панели и отступ
                    SizedBox(
                        width: double.infinity,
                        child: _buildPowerCard(settings, theme)),
                    const SizedBox(
                      height: 16,
                    ),

                    // Плашка с общей выработкой и отступ
                    SizedBox(
                        width: double.infinity,
                        child: _buildTotalProdCard(settings, theme)),
                    const SizedBox(
                      height: 16,
                    ),

                    // Плашка со средней выработкой панели и отступ
                    SizedBox(
                        width: double.infinity,
                        child: _buildAverageProdCard(settings, theme)),
                    const SizedBox(
                      height: 16,
                    ),

                    // Плашка с дополнительной информацией и отступ
                    _buildAdditionalRow(settings, theme),
                  ],
                )
              : Text(settings.errorMessage)),
    );
  }

  //
  // Построение виджета плашки статуса
  Widget _buildStatusBar(AppSettings settings) {
    // Строка
    return Row(
      // Центрирование содержимого по горизонтали
      mainAxisAlignment: MainAxisAlignment.center,
      // Все иконки статусов
      children: [
        // Расширенный до 20% ширины экрана статус по температуре
        Expanded(
            child: _buildStatusIcon(
                codesTemperture, settings.sensorHistory.last.temperature)),
        // Расширенный до 20% ширины экрана статус по напряжению
        Expanded(
            child: _buildStatusIcon(
                codesVoltage, settings.sensorHistory.last.temperature)),
        // Расширенный до 20% ширины экрана статус по свету
        Expanded(
            child: _buildStatusIcon(
                codesLight, settings.sensorHistory.last.temperature)),
        // Расширенный до 20% ширины экрана статус по влажности
        Expanded(
            child: _buildStatusIcon(
                codesHumidity, settings.sensorHistory.last.temperature)),
        // Расширенный до 20% ширины экрана статус по влажности
        if (settings.isRaining && settings.showRainIndicator)
          Expanded(child: _buildStatusIcon(codesRain, 10)),
      ],
    );
  }

  //
  // Построение виджета иконки статуса
  Widget _buildStatusIcon(int code, double value) {
    // Код статуса обстановки по данному показателю
    int statusCode = _getStatusCode(code, value);

    // Размер иконки с данным кодом статуса
    final double size = sizesByStatus[statusCode];
    // Цвет иконки с данным кодом статуса
    final Color color = colorsByStatus[statusCode];
    // Иконка текущего показателя
    final IconData icon = iconsOfStatusBar[code];
    // Всплывающая подсказка текущего показателя с данным кодом статуса
    final String tooltip = tooltips[code][statusCode];

    // Создание контейнера для иконки
    return Tooltip(
      message: tooltip,
      child: Container(
        // Внешние отступы от остальных элементов
        margin: const EdgeInsets.all(0),
        // Внутренние отступы от дочерних элементов
        padding: const EdgeInsets.all(12),
        // Создание корректной декорации
        decoration: BoxDecoration(
            // Цвет с небольшой прозрачностью
            color: color.withValues(alpha: 0.2),
            // Фигура круга
            shape: BoxShape.circle,
            // Покраска границ и установка их толщины
            border: Border.all(color: color, width: 2)),
        child: Icon(icon, color: color, size: size),
      ),
    );
  }

  //
  // Построение виджета плашки текущей мощности
  Widget _buildPowerCard(AppSettings settings, ThemeData theme) {
    return Card(
      // Подъем карточки
      elevation: 4,
      // Установка границ вида закругленного прямоугольника
      shape: RoundedRectangleBorder(
          // Радиус закругления в 16 единиц
          borderRadius: BorderRadius.circular(16)),
      child: Padding(
          // Отступы от внутреннего содержимого
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Строка с показателем мощности и иконкой для его определения
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.power, size: 40, color: theme.colorScheme.primary),
                Text(
                  '${settings.sensorHistory.last.power.toStringAsFixed(2)} Вт',
                  style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary),
                ),
              ]),
              // Отступ
              const SizedBox(
                height: 12,
              ),
              // Линия с описанием
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 16, color: Colors.grey),
                  SizedBox(width: 4),
                  Text('Текущая мощность станции',
                      style: TextStyle(color: Colors.grey)),
                ],
              )
            ],
          )),
    );
  }

  //
  // Построение виджета плашки общей выработки
  Widget _buildTotalProdCard(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
                // Установка функции для одинарного нажатия
                onTap: () =>
                    // Вывод диалогового окна настроек временного промежутка
                    _showTimeRangeDialog(
                      context,
                      'production',
                      settings.productionTimeRange,
                      // Функция изменения временного промежутка из настроек
                      settings.setProductionTimeRange,
                    ),
                child: Column(children: [
                  Icon(Icons.energy_savings_leaf,
                      size: 32, color: theme.colorScheme.secondary),
                  Text(
                    '${settings.totalProduction[_getCurrentRangeCode(settings.productionTimeRange)].toString()} кВт•ч',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Общая выработка за ${_getCurrentRangeName(settings.productionTimeRange)}',
                      style: const TextStyle(color: Colors.grey),
                    )
                  ]),
                ]))));
  }

  //
  // Построение виджета плашки средней выработки
  Widget _buildAverageProdCard(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
                // Установка функции для одинарного нажатия
                onTap: () => _showTimeRangeDialog(
                      context,
                      'production',
                      settings.productionTimeRange,
                      // Функция изменения временного промежутка из настроек
                      settings.setProductionTimeRange,
                    ),
                child: Column(children: [
                  Icon(Icons.analytics,
                      size: 32, color: theme.colorScheme.secondary),
                  Text(
                    '${settings.avrgProduction[_getCurrentRangeCode(settings.productionTimeRange)].toString()} кВт•ч/ч',
                    style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.secondary),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Средняя выработка за ${_getCurrentRangeName(settings.productionTimeRange)}',
                      style: const TextStyle(color: Colors.grey),
                    )
                  ]),
                ]))));
  }

  //
  // Построение виджета плашки дополнительной информации
  Widget _buildAdditionalRow(AppSettings settings, ThemeData theme) {
    return Row(
      children: [
        // Заполнение половины ширины экрана
        if (settings.showCO2Reduction)
          Expanded(
              child: settings.showSavings
                  ? _buildCO2Card(settings, theme)
                  : _buildCO2SoloCard(settings, theme)),
        if (settings.showCO2Reduction) const SizedBox(width: 16),
        // Заполнение половины ширины экрана
        if (settings.showSavings)
          Expanded(
              child: settings.showCO2Reduction
                  ? _buildSavings(settings, theme)
                  : _buildSoloSavings(settings, theme)),
      ],
    );
  }

  //
  // Построение виджета с данными о сокращении углеродного следа
  Widget _buildCO2Card(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
              // Установка функции для одинарного нажатия
              onTap: () =>
                  // Вывод диалогового окна настроек временного промежутка
                  _showTimeRangeDialog(
                context,
                'co2',
                settings.co2TimeRange,
                // Функция изменения временного промежутка из настроек
                settings.setCo2TimeRange,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Icon(Icons.co2, size: 64, color: theme.colorScheme.tertiary),
                  Expanded(
                      child: Column(children: [
                    Text(
                      '${settings.co2Savings[_getCurrentRangeCode(settings.co2TimeRange)].toString()} кг',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Сокращено CO2 за ${_getCurrentRangeName(settings.co2TimeRange)}',
                        style: const TextStyle(color: Colors.grey),
                      )
                    ]),
                  ]))
                ],
              ),
            )));
  }

  //
  // Построение виджета с данными о сокращении углеродного следа
  Widget _buildCO2SoloCard(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
              // Установка функции для одинарного нажатия
              onTap: () =>
                  // Вывод диалогового окна настроек временного промежутка
                  _showTimeRangeDialog(
                context,
                'co2',
                settings.co2TimeRange,
                // Функция изменения временного промежутка из настроек
                settings.setCo2TimeRange,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                  ),
                  Icon(Icons.co2, size: 64, color: theme.colorScheme.tertiary),
                  Text(
                    '${settings.co2Savings[_getCurrentRangeCode(settings.co2TimeRange)].toString()} кг',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Сокращено CO2 за ${_getCurrentRangeName(settings.co2TimeRange)}',
                      style: const TextStyle(color: Colors.grey),
                    )
                  ]),
                ],
              ),
            )));
  }

  //
  // Построение виджета с данными об экономии средств
  Widget _buildSavings(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
              // Установка функции для одинарного нажатия
              onTap: () =>
                  // Вывод диалогового окна настроек временного промежутка
                  _showTimeRangeDialog(
                context,
                'savings',
                settings.savingsTimeRange,
                // Функция изменения временного промежутка из настроек
                settings.setSavingsTimeRange,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 22,
                  ),
                  Icon(Icons.savings,
                      size: 64, color: theme.colorScheme.tertiary),
                  Expanded(
                      child: Column(children: [
                    Text(
                      '${(settings.totalProduction[_getCurrentRangeCode(settings.savingsTimeRange)] * settings.costPerKWh).toStringAsFixed(1)} рублей',
                      style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.tertiary),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(
                        Icons.history,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Сэкономлено средств за ${_getCurrentRangeName(settings.savingsTimeRange)}',
                        style: const TextStyle(color: Colors.grey),
                      )
                    ]),
                  ]))
                ],
              ),
            )));
  }

  //
  // Построение виджета с данными об экономии средств
  Widget _buildSoloSavings(AppSettings settings, ThemeData theme) {
    return Card(
        // Подъем карточки
        elevation: 4,
        // Установка границ вида закругленного прямоугольника
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // Элемент для создания отступов от внутренних элементов
        child: Padding(
            // Отступы от внутренних элементов
            padding: const EdgeInsets.all(16),
            // Виджет для определения жестов
            child: GestureDetector(
              // Установка функции для одинарного нажатия
              onTap: () =>
                  // Вывод диалогового окна настроек временного промежутка
                  _showTimeRangeDialog(
                context,
                'savings',
                settings.savingsTimeRange,
                // Функция изменения временного промежутка из настроек
                settings.setSavingsTimeRange,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 22,
                  ),
                  Icon(Icons.savings,
                      size: 64, color: theme.colorScheme.tertiary),
                  Text(
                    '${(settings.totalProduction[_getCurrentRangeCode(settings.savingsTimeRange)] * settings.costPerKWh).toStringAsFixed(1)} рублей',
                    style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.tertiary),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(
                      Icons.history,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Text(
                      'Сэкономлено средств за ${_getCurrentRangeName(settings.savingsTimeRange)}',
                      style: const TextStyle(color: Colors.grey),
                    )
                  ]),
                ],
              ),
            )));
  }

  //
  // Функция получения строкового представления текущего временного промежутка
  String _getCurrentRangeName(String range) {
    switch (range) {
      case 'day':
        return 'день';
      case 'month':
        return 'месяц';
      case 'year':
        return 'год';
      default:
        return 'undefined';
    }
  }

  //
  // Функция получения строкового представления текущего временного промежутка
  int _getCurrentRangeCode(String range) {
    switch (range) {
      case 'day':
        return 0;
      case 'month':
        return 1;
      case 'year':
        return 2;
      default:
        return 3;
    }
  }

  //
  // Функция получения кода статуса по данному показателю (предупреждение/опасность/стабильность)
  int _getStatusCode(int code, double value) {
    // Проверка на границы предупреждения
    if (value < statusManagerData[code][codesLowBound][codesWarning] ||
        value > statusManagerData[code][codesHighBound][codesWarning]) {
      return codesWarning;
    }
    // Проверка на границы опасности
    if (value < statusManagerData[code][codesLowBound][codesDanger] ||
        value > statusManagerData[code][codesHighBound][codesDanger]) {
      return codesDanger;
    }

    // Все в норме
    return codesOk;
  }

  //
  // Функция вывода окна для запроса нового временного промежутка
  void _showTimeRangeDialog(BuildContext context, String type,
      String currentRange, Function(String) funcOnChanged) {
    // Функция вывода диалогового окна
    showDialog(
        // Передача контекста для установки в дереве виджетов
        context: context,
        // Функция построения окна (какое окно построить и как это сделать?)
        builder: (context) => AlertDialog(
              title: const Text('Выберите период'),
              content:
                  // Внутренний контент диалога
                  // Виджет с возможностью прокрутки содержимого
                  SingleChildScrollView(
                      // Создание всех вариантов списка в колоночку
                      child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Элемент "радио" списка (с переключателем)
                  // Для закрытия списка нам и нужен Navigator, который отвечает за context
                  RadioListTile(
                      title: const Text('День'),
                      // Кодовое значение текущего элемента списка
                      value: 'day',
                      // Какой элемент выбран по умолчанию
                      groupValue: currentRange,
                      // Когда вызывается изменение состояние текущего элемента
                      onChanged: (value) {
                        // Перерисовываем экран
                        setState(() {});
                        // Вызывается определенная нами функция обработки изменений (из настроек)
                        funcOnChanged(value as String);
                        // Закрывается текущее диалоговое окно
                        Navigator.pop(context);
                      }),
                  // Элемент "радио" списка (с переключателем)
                  RadioListTile(
                    title: const Text('Месяц'),
                    // Кодовое значение текущего элемента списка
                    value: 'month',
                    // Какой элемент выбран по умолчанию
                    groupValue: currentRange,
                    // Когда вызывается изменение состояние текущего элемента
                    onChanged: (value) {
                      // Перерисовываем экран
                      setState(() {});
                      // Вызывается определенная нами функция обработки изменений (из настроек)
                      funcOnChanged(value as String);
                      // Закрывается текущее диалоговое окно
                      Navigator.pop(context);
                    },
                  ),
                  // Элемент "радио" списка (с переключателем)
                  RadioListTile(
                    title: const Text('Год'),
                    // Кодовое значение текущего элемента списка
                    value: 'year',
                    // Какой элемент выбран по умолчанию
                    groupValue: currentRange,
                    // Когда вызывается изменение состояние текущего элемента
                    onChanged: (value) {
                      // Перерисовываем экран
                      setState(() {});
                      // Вызывается определенная нами функция обработки изменений (из настроек)
                      funcOnChanged(value as String);
                      // Закрывается текущее диалоговое окно
                      Navigator.pop(context);
                    },
                  )
                ],
              )),
            ));
  }
}
