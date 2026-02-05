import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 진단 기록 썸네일 모델 (목록용)
class DiagnosisThumbnail {
  final int id;
  final String imagePath;
  final DateTime createdAt;
  final String result; // G1~G8 (백엔드가 목록에 포함시키면 사용)
  final String moldLocation; // 백엔드 enum 값

  DiagnosisThumbnail({
    required this.id,
    required this.imagePath,
    required this.createdAt,
    this.result = '',
    this.moldLocation = '',
  });

  factory DiagnosisThumbnail.fromJson(Map<String, dynamic> json) {
    return DiagnosisThumbnail(
      id: json['id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      result: json['result'] ?? '',
      moldLocation: json['mold_location'] ?? '',
    );
  }

  /// 장소 한글 변환
  String get locationKorean {
    const mapping = {
      'windows': '창가',
      'wallpaper': '벽지',
      'bathroom': '욕실',
      'ceiling': '천장',
      'kitchen': '주방',
      'food': '음식',
      'veranda': '베란다',
      'air_conditioner': '에어컨',
      'living_room': '거실',
      'sink': '싱크대',
      'toilet': '변기',
    };
    return mapping[moldLocation] ?? moldLocation;
  }

  /// 날짜 포맷 (yyyy.MM.dd HH:mm)
  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}

/// 진단 상세 정보 모델
class DiagnosisDetail {
  final int id;
  final int userId;
  final String result; // G1~G8
  final double confidence;
  final String imagePath;
  final String moldLocation;
  final DateTime createdAt;
  final String modelSolution;

  DiagnosisDetail({
    required this.id,
    required this.userId,
    required this.result,
    required this.confidence,
    required this.imagePath,
    required this.moldLocation,
    required this.createdAt,
    required this.modelSolution,
  });

  factory DiagnosisDetail.fromJson(Map<String, dynamic> json) {
    return DiagnosisDetail(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      result: json['result'] ?? '',
      confidence: (json['confidence'] ?? 0).toDouble(),
      imagePath: json['image_path'] ?? '',
      moldLocation: json['mold_location'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      modelSolution: json['model_solution'] is Map
          ? jsonEncode(json['model_solution'])
          : json['model_solution']?.toString() ?? '',
    );
  }

  /// 날짜 포맷 (yyyy.MM.dd HH:mm)
  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// 신뢰도 퍼센트
  int get confidencePercent => confidence.toInt();

  /// 장소 한글 변환
  String get locationKorean {
    const mapping = {
      'windows': '창가',
      'wallpaper': '벽지',
      'bathroom': '욕실',
      'ceiling': '천장',
      'kitchen': '주방',
      'food': '음식',
      'veranda': '베란다',
      'air_conditioner': '에어컨',
      'living_room': '거실',
      'sink': '싱크대',
      'toilet': '변기',
    };
    return mapping[moldLocation] ?? moldLocation;
  }
}

/// 마이페이지 API 서비스
class MyPageService {
  final ApiService _apiService = ApiService();

  /// 진단 기록 목록 조회
  Future<List<DiagnosisThumbnail>> getDiagnosisHistory() async {
    try {
      final response = await _apiService.dio.get('/my_page/diagnosis-history');
      debugPrint('[MyPageService] 진단 기록 목록 조회 성공');

      final List<dynamic> data = response.data;
      return data.map((e) => DiagnosisThumbnail.fromJson(e)).toList();
    } on DioException catch (e) {
      debugPrint('[MyPageService] 진단 기록 목록 조회 실패: ${e.response?.data}');
      rethrow;
    }
  }

  /// 진단 상세 정보 조회
  Future<DiagnosisDetail> getDiagnosisInfo(int id) async {
    try {
      final response = await _apiService.dio.post(
        '/my_page/diagnosis-info/',
        data: {'id': id},
      );
      debugPrint('[MyPageService] 진단 상세 조회 성공');
      return DiagnosisDetail.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[MyPageService] 진단 상세 조회 실패: ${e.response?.data}');
      rethrow;
    }
  }

  /// 진단 기록 삭제
  Future<bool> deleteDiagnosis(int id) async {
    try {
      await _apiService.dio.delete(
        '/my_page/delete-diagnosis/',
        data: {'id': id},
      );
      debugPrint('[MyPageService] 진단 기록 삭제 성공');
      return true;
    } on DioException catch (e) {
      debugPrint('[MyPageService] 진단 기록 삭제 실패: ${e.response?.data}');
      return false;
    }
  }
}
