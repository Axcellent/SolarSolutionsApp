import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettings with ChangeNotifier {
  bool _isDarkMode = false;
  int _refreshInterval = 5; // секунды
  String _espIpAddress = '192.168.1.100';

  bool get isDarkMode => _isDarkMode;
  int get refreshInterval => _refreshInterval;
  String get espIpAddress => _espIpAddress;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _refreshInterval = prefs.getInt('refreshInterval') ?? 5;
    _espIpAddress = prefs.getString('espIpAddress') ?? '192.168.1.100';
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveToPrefs('isDarkMode', value);
    notifyListeners();
  }

  Future<void> setRefreshInterval(int value) async {
    _refreshInterval = value;
    await _saveToPrefs('refreshInterval', value);
    notifyListeners();
  }

  Future<void> setEspIpAddress(String value) async {
    _espIpAddress = value;
    await _saveToPrefs('espIpAddress', value);
    notifyListeners();
  }

  Future<void> _saveToPrefs<T>(String key, T value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }
}
