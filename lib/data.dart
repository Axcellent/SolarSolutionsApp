library my_app.data;

List<SensorData> sensorHistory = [];
int sharedVariable = 0; // Общая переменная

class SensorData {
  final double voltage;
  final double temperature;
  final double light;
  final DateTime timestamp;

  SensorData({
    required this.voltage,
    required this.temperature,
    required this.light,
    required this.timestamp,
  });
}
