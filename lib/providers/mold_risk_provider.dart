import 'package:flutter/material.dart';
import '../models/mold_risk.dart';
import '../models/weather.dart';
import '../services/home_service.dart';

class MoldRiskProvider extends ChangeNotifier {
  MoldRiskModel? _moldRisk;
  WeatherModel? _weather;
  HomeInfoResponse? _homeInfo;
  bool _isLoading = false;

  final HomeService _homeService = HomeService();

  MoldRiskModel? get moldRisk => _moldRisk;
  WeatherModel? get weather => _weather;
  HomeInfoResponse? get homeInfo => _homeInfo;
  bool get isLoading => _isLoading;

  // 위험도 및 날씨 데이터 로드 (API 연동)
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // 단일 API 호출로 모든 데이터 가져오기
      _homeInfo = await _homeService.getHomeInfo();

      // 곰팡이 위험도 변환
      _moldRisk = _convertToMoldRiskModel(_homeInfo!);

      // 날씨 변환
      _weather = _convertToWeatherModel(_homeInfo!);

      debugPrint('[MoldRiskProvider] 데이터 로드 완료');

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[MoldRiskProvider] 데이터 로드 실패: $e');
      // 실패 시 더미 데이터 사용
      _moldRisk = MoldRiskModel.dummy();
      _weather = WeatherModel.dummy();
      _homeInfo = null;

      _isLoading = false;
      notifyListeners();
    }
  }

  // API 응답을 MoldRiskModel로 변환
  MoldRiskModel _convertToMoldRiskModel(HomeInfoResponse response) {
    final riskInfo = response.riskInfo;

    // 위험도 레벨 및 퍼센트 결정
    String riskLevel;
    int riskPercentage;

    if (riskInfo != null) {
      riskPercentage = riskInfo.percentage;

      if (riskPercentage <= 20) {
        riskLevel = 'safe';
      } else if (riskPercentage <= 40) {
        riskLevel = 'caution';
      } else if (riskPercentage <= 60) {
        riskLevel = 'warning';
      } else {
        riskLevel = 'danger';
      }
    } else {
      riskLevel = 'safe';
      riskPercentage = 20;
    }

    // 환기 추천 메시지 생성
    String recommendation;
    String? ventilationStart;
    String? ventilationEnd;

    if (response.ventilationTimes.isNotEmpty) {
      final firstVent = response.ventilationTimes.first;
      ventilationStart = firstVent.startTime;
      ventilationEnd = firstVent.endTime;
      recommendation = firstVent.description.isNotEmpty
          ? firstVent.description
          : '$ventilationStart ~ $ventilationEnd 사이에 환기를 추천해요!';
    } else {
      recommendation = riskInfo?.message ?? '환기 추천 정보가 없습니다.';
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
  WeatherModel _convertToWeatherModel(HomeInfoResponse response) {
    if (response.currentWeather.isEmpty) {
      return WeatherModel.dummy();
    }

    final weather = response.currentWeather.first;
    final temp = weather.temp;
    final humid = weather.humid.toInt();
    final rainProb = weather.rainProb;

    // 강수확률에 따른 날씨 상태 결정
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
      condition = weather.condition.isNotEmpty ? weather.condition : '맑음';
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

  // 새로고침
  Future<void> refresh() async {
    await loadData();
  }
}
