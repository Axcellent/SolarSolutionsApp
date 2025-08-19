// TODO: Возможно, откорректировать отображение всех иконок (размеры привязать к настройкам)
// TODO: Возможно, передавать данные в функции через  func({required double n1, required double n2}}
// TODO: Важно! Добавить уведомления

// Импорт необходимых библиотек Flutter'a
import 'package:flutter/material.dart'; // Виджеты и прочее
import 'package:provider/provider.dart'; // Для связиста-поисковика

// Импорт всех экранов
import 'app_settings.dart';
import 'sensor_screen.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'dashboard_screen.dart';

//
//
//
//
// ======================================
// Главня функция приложения
// Точка входа в приложение
// ======================================
void main() async {
  // Привязка всех ресурсов и виджетов Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Создание неизменямой переменной с полученным классом настроек
  final settings = AppSettings();
  // Ожидание загрузки настроек (вызов асинхронного метода)
  await settings.loadSettings();

  // Запуск приложения (Развертывание виджета и прикрепление его к представлению)
  runApp(
    // Виджет, предоставляющий доступ к некоторому объекту для всех дочерних
    // Используется для управления состоянием приложения и уведомления виджетов об изменениях
    ChangeNotifierProvider(
      // Все дочерние элементы смогут получать доступ к settings через контекст
      create: (context) => settings,
      // Передача дочернего, основного элемента приложения
      child: const MyApp(),
    ),
  );
}

//
//
//
//
/// ======================================= ///
/// Главный класс приложения                ///
/// Является неизменяемым и статическим     ///
/// ======================================= ///
class MyApp extends StatelessWidget {
  // Конструктор потенциально неизменяемого класса и передача идентификатора движку Flutter'a
  const MyApp({super.key});

  // Аннотация-указание на переопределение метода из родительского класса
  @override

  // Создание пользовательского интерфейса виджета
  // BuildContext [context] отвечает за доступ к родительским элементам и позицию в дереве элементов
  Widget build(BuildContext context) {
    // Использование провайдера объектов для получения из иерархии context объекта класса AppSettings
    final settings = Provider.of<AppSettings>(context);

    final double scaleFactor = settings.textScaleFactor;

    // Корень приложения
    // Предоставляет возможности изменения тем, навигации и локализации
    return MaterialApp(
      title: 'Приложение',
      // Создание темы приложения с использованием метода, позволяющего менять в исходной теме лишь некоторые параметры
      theme: settings.isDarkMode
          ? ThemeData.dark().copyWith(
              // TODO: Приписать все стили текста к множителю из настроек
              textTheme: Theme.of(context).textTheme.copyWith(
                  titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.titleLarge?.fontSize ??
                                    20) *
                                scaleFactor,
                      ),
                  titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.titleSmall?.fontSize ??
                                    12) *
                                scaleFactor,
                      ),
                  titleMedium:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize ??
                                    16) *
                                scaleFactor,
                          ),
                  headlineLarge:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.fontSize ??
                                    12) *
                                scaleFactor,
                          ),
                  headlineMedium:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.fontSize ??
                                    20) *
                                scaleFactor,
                          ),
                  headlineSmall:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.fontSize ??
                                    12) *
                                scaleFactor,
                          )),
              colorScheme: const ColorScheme.dark(
                primary: Color.fromARGB(255, 255, 171, 171),
                secondary: Color.fromARGB(255, 225, 77, 77),
                tertiary: Color.fromARGB(255, 248, 221, 221),
              ),
            )
          : ThemeData.light().copyWith(
              textTheme: Theme.of(context).textTheme.copyWith(
                  titleLarge: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.titleLarge?.fontSize ??
                                    20) *
                                scaleFactor,
                      ),
                  titleSmall: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontSize:
                            (Theme.of(context).textTheme.titleSmall?.fontSize ??
                                    12) *
                                scaleFactor,
                      ),
                  titleMedium:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.fontSize ??
                                    16) *
                                scaleFactor,
                          ),
                  headlineLarge:
                      Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.fontSize ??
                                    12) *
                                scaleFactor,
                          ),
                  headlineMedium:
                      Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineMedium
                                        ?.fontSize ??
                                    20) *
                                scaleFactor,
                          ),
                  headlineSmall:
                      Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontSize: (Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.fontSize ??
                                    12) *
                                scaleFactor,
                          )),
              colorScheme: ColorScheme.light(
                  primary: Colors.blue,
                  secondary: Colors.cyan[600]!,
                  tertiary: const Color.fromARGB(255, 77, 189, 189)),
            ),
      // Виджет на руте "По умолчанию"
      home: const MainScreen(),
      // Показывать баннер режима отладки
      debugShowCheckedModeBanner: false,
    );
  }
}

// primary: Color.fromARGB(255, 139, 96, 96),
//                 secondary: Color.fromARGB(255, 225, 77, 77),

//
//
//
//
/// ======================================= ///
/// Главный экран приложения                ///
/// Является изменяемым                     ///
/// ======================================= ///
class MainScreen extends StatefulWidget {
  // Конструктор потенциально неизменяемого класса и передача идентификатора движку Flutter'a
  const MainScreen({super.key});

  // Аннотация-указание на переопределение метода из родительского класса
  @override
  // Создание экземпляра изменяемого состояния для текущего класса
  State<MainScreen> createState() => _MainScreenState();
}

//
//
//
//
/// ======================================= ///
/// Состояние главного экрана приложения    ///
/// Отвечает за изменение                   ///
/// ======================================= ///
class _MainScreenState extends State<MainScreen> {
  // Индекс текущего подэкрана
  int _currentIndex = 0;

  // Список текущих подэкранов
  static const List<Widget> _screens = [
    DashboardScreen(),
    SensorScreen(),
    StatsScreen(),
    SettingsScreen(),
  ];

  // Аннотация-указание на переопределение метода из родительского класса
  @override
  // Создание пользовательского интерфейса виджета
  // BuildContext [context] отвечает за доступ к родительским элементам и позицию в дереве элементов
  Widget build(BuildContext context) {
    // Создание подмосток для построения главного экрана
    return Scaffold(
      // В центре - текущий подэкран
      body: _screens[_currentIndex],
      // Нижняя панель навигации
      bottomNavigationBar: BottomNavigationBar(
        // Отключение старого режима цветосхемы
        useLegacyColorScheme: false,
        // Установка текущего активного индекса
        currentIndex: _currentIndex,
        // При нажатии по иконке с индексом изменяется состояние экрана с учетом изменения индекса
        onTap: (index) => setState(() => _currentIndex = index),
        // Собственно иконки-кнопки (список константный)
        items: const [
          // Элемент панели навигации с указанием иконки и названия
          BottomNavigationBarItem(
            icon: Icon(Icons.solar_power),
            label: "Главная",
          ),
          // Элемент панели навигации с указанием иконки и названия
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: "Датчики",
          ),
          // Элемент панели навигации с указанием иконки и названия
          BottomNavigationBarItem(
            icon: Icon(Icons.data_saver_on),
            label: "Статистика датчиков",
          ),
          // Элемент панели навигации с указанием иконки и названия
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Настройки",
          ),
        ],
      ),
    );
  }
}
