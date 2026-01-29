import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_service.dart';
import '../models/mold_category.dart';

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

  /// name 필드에서 한글명 추출
  /// "스타키보트리스 (Stachybotrys chartarum)" → "스타키보트리스"
  String get koreanName {
    final idx = name.indexOf('(');
    if (idx > 0) return name.substring(0, idx).trim();
    return name.trim();
  }

  /// name 필드에서 학명 추출
  /// "스타키보트리스 (Stachybotrys chartarum)" → "Stachybotrys chartarum"
  String get scientificName {
    final match = RegExp(r'\((.+)\)').firstMatch(name);
    if (match != null) return match.group(1)!.trim();
    return name.trim();
  }

  /// feature 필드를 파싱하여 Map으로 반환
  /// "색상: 짙은 검은색\t외형: 젖으면 끈적...\t서식환경: ...\t유해정보: ..."
  Map<String, String> get _parsedFeatures {
    final map = <String, String>{};
    final parts = feature.split('\t');
    for (final part in parts) {
      final trimmed = part.trim();
      final colonIdx = trimmed.indexOf(':');
      if (colonIdx > 0) {
        final key = trimmed.substring(0, colonIdx).trim();
        final value = trimmed.substring(colonIdx + 1).trim();
        map[key] = value;
      }
    }
    return map;
  }

  String get colorInfo => _parsedFeatures['색상'] ?? '';
  String get appearance => _parsedFeatures['외형'] ?? '';
  String get environment => _parsedFeatures['서식환경'] ?? '';
  String get harmInfo => _parsedFeatures['유해정보'] ?? '';

  /// DictionaryResponse → MoldSubType 변환
  MoldSubType toMoldSubType() {
    final features = _parsedFeatures;
    final colorStr = features['색상'] ?? '';
    final appearanceStr = features['외형'] ?? '';
    final envStr = features['서식환경'] ?? '';
    final harmStr = features['유해정보'] ?? '';

    // 건강 영향: 쉼표로 분리
    final healthRisks = harmStr.isNotEmpty
        ? harmStr.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    // 발생 장소: 쉼표로 분리
    final locations = location.isNotEmpty
        ? location.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    // 제거 방법: \t로 분리
    final removals = solution.isNotEmpty
        ? solution.split('\t').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    // 예방법: \t로 분리
    final preventions = preventive.isNotEmpty
        ? preventive.split('\t').map((e) => e.trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    // 전체 설명 조합
    final descParts = <String>[];
    if (envStr.isNotEmpty) descParts.add('서식환경: $envStr');
    if (colorStr.isNotEmpty) descParts.add('색상: $colorStr');
    if (appearanceStr.isNotEmpty) descParts.add('외형: $appearanceStr');
    if (harmStr.isNotEmpty) descParts.add('유해정보: $harmStr');
    final fullDesc = descParts.join('\n');

    return MoldSubType(
      id: 'api_$id',
      name: koreanName,
      scientificName: scientificName,
      shortDescription: envStr.isNotEmpty ? envStr : (appearanceStr.isNotEmpty ? appearanceStr : feature),
      fullDescription: fullDesc,
      color: colorStr,
      characteristics: appearanceStr,
      commonLocations: locations,
      healthRisks: healthRisks,
      removalMethods: removals,
      preventions: preventions,
      gradientColors: _labelGradientColors(label),
    );
  }

  /// label별 그라데이션 색상
  static List<Color> _labelGradientColors(String label) {
    switch (label) {
      case 'G1':
        return [const Color(0xFF2D3436), const Color(0xFF636E72)];
      case 'G2':
        return [const Color(0xFF00B894), const Color(0xFF55EFC4)];
      case 'G3':
        return [const Color(0xFFDFE6E9), const Color(0xFFFFFFFF)];
      case 'G4':
        return [const Color(0xFFE17055), const Color(0xFFFAB1A0)];
      case 'G5':
        return [const Color(0xFFB2BEC3), const Color(0xFFDFE6E9)];
      default:
        return [const Color(0xFF636E72), const Color(0xFFB2BEC3)];
    }
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
