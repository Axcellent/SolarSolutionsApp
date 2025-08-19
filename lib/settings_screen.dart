// TODO: Исправить баг "1.1.1.01 - корректно"
// TODO: Удостовериться в отсутствии вреда от listen: false для настроек
// TODO: Починить отображение цвета при наведении на переключатели

// Импорт необходимых библиотек Flutter'a
import 'package:esp32_sensor_monitor/app_settings.dart';
import 'package:flutter/material.dart'; // Виджеты и прочее
import 'package:provider/provider.dart'; // Для связиста-поисковика

//
//
//
//
/// Экран с настройками приложения
/// Изменяемый
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsScreenState();
}

//
//
//
//
/// Состояние экрана с настройками приложения
/// Отвечает за изменение
class _SettingsScreenState extends State<SettingsScreen> {
  // Контроллер, позволяющий получать текст из поля и изименять этот текст программно
  late TextEditingController ipAddresController = TextEditingController();

  List<bool> isTileExpanded = [false, false, false, false, false, false, false];

  final int codesMain = 0;
  final int codesScreensDashboard = 1;
  final int codesScreensSensors = 2;
  final int codesScreensStats = 3;
  final int codesScreensSettings = 4;
  final int codesStation = 5;
  final int codesOther = 6;

  @override
  Widget build(BuildContext context) {
    AppSettings settings = Provider.of<AppSettings>(context);
    ipAddresController.text = settings.espIpAddress;

    return Scaffold(
        body: SingleChildScrollView(
      // Виджет, позволяющий создавать дочерние раскрывающиеся панели и расставлять в удобном формате
      child: ExpansionPanelList(
        elevation: 4,
        // Функция, которая будет вызываться при нажатии на элемент листа панелей
        expansionCallback: (panelIndex, isExpanded) =>
            // Разворачиваем панель с соответствующим индексом
            {isTileExpanded[panelIndex] = isExpanded, setState(() {})},
        children: [
          _buildMainSettingsSection(settings),
          _buildScreensDashboardSection(settings),
          _buildScreensSensorSection(settings),
          _buildScreensStatsSection(settings),
          _buildScreensSettingsSection(settings),
          _buildStationSection(settings),
          _buildOtherSection(settings)
        ],
      ),
    ));
  }

  //
  // Функция построения панели с главными настройками
  ExpansionPanel _buildMainSettingsSection(AppSettings settings) {
    // Собственно панель с возможностью сворачивания и разворачивания
    return ExpansionPanel(
        // При построении экрана приложения передаем сохранённый флаг развернутости панели (при перестроинии тоже)
        isExpanded: isTileExpanded[codesMain],
        // Заголовок панели (с помощью какой функции его строим)
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text("Основное"),
            ),
        body: Column(children: [
          // Тайл со встроенным переключателем
          SwitchListTile(
              // Надпись на тайле
              title: const Text("Тёмная тема"),
              // Какое текущее значение переключателя
              value: settings.isDarkMode,
              // Функция для выполнения при переключении
              onChanged: settings.toggleDarkMode),
          // Обычный тайл с текстом
          const ListTile(
            title: Text('Модификатор размера текста'),
          ),
          // TODO: Добавить демонстрационный показ размеров шрифта
          // Ползунок для изменения размера шрифта
          Slider(
              // Надпись над кружочком ползунка
              label: settings.textScaleFactor.toString(),
              // Сколько делений
              divisions: 10,
              // Минимальное значение
              min: 0.5,
              // Максимальное значение
              max: 1.5,
              // Значение на второй, фоновой линии
              secondaryTrackValue: 1.0,
              // Текущее значение ползунка
              value: settings.textScaleFactor,
              // Функция, вызываемая при изменении значения ползунка (передаём модификатор размера текста)
              onChanged: (value) => settings.setTextScaleFactor(value)),
          ListTile(
            // Название тайла (текст в центре)
            title: const Text('Уровень тревоги уведомлений'),
            // Элемент в крайней правой части тайла, элемент после названия тайла
            trailing:
                // Выпадающее по нажатию меню, выбираемые значения могут быть только типа String
                DropdownButton<String>(
              // Текущее значение
              value: settings.alertLevel,
              // Варианты выбора (выпадающий список)
              items: const [
                // Элемент выпадающего меню
                DropdownMenuItem(
                  // Значение элемента при выборе
                  value: 'danger',
                  // Отображаемый виджет
                  child: Text('Опасность'),
                ),
                DropdownMenuItem(
                  value: 'warning',
                  child: Text('Предупреждение'),
                ),
                DropdownMenuItem(
                  value: 'info',
                  child: Text('Информирование'),
                ),
              ],
              // Функция, вызываемая при изменении значения (меняет alertLevel в зависимости от выбранного элемента выпадающего списка)
              onChanged: (value) => settings.setAlertLevel(value as String),
            ),
          ),
          ListTile(
            // Элемент в крайней левой части тайла, элемент перед названием тайла
            leading:
                // Кнопка с текстом
                TextButton(
              // Функция, вызываемая при нажатии
              onPressed: () => settings.stopTimer(),
              // Отображаемый виджет
              child: const Text('Выключить'),
            ),
            title: const Text('Автообновление'),
            trailing:
                // Кнопка с текстом
                TextButton(
              onPressed: () => settings.runTimer(),
              child: const Text('Выключить'),
            ),
          ),
        ]));
  }

  //
  // Функция построения панели с настройками экрана выработки
  ExpansionPanel _buildScreensDashboardSection(AppSettings settings) {
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesScreensDashboard],
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Экран выработки'),
            ),
        body: Column(children: [
          SwitchListTile(
              value: settings.showHumidityChart,
              onChanged: (value) => settings.setShowHumidityChart(value))
        ]));
  }

  //
  // Функция построения панели с настройками экрана датчиков
  ExpansionPanel _buildScreensSensorSection(AppSettings settings) {
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesScreensSensors],
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Экран датичков'),
            ),
        body: Column(
          children: [
            SwitchListTile(
                title: const Text('Отображать график температуры'),
                value: settings.showTempChart,
                onChanged: settings.setShowTempChart),
            SwitchListTile(
                title: const Text('Отображать график освещенности'),
                value: settings.showLightChart,
                onChanged: settings.setShowLightChart),
          ],
        ));
  }

  //
  // Функция построения панели с настройками экрана статистики
  ExpansionPanel _buildScreensStatsSection(AppSettings settings) {
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesScreensStats],
        headerBuilder: (context, isExpanded) =>
            const ListTile(title: Text('Экран статистики')),
        body: Column(
          children: [
            // TODO: Поставить правильную функуию и параметр изменения
            SwitchListTile(
                title: const Text('Отображать таблицу недаввних показателей'),
                value: settings.showTempChart,
                onChanged: settings.setShowTempChart),
          ],
        ));
  }

  //
  // Функция построения панели с натсройками экрана настроек, хихихаха
  ExpansionPanel _buildScreensSettingsSection(AppSettings settings) {
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesScreensSettings],
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Экран настроек'),
            ),
        body: const Column(
          children: [],
        ));
  }

  //
  // Функция построения панели с настройками станции
  ExpansionPanel _buildStationSection(AppSettings settings) {
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesStation],
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Станция'),
            ),
        body: Column(
          children: [
            // TODO: Сделать tooltip'ы для информирования
            const Text('IP-адрес станции'),
            ListTile(
              title: TextFormField(
                // Контроллер поля с вводом (для отображения и получения значения)
                controller: ipAddresController,
                // Какая функция будет выполняться при нажатии клавиши Enter
                onFieldSubmitted: (value) => {
                  // Регулярное выражение, меня им еще Андрюшка учил))) Хотя сейчас правильнее рядовой Крикунов
                  // r - индикатор выражения
                  // '^ - индикатор начала строки
                  // (( - скобки для групировки конструкций с "|" = "либо"
                  // либо: 25[0-5] (250,251, ..., 255)
                  // либо: 2[0-4][0-9] (200,201, ..., 249)
                  // либо: [01]?[0-9][0-9]? (0, 1, ..., 199)
                  // ? - предыдущего эелемента может и не быть
                  // \. - точка
                  // {3} - предыдущая часть выражения должна присутствовать в строке три раза
                  // $' - конец строки
                  if (RegExp(r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}'
                          r'(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$')
                      .hasMatch(value))
                    settings.setEspIpAddress(value),
                  setState(() {})
                },
              ),
            )
          ],
        ));
  }

  //
  // Функция построения панели с ДРУГИМИМ ???? настройками
  ExpansionPanel _buildOtherSection(AppSettings settings) {
    // pyatochki?
    return ExpansionPanel(
        isExpanded: isTileExpanded[codesOther],
        headerBuilder: (context, isExpanded) => const ListTile(
              title: Text('Другое'),
            ),
        body: const Column(
          children: [],
        ));
  }
}
