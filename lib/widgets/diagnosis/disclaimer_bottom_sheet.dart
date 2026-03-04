import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// 곰팡이 진단 면책사유 동의 바텀시트
/// 최초 진단 시 1회 표시되며, 동의해야 진단이 진행됩니다.
class DiagnosisDisclaimerBottomSheet extends StatefulWidget {
  const DiagnosisDisclaimerBottomSheet({super.key});

  /// 바텀시트를 표시하고 사용자 동의 여부를 반환
  static Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => const DiagnosisDisclaimerBottomSheet(),
    );
    return result ?? false;
  }

  @override
  State<DiagnosisDisclaimerBottomSheet> createState() =>
      _DiagnosisDisclaimerBottomSheetState();
}

class _DiagnosisDisclaimerBottomSheetState
    extends State<DiagnosisDisclaimerBottomSheet> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 바
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.health_and_safety_outlined,
                    color: AppTheme.warning,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'AI 곰팡이 진단 안내',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gray800,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 면책 내용 (스크롤 가능)
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 안내 박스
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.warning.withOpacity(0.25),
                      ),
                    ),
                    child: const Text(
                      '본 진단 기능은 AI 모델을 활용한 참고용 서비스입니다.\n'
                      '진단을 시작하기 전 아래 내용을 반드시 확인해 주세요.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray700,
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildDisclaimerItem(
                    number: '1',
                    text:
                        'AI 진단 결과는 100% 정확하지 않을 수 있으며, 의학적·전문적 판단을 대체하지 않습니다.',
                  ),
                  _buildDisclaimerItem(
                    number: '2',
                    text:
                        '곰팡이 종류 및 위험도 등급은 학습 데이터 기반의 추정 결과이며, 실제 상황과 다를 수 있습니다.',
                  ),
                  _buildDisclaimerItem(
                    number: '3',
                    text:
                        '건강에 이상이 있거나 심각한 곰팡이 오염이 의심되는 경우, 반드시 전문가(환경 전문업체, 의료기관 등)에게 상담하시기 바랍니다.',
                  ),
                  _buildDisclaimerItem(
                    number: '4',
                    text:
                        '본 서비스의 진단 결과에 따른 조치로 발생한 손해에 대해 서비스 제공자는 책임을 지지 않습니다.',
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 동의 체크박스 + 버튼 영역
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  // 체크박스
                  GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 14,
                      ),
                      decoration: BoxDecoration(
                        color: _agreed
                            ? AppTheme.mintPrimary.withOpacity(0.08)
                            : AppTheme.gray100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _agreed
                              ? AppTheme.mintPrimary.withOpacity(0.4)
                              : AppTheme.gray200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _agreed
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 22,
                            color: _agreed
                                ? AppTheme.mintPrimary
                                : AppTheme.gray400,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              '위 내용을 확인했으며, 동의합니다',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.gray700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(color: AppTheme.gray300),
                          ),
                          child: const Text(
                            '취소',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.gray500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _agreed
                              ? () => Navigator.pop(context, true)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.mintPrimary,
                            disabledBackgroundColor: AppTheme.gray200,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            '동의하고 진단하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: _agreed ? Colors.white : AppTheme.gray400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerItem({
    required String number,
    required String text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: AppTheme.gray200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.gray600,
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
