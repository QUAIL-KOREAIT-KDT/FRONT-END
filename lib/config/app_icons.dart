import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 아이콘을 중앙 관리합니다.
/// 이모지 대신 Material Icons를 사용하여 일관된 디자인을 유지합니다.
class AppIcons {
  AppIcons._();

  // ─── 화면 타이틀 / 헤더 ───
  static const IconData fortune = Icons.science_rounded;
  static const IconData dictionary = Icons.menu_book_rounded;
  static const IconData diagnosis = Icons.biotech_rounded;
  static const IconData diagnosisResult = Icons.assignment_rounded;
  static const IconData iotSettings = Icons.router_rounded;
  static const IconData homeInfo = Icons.home_rounded;
  static const IconData diagnosisHistory = Icons.history_rounded;
  static const IconData detailModal = Icons.description_rounded;

  // ─── 섹션 아이콘 (진단결과 / 마이페이지) ───
  static const IconData sectionDiagnosis = Icons.biotech_rounded;
  static const IconData sectionLocation = Icons.location_on_rounded;
  static const IconData sectionSolution = Icons.lightbulb_rounded;
  static const IconData sectionPrevention = Icons.shield_rounded;
  static const IconData sectionAiAdvice = Icons.smart_toy_rounded;

  // ─── 폼 / 라벨 ───
  static const IconData person = Icons.person_rounded;
  static const IconData location = Icons.location_on_rounded;
  static const IconData home = Icons.home_rounded;
  static const IconData temperature = Icons.thermostat_rounded;
  static const IconData humidity = Icons.water_drop_rounded;
  static const IconData direction = Icons.explore_rounded;
  static const IconData camera = Icons.camera_alt_rounded;
  static const IconData gallery = Icons.photo_library_rounded;
}
