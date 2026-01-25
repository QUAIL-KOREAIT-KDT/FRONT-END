import 'package:flutter/material.dart';

class MoldInfoModel {
  final String id;
  final String type; // G1 ~ G7
  final String name;
  final String nameEn;
  final String description;
  final String color;
  final String characteristics;
  final List<String> commonLocations;
  final List<String> treatments;
  final List<String> preventions;
  final bool isMold; // G5, G6, G7은 곰팡이가 아님

  MoldInfoModel({
    required this.id,
    required this.type,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.color,
    required this.characteristics,
    required this.commonLocations,
    required this.treatments,
    required this.preventions,
    required this.isMold,
  });

  // 곰팡이 사전 더미 데이터
  static List<MoldInfoModel> getDummyList() {
    return [
      MoldInfoModel(
        id: '1',
        type: 'G1',
        name: '검은 곰팡이',
        nameEn: 'Black Mold',
        description: '가장 흔한 유형의 곰팡이로, 습한 벽면이나 창가에서 주로 발생합니다.',
        color: '검정색, 짙은 회색, 짙은 갈색',
        characteristics: '점박이(Spot), 얼룩덜룩한 패치, 그을음 형태',
        commonLocations: ['창가', '벽지', '욕실', '지하실'],
        treatments: [
          '곰팡이 제거제 분사 후 15분 방치',
          '부드러운 솔로 문질러 제거',
          '깨끗한 물로 헹군 후 건조',
        ],
        preventions: [
          '환기를 자주 해주세요',
          '습도를 60% 이하로 유지',
          '결로 발생 시 즉시 제거',
        ],
        isMold: true,
      ),
      MoldInfoModel(
        id: '2',
        type: 'G2',
        name: '푸른 곰팡이',
        nameEn: 'Green Mold (Penicillium)',
        description: '주로 음식물이나 습한 실내 환경에서 발생하는 페니실리움 종입니다.',
        color: '청록색, 녹색',
        characteristics: '보송보송한 질감, 원형으로 퍼져나감',
        commonLocations: ['음식물', '냉장고', '습한 실내', '가죽 제품'],
        treatments: [
          '오염된 음식은 즉시 폐기',
          '해당 부위 알코올 소독',
          '주변 청소 및 건조',
        ],
        preventions: [
          '음식물 보관 기간 준수',
          '냉장고 정기 청소',
          '습기 제거',
        ],
        isMold: true,
      ),
      MoldInfoModel(
        id: '3',
        type: 'G3',
        name: '흰 곰팡이',
        nameEn: 'White Mold',
        description: '음식물의 초기 균사체 형태로, 주로 흰색을 띕니다.',
        color: '흰색, 연한 회색',
        characteristics: '솜털 같은 질감, 초기 단계 곰팡이',
        commonLocations: ['음식물', '빵', '과일', '치즈'],
        treatments: [
          '오염된 음식 즉시 폐기',
          '보관 용기 세척 및 소독',
        ],
        preventions: [
          '음식물 밀폐 보관',
          '적정 온도 유지',
          '유통기한 확인',
        ],
        isMold: true,
      ),
      MoldInfoModel(
        id: '4',
        type: 'G4',
        name: '주황 곰팡이',
        nameEn: 'Orange Mold',
        description: '주로 욕실에서 발견되는 곰팡이입니다.',
        color: '주황색, 오렌지색',
        characteristics: '습한 환경에서 빠르게 번식',
        commonLocations: ['욕실', '샤워실', '타일 틈', '실리콘'],
        treatments: [
          '욕실 세제로 문질러 제거',
          '락스 희석액으로 소독',
          '충분히 건조',
        ],
        preventions: [
          '샤워 후 환기',
          '물기 제거',
          '실리콘 정기 교체',
        ],
        isMold: true,
      ),
      MoldInfoModel(
        id: '5',
        type: 'G5',
        name: '분홍 물때',
        nameEn: 'Pink Bacteria (Serratia marcescens)',
        description: '곰팡이가 아닌 세균성 물때입니다. 락스로 쉽게 제거됩니다.',
        color: '분홍색, 연한 빨간색',
        characteristics: '미끌미끌한 질감, 세균성',
        commonLocations: ['욕실', '세면대', '비누받침', '샤워커튼'],
        treatments: [
          '락스나 욕실 세제로 제거',
          '브러시로 문질러 닦기',
        ],
        preventions: [
          '자주 씻고 말려주기',
          '환기 자주 하기',
          '물기 제거',
        ],
        isMold: false,
      ),
      MoldInfoModel(
        id: '6',
        type: 'G6',
        name: '백화현상',
        nameEn: 'Efflorescence',
        description: '곰팡이가 아닌 염분 결정입니다. 백화가 보이면 곰팡이가 생길 조건이 갖춰진 것입니다.',
        color: '흰색',
        characteristics: '가루 같은 질감, 염분 결정',
        commonLocations: ['콘크리트 벽', '벽돌', '지하실'],
        treatments: [
          '마른 솔로 털어내기',
          '물로 닦고 건조',
          '방수 처리',
        ],
        preventions: [
          '방수 처리',
          '습기 차단',
          '환기',
        ],
        isMold: false,
      ),
    ];
  }

  // 타입별 배경 그라데이션 색상
  List<Color> get gradientColors {
    switch (type) {
      case 'G1':
        return [const Color(0xFF2D3436), const Color(0xFF636E72)];
      case 'G2':
        return [const Color(0xFF00B894), const Color(0xFF55EFC4)];
      case 'G3':
        return [const Color(0xFFDFE6E9), const Color(0xFFFFFFFF)];
      case 'G4':
        return [const Color(0xFFE17055), const Color(0xFFFAB1A0)];
      case 'G5':
        return [const Color(0xFFFD79A8), const Color(0xFFFDCB6E)];
      case 'G6':
        return [const Color(0xFFB2BEC3), const Color(0xFFDFE6E9)];
      default:
        return [const Color(0xFF636E72), const Color(0xFFB2BEC3)];
    }
  }

  String get emoji {
    switch (type) {
      case 'G5':
        return '🧫';
      case 'G6':
        return '⚪';
      default:
        return '🦠';
    }
  }
}
