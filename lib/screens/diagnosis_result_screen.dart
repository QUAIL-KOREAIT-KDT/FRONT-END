import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/mold_diagnosis.dart';

class DiagnosisResultScreen extends StatelessWidget {
  const DiagnosisResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 더미 데이터
    final diagnosis = MoldDiagnosisModel.dummy();

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
            // 이미지 영역
            Container(
              margin: const EdgeInsets.all(20),
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.gray200, AppTheme.gray300],
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Text(
                  '분석된 이미지 영역',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray500,
                  ),
                ),
              ),
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
                  // 심각도 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.warning,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⚠️', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 6),
                        Text(
                          diagnosis.severityText,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 곰팡이 이름
                  Text(
                    diagnosis.moldName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gray800,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // 타입 및 위치
                  Text(
                    '[${diagnosis.moldType}] ${diagnosis.moldNameEn} • ${diagnosis.location}에서 발견',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.gray500,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 심각도 바
                  Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Container(
                          height: 8,
                          margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: index < diagnosis.severityLevel
                                ? AppTheme.warning
                                : AppTheme.gray200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 해결 방법 섹션
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Text('💡', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        '해결 방법',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gray800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 솔루션 카드들
                  ...List.generate(
                    diagnosis.solutions.length,
                    (index) => _buildSolutionCard(
                      index + 1,
                      diagnosis.solutions[index],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 예방 팁 섹션
                  const Row(
                    children: [
                      Text('🛡️', style: TextStyle(fontSize: 16)),
                      SizedBox(width: 8),
                      Text(
                        '예방 팁',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gray800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.mintLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: diagnosis.preventions
                          .map((tip) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '•',
                                      style: TextStyle(
                                        color: AppTheme.mintPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.gray700,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSolutionCard(int number, String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.gray100, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: AppTheme.mintPrimary,
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
