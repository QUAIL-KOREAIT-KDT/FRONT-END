import 'package:flutter/material.dart';
import '../config/theme.dart';

class RiskInfoModal extends StatelessWidget {
  const RiskInfoModal({super.key});

  /// 모달 표시 (static 메서드로 쉽게 호출)
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => const RiskInfoModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '곰팡이 위험도란?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray800,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: AppTheme.gray500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 설명 섹션
            _buildInfoSection(
              '📊 위험도 점수란?',
              '곰팡이가 발생할 가능성을 0~100점 사이의 점수로 나타낸 지표입니다. '
                  '점수가 높을수록 곰팡이 발생 위험이 높습니다.',
            ),
            const SizedBox(height: 16),

            _buildInfoSection(
              '🧮 어떻게 산출되나요?',
              '실내외 온도, 습도, 날씨, 시간대 등 다양한 환경 요인을 AI 모델에 입력하여 '
                  '곰팡이 발생 위험도를 예측합니다.',
            ),
            const SizedBox(height: 16),

            // 위험도 단계 안내
            const Text(
              '⚠️ 위험도 단계',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 12),
            _buildRiskLevel('0~30점', '안전', AppTheme.safe),
            const SizedBox(height: 8),
            _buildRiskLevel('31~60점', '주의', AppTheme.caution),
            const SizedBox(height: 8),
            _buildRiskLevel('61~90점', '경고', AppTheme.warning),
            const SizedBox(height: 8),
            _buildRiskLevel('91~100점', '위험', AppTheme.danger),
            const SizedBox(height: 20),

            // 닫기 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.mintPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: AppTheme.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildRiskLevel(String range, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          range,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray700,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.gray600,
          ),
        ),
      ],
    );
  }
}
