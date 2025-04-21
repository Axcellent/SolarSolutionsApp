import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<AppSettings>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeSetting(context, settings),
          const Divider(),
          _buildRefreshIntervalSetting(context, settings),
          const Divider(),
          _buildEspIpSetting(context, settings),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildThemeSetting(BuildContext context, AppSettings settings) {
    return SwitchListTile(
      title: const Text('Темная тема'),
      value: settings.isDarkMode,
      onChanged: (value) => settings.toggleDarkMode(value),
      secondary: const Icon(Icons.brightness_4),
    );
  }

  Widget _buildRefreshIntervalSetting(
    BuildContext context,
    AppSettings settings,
  ) {
    return ListTile(
      leading: const Icon(Icons.timer),
      title: const Text('Частота обновления (сек)'),
      trailing: DropdownButton<int>(
        value: settings.refreshInterval,
        items: [1, 2, 5, 10, 15, 30, 60]
            .map(
              (value) => DropdownMenuItem(value: value, child: Text('$value')),
            )
            .toList(),
        onChanged: (value) {
          if (value != null) {
            settings.setRefreshInterval(value);
          }
        },
      ),
    );
  }

  Widget _buildEspIpSetting(BuildContext context, AppSettings settings) {
    return ListTile(
      leading: const Icon(Icons.wifi),
      title: const Text('IP адрес ESP32'),
      trailing: SizedBox(
        width: 150,
        child: TextField(
          controller: TextEditingController(text: settings.espIpAddress),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 8),
          ),
          onSubmitted: (value) => settings.setEspIpAddress(value),
        ),
      ),
    );
  }
}
