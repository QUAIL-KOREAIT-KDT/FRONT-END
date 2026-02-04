import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 장소 매핑 (한글 -> 백엔드 enum)
const Map<String, String> locationToApiValue = {
  '창가': 'windows',
  '벽지': 'wallpaper',
  '욕실': 'bathroom',
  '천장': 'ceiling',
  '주방': 'kitchen',
  '음식': 'food',
  '베란다': 'veranda',
  '에어컨': 'air_conditioner',
  '거실': 'living_room',
  '싱크대': 'sink',
  '변기': 'toilet',
  '기타': 'living_room', // 기타는 거실로 매핑
};

/// 진단 결과 응답 모델 (백엔드 DiagnosisResponse와 일치)
class DiagnosisResponse {
  final int id;
  final String result; // G1~G8
  final double confidence;
  final String imagePath;
  final String moldLocation;
  final DateTime createdAt;
  final String modelSolution;

  DiagnosisResponse({
    required this.id,
    required this.result,
    required this.confidence,
    required this.imagePath,
    required this.moldLocation,
    required this.createdAt,
    required this.modelSolution,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      id: json['id'] ?? 0,
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

  /// 곰팡이 등급 (G1~G8)
  String get grade => result;

  /// 신뢰도 퍼센트
  int get confidencePercent => (confidence * 100).toInt();
}

/// 진단 API 서비스
class DiagnosisService {
  final ApiService _apiService = ApiService();

  /// 곰팡이 이미지 진단 (place 파라미터 필수)
  Future<DiagnosisResponse> predictMold(File imageFile, String place) async {
    try {
      final fileName = imageFile.path.split(Platform.pathSeparator).last;

      // 한글 장소명을 백엔드 enum 값으로 변환
      final apiPlace = locationToApiValue[place] ?? place;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
        'place': apiPlace,
      });

      final response = await _apiService.dio.post(
        '/diagnosis/predict',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 60), // 이미지 진단은 시간이 오래 걸림
          sendTimeout: const Duration(seconds: 30), // 이미지 업로드 시간
        ),
      );

      debugPrint('[DiagnosisService] 진단 성공');
      return DiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[DiagnosisService] 진단 실패: ${e.response?.data}');
      rethrow;
    }
  }

  /// 웹용 - Uint8List로 이미지 진단
  Future<DiagnosisResponse> predictMoldFromBytes(
    Uint8List bytes,
    String fileName,
    String place,
  ) async {
    try {
      // 한글 장소명을 백엔드 enum 값으로 변환
      final apiPlace = locationToApiValue[place] ?? place;

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
        'place': apiPlace,
      });

      final response = await _apiService.dio.post(
        '/diagnosis/predict',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          receiveTimeout: const Duration(seconds: 60), // 이미지 진단은 시간이 오래 걸림
          sendTimeout: const Duration(seconds: 30), // 이미지 업로드 시간
        ),
      );

      debugPrint('[DiagnosisService] 진단 성공 (웹)');
      return DiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[DiagnosisService] 진단 실패 (웹): ${e.response?.data}');
      rethrow;
    }
  }
}
