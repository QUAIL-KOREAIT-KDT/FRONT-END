import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 진단 결과 응답 모델
class DiagnosisResponse {
  final String moldName;
  final String code;
  final String solution;
  final String imageUrl;

  DiagnosisResponse({
    required this.moldName,
    required this.code,
    required this.solution,
    required this.imageUrl,
  });

  factory DiagnosisResponse.fromJson(Map<String, dynamic> json) {
    return DiagnosisResponse(
      moldName: json['mold_name'] ?? '',
      code: json['code'] ?? '',
      solution: json['solution'] ?? '',
      imageUrl: json['image_url'] ?? '',
    );
  }

  /// 더미 데이터
  static DiagnosisResponse dummy() {
    return DiagnosisResponse(
      moldName: 'Cladosporium (검은 곰팡이)',
      code: 'G1',
      solution: '락스 희석액을 사용하여 닦아내세요. 환기를 자주 시켜주세요.',
      imageUrl: 'https://example.com/mold.jpg',
    );
  }
}

/// 진단 API 서비스
class DiagnosisService {
  final ApiService _apiService = ApiService();

  /// 곰팡이 이미지 진단
  Future<DiagnosisResponse> predictMold(File imageFile) async {
    try {
      final fileName = imageFile.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      final response = await _apiService.dio.post(
        '/diagnosis/predict',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('[DiagnosisService] 진단 성공');
      return DiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[DiagnosisService] 진단 실패: ${e.response?.data}');
      debugPrint('[DiagnosisService] 더미 데이터 사용');
      return DiagnosisResponse.dummy();
    }
  }

  /// 웹용 - Uint8List로 이미지 진단
  Future<DiagnosisResponse> predictMoldFromBytes(Uint8List bytes, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiService.dio.post(
        '/diagnosis/predict',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      debugPrint('[DiagnosisService] 진단 성공 (웹)');
      return DiagnosisResponse.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('[DiagnosisService] 진단 실패 (웹): ${e.response?.data}');
      debugPrint('[DiagnosisService] 더미 데이터 사용');
      return DiagnosisResponse.dummy();
    }
  }
}
