import 'package:flutter/material.dart';
import '../models/mold_risk.dart';
import '../models/weather.dart';
import '../services/home_service.dart';

class MoldRiskProvider extends ChangeNotifier {
  MoldRiskModel? _moldRisk;
  WeatherModel? _weather;
  RefreshResponse? _refreshInfo;
  bool _isLoading = false;

  final HomeService _homeService = HomeService();

  MoldRiskModel? get moldRisk => _moldRisk;
  WeatherModel? get weather => _weather;
  RefreshResponse? get refreshInfo => _refreshInfo;
  bool get isLoading => _isLoading;

  // 위험도 및 날씨 데이터 로드 (API 연동)
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 병렬로 API 호출
      final results = await Future.wait([
        _homeService.getMoldRisk(),
        _homeService.getWeather(),
        _homeService.getRefreshInfo(),
      ]);

      final moldRiskResponse = results[0] as MoldRiskResponse;
      final weatherResponse = results[1] as WeatherResponse;
      final refreshResponse = results[2] as RefreshResponse;

      // 곰팡이 위험도 변환
      _moldRisk = _convertToMoldRiskModel(moldRiskResponse, refreshResponse);

      // 날씨 변환
      _weather = _convertToWeatherModel(weatherResponse);

      // 환기 정보 저장
      _refreshInfo = refreshResponse;

      debugPrint('[MoldRiskProvider] 데이터 로드 완료');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[MoldRiskProvider] 데이터 로드 실패: $e');
      // 실패 시 더미 데이터 사용
      _moldRisk = MoldRiskModel.dummy();
      _weather = WeatherModel.dummy();
      _refreshInfo = RefreshResponse.dummy();

      _isLoading = false;
      notifyListeners();
    }
  }

  // API 응답을 MoldRiskModel로 변환
  MoldRiskModel _convertToMoldRiskModel(
    MoldRiskResponse response,
    RefreshResponse refreshResponse,
  ) {
    // moldIndex를 위험 레벨로 변환
    String riskLevel;
    int riskPercentage;

    switch (response.moldIndex) {
      case '매우 양호':
        riskLevel = 'safe';
        riskPercentage = 10;
        break;
      case '양호':
        riskLevel = 'safe';
        riskPercentage = 25;
        break;
      case '보통':
        riskLevel = 'caution';
        riskPercentage = 50;
        break;
      case '나쁨':
        riskLevel = 'warning';
        riskPercentage = 75;
        break;
      case '매우 나쁨':
        riskLevel = 'danger';
        riskPercentage = 95;
        break;
      default:
        riskLevel = 'safe';
        riskPercentage = 20;
    }

    // 환기 추천 메시지 생성
    String recommendation;
    String? ventilationStart;
    String? ventilationEnd;

    if (refreshResponse.canRefresh && refreshResponse.dateList.isNotEmpty) {
      ventilationStart = _formatTime(refreshResponse.dateList.first);
      ventilationEnd = _formatTime(refreshResponse.dateList.last);
      recommendation = '$ventilationStart ~ $ventilationEnd 사이에 환기를 추천해요!';
    } else {
      recommendation = refreshResponse.message;
    }

    return MoldRiskModel(
      riskPercentage: riskPercentage,
      riskLevel: riskLevel,
      recommendation: recommendation,
      ventilationTimeStart: ventilationStart,
      ventilationTimeEnd: ventilationEnd,
      updatedAt: DateTime.now(),
    );
  }

  // API 응답을 WeatherModel로 변환
  WeatherModel _convertToWeatherModel(WeatherResponse response) {
    final temp = double.tryParse(response.temp) ?? 0.0;
    final humid = int.tryParse(response.humid) ?? 0;

    // 강수확률에 따른 날씨 상태 결정
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

  // 시간 포맷팅 (20260127 1300 -> 13:00)
  String _formatTime(String dateTime) {
    if (dateTime.length >= 13) {
      final hour = dateTime.substring(9, 11);
      final minute = dateTime.substring(11, 13);
      return '$hour:$minute';
    }
    return dateTime;
  }

  // 새로고침
  Future<void> refresh() async {
    await loadData();
  }
}
