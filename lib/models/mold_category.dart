import 'package:flutter/material.dart';

/// 곰팡이 대분류 (검은 곰팡이, 푸른 곰팡이 등)
class MoldCategory {
  final String id;
  final String name;
  final String description;
  final List<Color> gradientColors;
  final String emoji;
  final List<MoldSubType> subTypes;

  MoldCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.gradientColors,
    required this.emoji,
    required this.subTypes,
  });

  static List<MoldCategory> getCategories() {
    return [
      MoldCategory(
        id: 'black',
        name: '검은 곰팡이',
        description: '가장 흔한 유형, 습한 벽면에 발생',
        gradientColors: [const Color(0xFF2D3436), const Color(0xFF636E72)],
        emoji: '🦠',
        subTypes: MoldSubType.getBlackMolds(),
      ),
      MoldCategory(
        id: 'green',
        name: '푸른 곰팡이',
        description: '음식물, 습한 실내에서 발생',
        gradientColors: [const Color(0xFF00B894), const Color(0xFF55EFC4)],
        emoji: '🦠',
        subTypes: MoldSubType.getGreenMolds(),
      ),
      MoldCategory(
        id: 'white',
        name: '흰 곰팡이',
        description: '초기 균사체 형태, 음식물',
        gradientColors: [const Color(0xFFDFE6E9), const Color(0xFFFFFFFF)],
        emoji: '🦠',
        subTypes: MoldSubType.getWhiteMolds(),
      ),
      MoldCategory(
        id: 'orange',
        name: '주황 곰팡이',
        description: '주로 욕실에서 발견',
        gradientColors: [const Color(0xFFE17055), const Color(0xFFFAB1A0)],
        emoji: '🦠',
        subTypes: MoldSubType.getOrangeMolds(),
      ),
      MoldCategory(
        id: 'pink',
        name: '분홍 물때',
        description: '세균성, 락스로 제거 가능',
        gradientColors: [const Color(0xFFFD79A8), const Color(0xFFFDCB6E)],
        emoji: '🧫',
        subTypes: [],
      ),
      MoldCategory(
        id: 'efflorescence',
        name: '백화현상',
        description: '곰팡이 발생 전조 현상',
        gradientColors: [const Color(0xFFB2BEC3), const Color(0xFFDFE6E9)],
        emoji: '⚪',
        subTypes: [],
      ),
    ];
  }
}

/// 곰팡이 세부 종류 (Spot 곰팡이, Cladosporium 등)
class MoldSubType {
  final String id;
  final String name;
  final String scientificName;
  final String shortDescription;
  final String fullDescription;
  final String color;
  final String characteristics;
  final List<String> commonLocations;
  final List<String> healthRisks;
  final List<String> removalMethods;
  final List<String> preventions;
  final List<Color> gradientColors;

  MoldSubType({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.shortDescription,
    required this.fullDescription,
    required this.color,
    required this.characteristics,
    required this.commonLocations,
    required this.healthRisks,
    required this.removalMethods,
    required this.preventions,
    required this.gradientColors,
  });

  /// 검은 곰팡이 세부 종류 (4개)
  static List<MoldSubType> getBlackMolds() {
    return [
      MoldSubType(
        id: 'spot',
        name: 'Spot 곰팡이',
        scientificName: 'Stachybotrys chartarum',
        shortDescription: '벽면에 점박이 형태로 발생',
        fullDescription:
            '습한 벽면이나 천장에 작은 점 형태로 시작하여 점차 퍼져나가는 곰팡이입니다. 주로 결로가 발생하는 창가나 욕실 주변에서 발견됩니다.',
        color: '검정색, 짙은 회색',
        characteristics: '점박이(Spot) 형태, 점차 원형으로 확산',
        commonLocations: ['창가', '욕실 천장', '베란다', '지하실'],
        healthRisks: ['호흡기 자극', '알레르기 반응', '두통'],
        removalMethods: [
          '곰팡이 제거제 분사 후 15분 방치',
          '부드러운 솔로 문질러 제거',
          '깨끗한 물로 헹군 후 완전 건조',
        ],
        preventions: ['환기를 자주 해주세요', '습도 60% 이하 유지', '결로 발생 시 즉시 제거'],
        gradientColors: [const Color(0xFF2D3436), const Color(0xFF636E72)],
      ),
      MoldSubType(
        id: 'cladosporium',
        name: 'Cladosporium',
        scientificName: 'Cladosporium cladosporioides',
        shortDescription: '실내외 가장 흔한 곰팡이',
        fullDescription:
            '전 세계적으로 가장 흔하게 발견되는 곰팡이 중 하나입니다. 실내외 모두에서 발견되며, 특히 욕실이나 에어컨 필터에서 자주 발견됩니다.',
        color: '올리브 녹색 ~ 검은색',
        characteristics: '벨벳 같은 질감, 불규칙한 패턴',
        commonLocations: ['에어컨 필터', '욕실', '창틀', '카펫'],
        healthRisks: ['천식 악화', '알레르기성 비염', '피부 자극'],
        removalMethods: [
          '해당 부위 알코올 소독',
          '에어컨 필터 정기 교체',
          '전문 청소 서비스 이용',
        ],
        preventions: ['에어컨 필터 정기 청소', '실내 습도 관리', '정기적인 환기'],
        gradientColors: [const Color(0xFF2D3436), const Color(0xFF4A5568)],
      ),
      MoldSubType(
        id: 'alternaria',
        name: 'Alternaria',
        scientificName: 'Alternaria alternata',
        shortDescription: '알레르기 유발 대표 곰팡이',
        fullDescription:
            '알레르기를 유발하는 대표적인 곰팡이로, 습한 환경에서 빠르게 번식합니다. 특히 샤워실이나 싱크대 주변에서 자주 발견됩니다.',
        color: '검은색 ~ 짙은 갈색',
        characteristics: '솜털 같은 질감, 동심원 패턴',
        commonLocations: ['샤워실', '싱크대', '창문 실리콘', '화분'],
        healthRisks: ['심한 알레르기 반응', '천식 발작', '눈 자극'],
        removalMethods: [
          '락스 희석액으로 소독',
          '실리콘 부위는 교체 권장',
          '마스크 착용 후 제거 작업',
        ],
        preventions: ['샤워 후 환기 필수', '물기 즉시 제거', '실리콘 정기 점검'],
        gradientColors: [const Color(0xFF1A1A2E), const Color(0xFF4A4A6A)],
      ),
      MoldSubType(
        id: 'aspergillus_niger',
        name: 'Aspergillus Niger',
        scientificName: 'Aspergillus niger',
        shortDescription: '검은 누룩곰팡이',
        fullDescription:
            '검은 누룩곰팡이로 알려진 종으로, 습한 벽지나 타일 틈에서 발견됩니다. 독소를 생성할 수 있어 주의가 필요합니다.',
        color: '검은색, 진한 갈색',
        characteristics: '가루 같은 포자, 원형 군락',
        commonLocations: ['벽지', '타일 틈', '욕실 코너', '지하실'],
        healthRisks: ['폐 감염 위험', '면역력 저하자 주의', '독소 생성 가능'],
        removalMethods: [
          '전문 곰팡이 제거제 사용',
          '심한 경우 전문가 상담',
          '오염된 벽지는 교체 권장',
        ],
        preventions: ['벽지 뒤 습기 확인', '방수 처리', '제습기 사용'],
        gradientColors: [const Color(0xFF0D0D0D), const Color(0xFF3D3D3D)],
      ),
    ];
  }

  /// 푸른 곰팡이 세부 종류 (4개)
  static List<MoldSubType> getGreenMolds() {
    return [
      MoldSubType(
        id: 'penicillium',
        name: 'Penicillium',
        scientificName: 'Penicillium chrysogenum',
        shortDescription: '페니실린 유래 곰팡이',
        fullDescription: '항생제 페니실린을 생산하는 곰팡이로 유명합니다. 음식물이나 습한 실내에서 흔히 발견됩니다.',
        color: '청록색, 녹색',
        characteristics: '보송보송한 질감, 원형 확산',
        commonLocations: ['음식물', '냉장고', '가죽 제품', '습한 실내'],
        healthRisks: ['알레르기 반응', '호흡기 자극'],
        removalMethods: ['오염된 음식 즉시 폐기', '해당 부위 알코올 소독'],
        preventions: ['음식물 보관 기간 준수', '냉장고 정기 청소'],
        gradientColors: [const Color(0xFF00B894), const Color(0xFF55EFC4)],
      ),
      MoldSubType(
        id: 'aspergillus_flavus',
        name: 'Aspergillus Flavus',
        scientificName: 'Aspergillus flavus',
        shortDescription: '식품 오염 곰팡이',
        fullDescription: '곡물이나 견과류에서 발견되며, 아플라톡신이라는 독소를 생성할 수 있습니다.',
        color: '황록색',
        characteristics: '가루 같은 질감, 동심원 패턴',
        commonLocations: ['곡물', '견과류', '향신료'],
        healthRisks: ['아플라톡신 독소', '간 손상 위험'],
        removalMethods: ['오염된 식품 폐기', '보관 용기 소독'],
        preventions: ['식품 건조 보관', '밀폐 용기 사용'],
        gradientColors: [const Color(0xFF00CEC9), const Color(0xFF81ECEC)],
      ),
      MoldSubType(
        id: 'trichoderma',
        name: 'Trichoderma',
        scientificName: 'Trichoderma viride',
        shortDescription: '목재 부패 곰팡이',
        fullDescription: '습한 목재나 종이에서 자라며, 녹색 포자를 형성합니다.',
        color: '밝은 녹색',
        characteristics: '빠른 성장, 녹색 포자',
        commonLocations: ['목재', '종이', '젖은 벽지'],
        healthRisks: ['알레르기 반응', '호흡기 자극'],
        removalMethods: ['목재 건조', '곰팡이 제거제 사용'],
        preventions: ['목재 방습 처리', '습기 관리'],
        gradientColors: [const Color(0xFF26DE81), const Color(0xFF7BED9F)],
      ),
      MoldSubType(
        id: 'fusarium',
        name: 'Fusarium',
        scientificName: 'Fusarium oxysporum',
        shortDescription: '식물 병원균',
        fullDescription: '주로 식물에 감염되지만, 실내 화분에서 발견될 수 있습니다.',
        color: '분홍빛 녹색',
        characteristics: '솜털 같은 균사',
        commonLocations: ['화분', '식물', '습한 토양'],
        healthRisks: ['면역력 저하자 감염 위험'],
        removalMethods: ['감염된 토양 교체', '화분 소독'],
        preventions: ['화분 과습 방지', '통풍 유지'],
        gradientColors: [const Color(0xFF1ABC9C), const Color(0xFF48DBFB)],
      ),
    ];
  }

  /// 흰 곰팡이 세부 종류
  static List<MoldSubType> getWhiteMolds() {
    return [
      MoldSubType(
        id: 'mucor',
        name: 'Mucor',
        scientificName: 'Mucor mucedo',
        shortDescription: '빵 곰팡이',
        fullDescription: '빵이나 과일에서 흔히 발견되는 흰색 곰팡이입니다.',
        color: '흰색, 연한 회색',
        characteristics: '솜털 같은 질감, 빠른 성장',
        commonLocations: ['빵', '과일', '치즈'],
        healthRisks: ['알레르기 반응'],
        removalMethods: ['오염된 음식 폐기'],
        preventions: ['음식 밀폐 보관', '적정 온도 유지'],
        gradientColors: [const Color(0xFFDFE6E9), const Color(0xFFFFFFFF)],
      ),
    ];
  }

  /// 주황 곰팡이 세부 종류
  static List<MoldSubType> getOrangeMolds() {
    return [
      MoldSubType(
        id: 'fuligo',
        name: 'Fuligo septica',
        scientificName: 'Fuligo septica',
        shortDescription: '개구리알 곰팡이',
        fullDescription: '습한 나무나 정원에서 발견되며, 주황색~노란색을 띕니다.',
        color: '주황색, 노란색',
        characteristics: '점액질 형태',
        commonLocations: ['정원', '습한 나무', '멀치'],
        healthRisks: ['일반적으로 무해'],
        removalMethods: ['물리적 제거', '건조'],
        preventions: ['정원 습기 관리'],
        gradientColors: [const Color(0xFFE17055), const Color(0xFFFAB1A0)],
      ),
    ];
  }
}
