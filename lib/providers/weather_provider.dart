import 'package:flutter/material.dart';
import '../models/weather.dart';
import '../services/home_service.dart';

class WeatherProvider extends ChangeNotifier {
  WeatherModel? _weather;
  HomeInfoResponse? _homeInfo;
  bool _isLoading = false;
  String? _error;
  String _location = '서울특별시';

  final HomeService _homeService = HomeService();

  WeatherModel? get weather => _weather;
  HomeInfoResponse? get homeInfo => _homeInfo;
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
      // 단일 API로 모든 정보 가져오기
      _homeInfo = await _homeService.getHomeInfo();

      _weather = _convertToWeatherModel(_homeInfo!);
      _location = _homeInfo!.regionAddress.isNotEmpty
          ? _homeInfo!.regionAddress
          : _location;

      debugPrint('[WeatherProvider] 날씨 로드 완료: $_location');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[WeatherProvider] 날씨 로드 실패: $e');
      _error = '날씨 정보를 불러오는데 실패했습니다.';

      // 실패 시 더미 데이터 사용
      _weather = WeatherModel.dummy();
      _homeInfo = null;

      _isLoading = false;
      notifyListeners();
    }
  }

  // API 응답을 WeatherModel로 변환
  WeatherModel _convertToWeatherModel(HomeInfoResponse response) {
    if (response.currentWeather.isEmpty) {
      return WeatherModel.dummy();
    }

    final weatherDetail = response.currentWeather.first;
    final temp = weatherDetail.temp;
    final humid = weatherDetail.humid.toInt();
    final rainProb = weatherDetail.rainProb;

    String condition;
    String conditionIcon;

    if (rainProb >= 60) {
      condition = '비';
      conditionIcon = '🌧️';
    } else if (rainProb >= 30) {
      condition = '흐림';
      conditionIcon = '☁️';
    } else if (temp < 0) {
      condition = '맑고 추움';
      conditionIcon = '❄️';
    } else {
      condition =
          weatherDetail.condition.isNotEmpty ? weatherDetail.condition : '맑음';
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
    if (_homeInfo != null && _homeInfo!.ventilationTimes.isNotEmpty)
      return true;
    return _weather!.humidity < 70 &&
        !_weather!.condition.contains('비') &&
        !_weather!.condition.contains('눈');
  }

  // 환기 추천 메시지
  String get ventilationMessage {
    if (_homeInfo != null && _homeInfo!.ventilationTimes.isNotEmpty) {
      final vent = _homeInfo!.ventilationTimes.first;
      if (vent.description.isNotEmpty) {
        return vent.description;
      }
      return '${vent.startTime} ~ ${vent.endTime} 환기 추천!';
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
}
