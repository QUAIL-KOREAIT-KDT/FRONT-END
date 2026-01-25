import 'package:flutter/material.dart';
import '../models/weather.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  bool _isLoading = false;
  String? _error;
  String _location = '서울특별시';

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get location => _location;

  // 날씨 정보 로드
  Future<void> loadWeather({String? location}) async {
    _isLoading = true;
    _error = null;
    if (location != null) _location = location;
    notifyListeners();

    try {
      // TODO: 실제 날씨 API 연동
      await Future.delayed(const Duration(milliseconds: 800));

      // 더미 데이터
      _weather = WeatherModel(
        temperature: 18,
        humidity: 65,
        condition: '맑음',
        conditionIcon: '☀️',
        dateTime: DateTime.now(),
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = '날씨 정보를 불러오는데 실패했습니다.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // 날씨 새로고침
  Future<void> refreshWeather() async {
    await loadWeather(location: _location);
  }

  // 환기 추천 여부
  bool get isGoodForVentilation {
    if (_weather == null) return false;
    // 습도가 낮고 비가 오지 않을 때 환기 추천
    return _weather!.humidity < 70 &&
        !_weather!.condition.contains('비') &&
        !_weather!.condition.contains('눈');
  }

  // 환기 추천 메시지
  String get ventilationMessage {
    if (_weather == null) return '';

    if (isGoodForVentilation) {
      return '지금 환기하기 좋은 날씨예요! 🌬️';
    } else if (_weather!.humidity >= 80) {
      return '습도가 높아요. 환기보다 제습을 추천해요.';
    } else if (_weather!.condition.contains('비')) {
      return '비가 오고 있어요. 창문을 닫아주세요.';
    } else {
      return '실내 환기에 주의가 필요해요.';
    }
  }
}
