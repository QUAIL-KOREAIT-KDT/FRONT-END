import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 날씨 상세 정보 모델
class WeatherDetail {
  final String time;
  final double temp;
  final double humid;
  final int rainProb;
  final String condition;

  WeatherDetail({
    required this.time,
    required this.temp,
    required this.humid,
    required this.rainProb,
    required this.condition,
  });

  factory WeatherDetail.fromJson(Map<String, dynamic> json) {
    return WeatherDetail(
      time: json['time'] ?? '',
      temp: (json['temp'] ?? 0).toDouble(),
      humid: (json['humid'] ?? 0).toDouble(),
      rainProb: json['rain_prob'] ?? 0,
      condition: json['condition'] ?? '',
    );
  }
}

/// 환기 추천 시간 모델
class VentilationTime {
  final String date;
  final String startTime;
  final String endTime;
  final String description;

  VentilationTime({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.description,
  });

  factory VentilationTime.fromJson(Map<String, dynamic> json) {
    return VentilationTime(
      date: json['date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

/// 단일 시점 곰팡이 위험도 아이템 (백엔드 MoldRiskItem 대응)
class MoldRiskItem {
  final String time;      // "13:00"
  final double score;     // 0.0 ~ 100.0
  final String level;     // "SAFE" | "WARNING" | "DANGER"
  final String type;      // "MAX" | "MIN" | "CURRENT"
  final String message;
  final double tempUsed;
  final double humidUsed;

  MoldRiskItem({
    required this.time,
    required this.score,
    required this.level,
    required this.type,
    required this.message,
    required this.tempUsed,
    required this.humidUsed,
  });

  factory MoldRiskItem.fromJson(Map<String, dynamic> json) {
    return MoldRiskItem(
      time: json['time'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      level: json['level'] ?? 'SAFE',
      type: json['type'] ?? 'CURRENT',
      message: json['message'] ?? '',
      tempUsed: (json['temp_used'] ?? 0).toDouble(),
      humidUsed: (json['humid_used'] ?? 0).toDouble(),
    );
  }

  /// 위험도 퍼센트 (0~100)
  int get percentage => score.clamp(0, 100).toInt();
}

/// 홈 화면 정보 응답 모델
class HomeInfoResponse {
  final String regionAddress;
  final List<WeatherDetail> currentWeather;
  final List<VentilationTime> ventilationTimes;
  final List<MoldRiskItem> riskForecast;

  HomeInfoResponse({
    required this.regionAddress,
    required this.currentWeather,
    required this.ventilationTimes,
    required this.riskForecast,
  });

  factory HomeInfoResponse.fromJson(Map<String, dynamic> json) {
    return HomeInfoResponse(
      regionAddress: json['region_address'] ?? '',
      currentWeather: (json['current_weather'] as List<dynamic>?)
              ?.map((e) => WeatherDetail.fromJson(e))
              .toList() ??
          [],
      ventilationTimes: (json['ventilation_times'] as List<dynamic>?)
              ?.map((e) => VentilationTime.fromJson(e))
              .toList() ??
          [],
      riskForecast: (json['risk_forecast'] as List<dynamic>?)
              ?.map((e) => MoldRiskItem.fromJson(e))
              .toList() ??
          [],
    );
  }

  /// 실시간 위험도 (CURRENT)
  MoldRiskItem? get currentRisk =>
      riskForecast.where((e) => e.type == 'CURRENT').firstOrNull;

  /// 당일 최고 위험도 (MAX)
  MoldRiskItem? get maxRisk =>
      riskForecast.where((e) => e.type == 'MAX').firstOrNull;

  /// 당일 최저 위험도 (MIN)
  MoldRiskItem? get minRisk =>
      riskForecast.where((e) => e.type == 'MIN').firstOrNull;

  /// 현재 시간대의 날씨 정보
  WeatherDetail? get currentHourWeather {
    if (currentWeather.isEmpty) return null;
    return currentWeather.first;
  }

  /// 환기 가능 여부
  bool get canVentilate => ventilationTimes.isNotEmpty;

  /// 환기 추천 메시지
  String get ventilationMessage {
    if (canVentilate) {
      final first = ventilationTimes.first;
      return '${first.startTime} ~ ${first.endTime} 환기 추천';
    }
    return '오늘 환기는 곰팡이한테 주세요 🍄';
  }
}

/// 홈 API 서비스 (곰팡이 위험도, 날씨, 환기 정보)
class HomeService {
  final ApiService _apiService = ApiService();

  /// 홈 화면 정보 조회 (통합 API)
  Future<HomeInfoResponse> getHomeInfo() async {
    try {
      final response = await _apiService.dio.get('/home/info');
      debugPrint('[HomeService] 홈 정보 조회 성공');
      return HomeInfoResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] 홈 정보 조회 실패: ${e.response?.data}');
      rethrow;
    }
  }
}
