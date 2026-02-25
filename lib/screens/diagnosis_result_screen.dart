import 'package:flutter/material.dart';
import 'dart:convert';
import '../config/theme.dart';
import '../services/diagnosis_service.dart';

/// RAG 솔루션 파싱 모델
class RagSolution {
  final String diagnosis;
  final List<String> frequentlyVisitedAreas;
  final List<String> solutions;
  final List<String> preventions;
  final String insight;

  RagSolution({
    required this.diagnosis,
    required this.frequentlyVisitedAreas,
    required this.solutions,
    required this.preventions,
    required this.insight,
  });

  factory RagSolution.fromJson(Map<String, dynamic> json) {
    return RagSolution(
      diagnosis: json['diagnosis'] ?? '',
      frequentlyVisitedAreas:
          List<String>.from(json['FrequentlyVisitedAreas'] ?? []),
      solutions: List<String>.from(json['solution'] ?? []),
      preventions: List<String>.from(json['prevention'] ?? []),
      insight: json['insight'] ?? '',
    );
  }

  /// 문자열 또는 Map에서 파싱 (JSON 또는 일반 텍스트)
  static RagSolution parse(dynamic input) {
    try {
      // 이미 Map으로 파싱된 경우 (Dio가 자동 decode한 경우)
      if (input is Map<String, dynamic>) {
        return RagSolution.fromJson(input);
      }

      final text = input.toString();
      final json = jsonDecode(text);
      return RagSolution.fromJson(json);
    } catch (e) {
      // JSON이 아닌 경우 일반 텍스트로 처리
      final text = input.toString();
      return RagSolution(
        diagnosis: text,
        frequentlyVisitedAreas: [],
        solutions: text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
        preventions: [],
        insight: '',
      );
    }
  }
}

class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 전달받은 DiagnosisResponse 가져오기
    final args = ModalRoute.of(context)?.settings.arguments;
    final DiagnosisResponse? diagnosis =
        args is DiagnosisResponse ? args : null;

    if (diagnosis == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('진단 결과')),
        body: const Center(child: Text('진단 결과를 불러올 수 없습니다.')),
      );
    }

    // RAG 솔루션 파싱
    final ragSolution = RagSolution.parse(diagnosis.modelSolution);

    // 장소 한글 변환
    final locationKorean = _getLocationKorean(diagnosis.moldLocation);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.gray100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppTheme.gray700,
                size: 28,
              ),
            ),
          ),
        ),
        title: const Text(
          '📋 진단 결과',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 이미지 영역 (CAM 이미지 우선, 없으면 원본)
            Container(
              margin: const EdgeInsets.all(20),
              height: 340,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: diagnosis.displayImagePath.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(diagnosis.displayImagePath),
                        fit: BoxFit.cover,
                      )
                    : null,
                gradient: diagnosis.displayImagePath.isEmpty
                    ? LinearGradient(
                        colors: [AppTheme.gray200, AppTheme.gray300],
                      )
                    : null,
              ),
              child: diagnosis.displayImagePath.isEmpty
                  ? const Center(
                      child: Text(
                        '분석된 이미지 영역',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray500,
                        ),
                      ),
                    )
                  : null,
            ),

            // 결과 카드
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.mintLight, AppTheme.pinkLight],
                ),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 등급 뱃지
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getGradeColor(diagnosis.result),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getGradeBadge(diagnosis.result),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '신뢰도 ${diagnosis.confidence.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 곰팡이 이름
                  Text(
                    _getGradeName(diagnosis.result),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gray800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 위치
                  Text(
                    '$locationKorean에서 발견',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 신뢰도 바
                  Row(
                    children: [
                      Expanded(
                        flex: diagnosis.confidencePercent,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getGradeColor(diagnosis.result),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 100 - diagnosis.confidencePercent,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppTheme.gray200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 진단 설명 섹션
            if (ragSolution.diagnosis.isNotEmpty)
              _buildSection(
                icon: '🔬',
                title: '진단 결과',
                child: Text(
                  ragSolution.diagnosis,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray600,
                    height: 1.6,
                  ),
                ),
              ),

            // 주요 출몰 지역
            if (ragSolution.frequentlyVisitedAreas.isNotEmpty)
              _buildSection(
                icon: '📍',
                title: '주요 발생 장소',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ragSolution.frequentlyVisitedAreas
                      .map((area) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.mintLight,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              area,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.mintDark,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),

            // 해결 방법 섹션
            if (ragSolution.solutions.isNotEmpty)
              _buildSection(
                icon: '💡',
                title: '해결 방법',
                child: Column(
                  children: List.generate(
                    ragSolution.solutions.length,
                    (index) => _buildSolutionCard(
                      index + 1,
                      ragSolution.solutions[index],
                      color: AppTheme.mintPrimary,
                    ),
                  ),
                ),
              ),

            // 예방법 섹션
            if (ragSolution.preventions.isNotEmpty)
              _buildSection(
                icon: '🛡️',
                title: '예방법',
                child: Column(
                  children: List.generate(
                    ragSolution.preventions.length,
                    (index) => _buildSolutionCard(
                      index + 1,
                      ragSolution.preventions[index],
                      color: AppTheme.pinkPrimary,
                    ),
                  ),
                ),
              ),

            // AI 인사이트 섹션
            if (ragSolution.insight.isNotEmpty)
              _buildSection(
                icon: '🤖',
                title: 'AI 전문가 조언',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.mintLight.withOpacity(0.5),
                        AppTheme.pinkLight.withOpacity(0.5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.mintPrimary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    ragSolution.insight,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray700,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String icon,
    required String title,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  String _getLocationKorean(String location) {
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
      'other': '기타',
    };
    return mapping[location] ?? location;
  }

  Color _getGradeColor(String grade) {
    switch (grade.toUpperCase()) {
      case 'G0':
        return AppTheme.safe;
      case 'G1':
      case 'G2':
        return AppTheme.caution;
      case 'G3':
      case 'G4':
      case 'MULTI':
        return AppTheme.warning;
      default:
        return AppTheme.danger;
    }
  }

  String _getGradeBadge(String grade) {
    switch (grade.toUpperCase()) {
      case 'G0':
        return '안전';
      case 'G1':
        return '검은곰팡이';
      case 'G2':
        return '푸른곰팡이';
      case 'G3':
        return '흰곰팡이';
      case 'G4':
        return '붉은곰팡이';
      case 'MULTI':
        return '복합곰팡이';
      case 'UNCLASSIFIED':
        return '주의';
      default:
        return '주의';
    }
  }

  String _getGradeName(String grade) {
    switch (grade.toUpperCase()) {
      case 'G0':
        return '곰팡이 미검출';
      case 'G1':
        return '검은곰팡이';
      case 'G2':
        return '푸른/초록 곰팡이';
      case 'G3':
        return '하얀 곰팡이 / 백화현상';
      case 'G4':
        return '붉은 곰팡이 / 박테리아';
      case 'MULTI':
        return '복합 곰팡이 검출';
      case 'UNCLASSIFIED':
        return '재진단 필요';
      default:
        return '재진단 필요';
    }
  }

  Widget _buildSolutionCard(int number, String text, {Color? color}) {
    final cardColor = color ?? AppTheme.mintPrimary;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray100, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cardColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray700,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
