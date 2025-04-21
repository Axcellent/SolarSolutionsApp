import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';
import 'sensor_screen.dart';
import 'settings_screen.dart';
import 'StatsScreen.dart';
import 'solar_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = AppSettings();
  await settings.loadSettings();

  runApp(
    ChangeNotifierProvider(
      create: (context) => settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return MaterialApp(
      title: 'ESP32 Sensor Monitor',
      theme: settings.isDarkMode
          ? ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.blueGrey,
                secondary: Colors.cyan[300]!,
              ),
            )
          : ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: Colors.blue,
                secondary: Colors.cyan[800]!,
              ),
            ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const SensorScreen(),
    const SettingsScreen(),
    const StatsScreen(),
    const SolarDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            label: 'Датчики',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Настройки',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.data_saver_on),
            label: 'Статистика датчиков',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sunny),
            label: 'Статистика панели',
          ),
        ],
      ),
    );
  }
}
