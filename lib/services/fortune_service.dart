import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 운세 응답 모델
class FortuneResponse {
  final int score;
  final String status;
  final String message;

  FortuneResponse({
    required this.score,
    required this.status,
    required this.message,
  });

  factory FortuneResponse.fromJson(Map<String, dynamic> json) {
    return FortuneResponse(
      score: json['score'] ?? 0,
      status: json['status'] ?? '',
      message: json['message'] ?? '',
    );
  }

  /// 더미 데이터
  static FortuneResponse dummy() {
    return FortuneResponse(
      score: 85,
      status: '뽀송함',
      message: '오늘은 곰팡이 걱정 없는 날!',
    );
  }

  /// 점수에 따른 이모지
  String get emoji {
    if (score >= 80) return '😊';
    if (score >= 60) return '🙂';
    if (score >= 40) return '😐';
    if (score >= 20) return '😟';
    return '😰';
  }

  /// 점수에 따른 색상 (hex)
  int get colorValue {
    if (score >= 80) return 0xFF4CAF50; // green
    if (score >= 60) return 0xFF8BC34A; // light green
    if (score >= 40) return 0xFFFFC107; // amber
    if (score >= 20) return 0xFFFF9800; // orange
    return 0xFFF44336; // red
  }
}

/// 운세 API 서비스
class FortuneService {
  final ApiService _apiService = ApiService();

  /// 오늘의 팡이 운세 조회
  Future<FortuneResponse> getTodayFortune() async {
    try {
      final response = await _apiService.dio.get('/fortune/today');
      debugPrint('[FortuneService] 운세 조회 성공');
      return FortuneResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[FortuneService] 운세 조회 실패: ${e.response?.data}');
      debugPrint('[FortuneService] 더미 데이터 사용');
      return FortuneResponse.dummy();
    }
  }
}
