import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 곰팡이 위험도 응답 모델
class MoldRiskResponse {
  final String date;
  final int temp;
  final int humid;
  final String moldIndex;

  MoldRiskResponse({
    required this.date,
    required this.temp,
    required this.humid,
    required this.moldIndex,
  });

  factory MoldRiskResponse.fromJson(Map<String, dynamic> json) {
    return MoldRiskResponse(
      date: json['date'] ?? '',
      temp: json['temp'] ?? 0,
      humid: json['humid'] ?? 0,
      moldIndex: json['mold_index'] ?? '알 수 없음',
    );
  }

  /// 더미 데이터
  static MoldRiskResponse dummy() {
    return MoldRiskResponse(
      date: '20260127 1200',
      temp: 18,
      humid: 65,
      moldIndex: '양호',
    );
  }
}

/// 날씨 응답 모델
class WeatherResponse {
  final String date;
  final String region;
  final String temp;
  final String humid;
  final String dewPoint;
  final String pp;
  final String moldIndex;

  WeatherResponse({
    required this.date,
    required this.region,
    required this.temp,
    required this.humid,
    required this.dewPoint,
    required this.pp,
    required this.moldIndex,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      date: json['date'] ?? '',
      region: json['region'] ?? '',
      temp: json['temp']?.toString() ?? '0',
      humid: json['humid']?.toString() ?? '0',
      dewPoint: json['dew_point']?.toString() ?? '0',
      pp: json['PP']?.toString() ?? '0',
      moldIndex: json['mold_index']?.toString() ?? '0',
    );
  }

  /// 더미 데이터
  static WeatherResponse dummy() {
    return WeatherResponse(
      date: '20260127 1200',
      region: '서울',
      temp: '18',
      humid: '65',
      dewPoint: '10',
      pp: '10',
      moldIndex: '35',
    );
  }
}

/// 환기 추천 응답 모델
class RefreshResponse {
  final String region;
  final List<String> dateList;

  RefreshResponse({
    required this.region,
    required this.dateList,
  });

  factory RefreshResponse.fromJson(Map<String, dynamic> json) {
    return RefreshResponse(
      region: json['region'] ?? '',
      dateList: (json['date_list'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  /// 더미 데이터
  static RefreshResponse dummy() {
    return RefreshResponse(
      region: '서울',
      dateList: ['20260127 1300', '20260127 1400', '20260127 1500'],
    );
  }

  /// 환기 가능 여부
  bool get canRefresh => dateList.isNotEmpty;

  /// 환기 추천 메시지
  String get message {
    if (canRefresh) {
      return '환기 추천 시간: ${dateList.length}개 구간';
    }
    return '오늘 환기는 곰팡이한테 주세요 🍄';
  }
}

/// 홈 API 서비스 (곰팡이 위험도, 날씨, 환기 정보)
class HomeService {
  final ApiService _apiService = ApiService();

  /// 당일 곰팡이 위험도 조회
  Future<MoldRiskResponse> getMoldRisk() async {
    try {
      final response = await _apiService.dio.get('/home/molddate');
      debugPrint('[HomeService] 곰팡이 위험도 조회 성공');
      return MoldRiskResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] 곰팡이 위험도 조회 실패: ${e.response?.data}');
      debugPrint('[HomeService] 더미 데이터 사용');
      return MoldRiskResponse.dummy();
    }
  }

  /// 오늘 날씨 조회
  Future<WeatherResponse> getWeather() async {
    try {
      final response = await _apiService.dio.get('/home/weather');
      debugPrint('[HomeService] 날씨 조회 성공');
      return WeatherResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] 날씨 조회 실패: ${e.response?.data}');
      debugPrint('[HomeService] 더미 데이터 사용');
      return WeatherResponse.dummy();
    }
  }

  /// 환기 추천 시간 조회
  Future<RefreshResponse> getRefreshInfo() async {
    try {
      final response = await _apiService.dio.get('/home/refresh');
      debugPrint('[HomeService] 환기 정보 조회 성공');
      return RefreshResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[HomeService] 환기 정보 조회 실패: ${e.response?.data}');
      debugPrint('[HomeService] 더미 데이터 사용');
      return RefreshResponse.dummy();
    }
  }
}
