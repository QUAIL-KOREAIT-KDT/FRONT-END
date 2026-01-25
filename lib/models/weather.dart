class WeatherModel {
  final double temperature;
  final int humidity;
  final String condition;
  final String conditionIcon;
  final DateTime dateTime;

  WeatherModel({
    required this.temperature,
    required this.humidity,
    required this.condition,
    required this.conditionIcon,
    required this.dateTime,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      temperature: json['temperature']?.toDouble() ?? 0.0,
      humidity: json['humidity'] ?? 0,
      condition: json['condition'] ?? '맑음',
      conditionIcon: json['condition_icon'] ?? '☀️',
      dateTime: json['date_time'] != null
          ? DateTime.parse(json['date_time'])
          : DateTime.now(),
    );
  }

  // 더미 데이터
  factory WeatherModel.dummy() {
    return WeatherModel(
      temperature: -2,
      humidity: 45,
      condition: '맑음',
      conditionIcon: '☀️',
      dateTime: DateTime.now(),
    );
  }
}
