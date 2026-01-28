import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';

/// 곰팡이 도감 응답 모델
class DictionaryResponse {
  final int id;
  final String label;
  final String name;
  final String feature;
  final String location;
  final String imagePath;
  final String detailImagePath;
  final String solution;
  final String preventive;

  DictionaryResponse({
    required this.id,
    required this.label,
    required this.name,
    required this.feature,
    required this.location,
    required this.imagePath,
    required this.detailImagePath,
    required this.solution,
    required this.preventive,
  });

  factory DictionaryResponse.fromJson(Map<String, dynamic> json) {
    return DictionaryResponse(
      id: json['id'] ?? 0,
      label: json['label'] ?? '',
      name: json['name'] ?? '',
      feature: json['feature'] ?? '',
      location: json['location'] ?? '',
      imagePath: json['image_path'] ?? '',
      detailImagePath: json['detail_image_path'] ?? '',
      solution: json['solution'] ?? '',
      preventive: json['preventive'] ?? '',
    );
  }

  /// 더미 데이터 목록
  static List<DictionaryResponse> dummyList() {
    return [
      DictionaryResponse(
        id: 1,
        label: 'G1',
        name: 'Cladosporium (클라도스포리움)',
        feature: '검은색 또는 올리브색의 곰팡이로, 가장 흔하게 발견됩니다.',
        location: '창문, 욕실, 벽지',
        imagePath: '/static/images/G1_Cladosporium.jpg',
        detailImagePath: '/static/images/G1_Cladosporium_detail.jpg',
        solution: '락스 희석액으로 닦아내고, 환기를 자주 시켜주세요.',
        preventive: '습도를 60% 이하로 유지하고, 환기를 자주 해주세요.',
      ),
      DictionaryResponse(
        id: 2,
        label: 'G2',
        name: 'Penicillium (페니실리움)',
        feature: '청록색 또는 파란색의 곰팡이로, 음식에서 자주 발견됩니다.',
        location: '음식, 냉장고, 습한 곳',
        imagePath: '/static/images/G2_Penicillium.jpg',
        detailImagePath: '/static/images/G2_Penicillium.jpg',
        solution: '감염된 음식은 버리고, 주변을 깨끗이 청소하세요.',
        preventive: '음식을 밀봉 보관하고, 냉장고를 정기적으로 청소하세요.',
      ),
      DictionaryResponse(
        id: 3,
        label: 'G3',
        name: 'Aspergillus (아스페르길루스)',
        feature: '노란색, 녹색, 검은색 등 다양한 색상의 곰팡이입니다.',
        location: '욕실, 주방, 에어컨',
        imagePath: '/static/images/G3_Mucor.png',
        detailImagePath: '/static/images/G3_Mucor.png',
        solution: '전문 곰팡이 제거제를 사용하고, 심한 경우 전문가에게 의뢰하세요.',
        preventive: '환기와 제습을 철저히 하고, 에어컨 필터를 정기적으로 청소하세요.',
      ),
      DictionaryResponse(
        id: 4,
        label: 'G4',
        name: 'Stachybotrys (스타키보트리스)',
        feature: '검은색의 독성 곰팡이로, 습한 환경에서 자랍니다.',
        location: '벽지, 천장, 바닥',
        imagePath: '/static/images/G1_Stachybotrys.jpg',
        detailImagePath: '/static/images/G1_Stachybotrys_detail.jpg',
        solution: '전문가에게 제거를 의뢰하세요. 직접 제거 시 보호장비를 착용하세요.',
        preventive: '누수를 즉시 수리하고, 습도 관리를 철저히 하세요.',
      ),
    ];
  }
}

/// 도감 API 서비스
class DictionaryService {
  final ApiService _apiService = ApiService();

  /// 곰팡이 도감 목록 조회
  Future<List<DictionaryResponse>> getDictionaryList() async {
    try {
      final response = await _apiService.dio.get('/dictionary/list');
      debugPrint('[DictionaryService] 도감 목록 조회 성공');

      final List<dynamic> data = response.data;
      return data.map((json) => DictionaryResponse.fromJson(json)).toList();
    } on DioException catch (e) {
      debugPrint('[DictionaryService] 도감 목록 조회 실패: ${e.response?.data}');
      debugPrint('[DictionaryService] 더미 데이터 사용');
      return DictionaryResponse.dummyList();
    }
  }
}
