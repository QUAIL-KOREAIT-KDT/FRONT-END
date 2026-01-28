import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/home_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  RefreshResponse? _refreshInfo;
  bool _isLoading = false;
  String? _error;
  String _location = '서울특별시';

  final HomeService _homeService = HomeService();

  WeatherModel? get weather => _weather;
  RefreshResponse? get refreshInfo => _refreshInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get location => _location;

  // 날씨 정보 로드 (API 연동)
  Future<void> loadWeather({String? location}) async {
    _isLoading = true;
    _error = null;
    if (location != null) _location = location;
    notifyListeners();

    try {
      // 날씨와 환기 정보 병렬 호출
      final results = await Future.wait([
        _homeService.getWeather(),
        _homeService.getRefreshInfo(),
      ]);

      final weatherResponse = results[0] as WeatherResponse;
      final refreshResponse = results[1] as RefreshResponse;

      _weather = _convertToWeatherModel(weatherResponse);
      _refreshInfo = refreshResponse;
      _location = weatherResponse.region.isNotEmpty ? weatherResponse.region : _location;

      debugPrint('[WeatherProvider] 날씨 로드 완료: $_location');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[WeatherProvider] 날씨 로드 실패: $e');
      _error = '날씨 정보를 불러오는데 실패했습니다.';

      // 실패 시 더미 데이터 사용
      _weather = WeatherModel.dummy();
      _refreshInfo = RefreshResponse.dummy();

      _isLoading = false;
      notifyListeners();
    }
  }

  // API 응답을 WeatherModel로 변환
  WeatherModel _convertToWeatherModel(WeatherResponse response) {
    final temp = double.tryParse(response.temp) ?? 0.0;
    final humid = int.tryParse(response.humid) ?? 0;
    final pp = int.tryParse(response.pp) ?? 0;

    String condition;
    String conditionIcon;

    if (pp >= 60) {
      condition = '비';
      conditionIcon = '🌧️';
    } else if (pp >= 30) {
      condition = '흐림';
      conditionIcon = '☁️';
    } else if (temp < 0) {
      condition = '맑고 추움';
      conditionIcon = '❄️';
    } else {
      condition = '맑음';
      conditionIcon = '☀️';
    }

    return WeatherModel(
      temperature: temp,
      humidity: humid,
      condition: condition,
      conditionIcon: conditionIcon,
      dateTime: DateTime.now(),
    );
  }

  // 날씨 새로고침
  Future<void> refreshWeather() async {
    await loadWeather(location: _location);
  }

  // 환기 추천 여부
  bool get isGoodForVentilation {
    if (_weather == null) return false;
    if (_refreshInfo != null && _refreshInfo!.canRefresh) return true;
    return _weather!.humidity < 70 &&
        !_weather!.condition.contains('비') &&
        !_weather!.condition.contains('눈');
  }

  // 환기 추천 메시지
  String get ventilationMessage {
    if (_refreshInfo != null && _refreshInfo!.canRefresh) {
      final times = _refreshInfo!.dateList;
      if (times.isNotEmpty) {
        return '${_formatTime(times.first)} ~ ${_formatTime(times.last)} 환기 추천!';
      }
    }

    if (_weather == null) return '';

    if (isGoodForVentilation) {
      return '지금 환기하기 좋은 날씨예요!';
    } else if (_weather!.humidity >= 80) {
      return '습도가 높아요. 환기보다 제습을 추천해요.';
    } else if (_weather!.condition.contains('비')) {
      return '비가 오고 있어요. 창문을 닫아주세요.';
    } else {
      return '실내 환기에 주의가 필요해요.';
    }
  }

  // 시간 포맷팅 (20260127 1300 -> 13:00)
  String _formatTime(String dateTime) {
    if (dateTime.length >= 13) {
      final hour = dateTime.substring(9, 11);
      final minute = dateTime.substring(11, 13);
      return '$hour:$minute';
    }
    return dateTime;
  }
}
