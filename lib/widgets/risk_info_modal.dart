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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: DefaultTabController(
        length: 2,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── 헤더 + 닫기 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '도움말',
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
              ),

              // ── 탭 바 ──
              Container(
                margin: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                decoration: BoxDecoration(
                  color: AppTheme.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  labelColor: Colors.white,
                  unselectedLabelColor: AppTheme.gray500,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  indicator: BoxDecoration(
                    color: AppTheme.mintPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  padding: const EdgeInsets.all(3),
                  tabs: const [
                    Tab(text: '위험도 설명'),
                    Tab(text: '경고등 가이드'),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ── 탭 컨텐츠 (스크롤 가능) ──
              Flexible(
                child: TabBarView(
                  children: [
                    _buildRiskExplanationTab(),
                    _buildSignalGuideTab(),
                  ],
                ),
              ),

              // ── 닫기 버튼 ──
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                child: SizedBox(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // 탭 1: 위험도 설명
  // ─────────────────────────────────────────
  Widget _buildRiskExplanationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection(
            '📊 위험도란?',
            '곰팡이가 발생할 가능성을 0~100% 사이의 수치로 나타낸 지표입니다. '
                '수치가 높을수록 곰팡이 발생 위험이 높습니다.',
          ),
          const SizedBox(height: 16),
          _buildInfoSection(
            '🧮 어떻게 산출되나요?',
            '다음 3단계를 거쳐 위험도를 산출합니다.',
          ),
          const SizedBox(height: 12),
          _buildStep('1', '외부 온습도를 기반으로 실내 온습도를 유추합니다.'),
          const SizedBox(height: 8),
          _buildStep('2', '실내 온습도와 창문 방향, 층수 등을 고려하여 벽면 온도와 벽면 상대 습도를 계산합니다.'),
          const SizedBox(height: 8),
          _buildStep('3', '벽면 상대 습도에 곰팡이 임계점을 적용하여 최종 위험도를 산출합니다.'),
          const SizedBox(height: 16),
          const Text(
            '⚠️ 위험도 단계',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),
          const SizedBox(height: 12),
          _buildRiskLevel('0~30%', '안전', AppTheme.safe),
          const SizedBox(height: 8),
          _buildRiskLevel('31~60%', '주의', AppTheme.caution),
          const SizedBox(height: 8),
          _buildRiskLevel('61~90%', '경고', AppTheme.warning),
          const SizedBox(height: 8),
          _buildRiskLevel('91~100%', '위험', AppTheme.danger),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 탭 2: 경고등 가이드
  // ─────────────────────────────────────────
  Widget _buildSignalGuideTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '홈 화면의 경고등은 현재 곰팡이 위험도에 따라 자동으로 변합니다.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.gray600,
            ),
          ),
          const SizedBox(height: 20),

          // 안전 (0~30%)
          _buildSignalCard(
            level: '안전',
            range: '0 ~ 30%',
            color: AppTheme.safe,
            riskImage: 'assets/images/sign/risk_safe.webp',
            actionImage: 'assets/images/sign/ventilation_off.webp',
            description: '곰팡이 걱정 없는 쾌적한 환경입니다.',
            actions: [
              '별도의 조치가 필요 없습니다.',
              '평소처럼 생활하셔도 됩니다.',
            ],
          ),
          const SizedBox(height: 16),

          // 주의 (31~60%)
          _buildSignalCard(
            level: '주의',
            range: '31 ~ 60%',
            color: AppTheme.caution,
            riskImage: 'assets/images/sign/risk_caution.webp',
            actionImage: 'assets/images/sign/ventilation_on.webp',
            description: '습기가 높아지고 있어 주의가 필요합니다.',
            actions: [
              '창문을 열어 30분 이상 환기해주세요.',
              '욕실·주방 등 습기 많은 곳을 확인하세요.',
            ],
          ),
          const SizedBox(height: 16),

          // 경고 (61~90%)
          _buildSignalCard(
            level: '경고',
            range: '61 ~ 90%',
            color: AppTheme.warning,
            riskImage: 'assets/images/sign/risk_warning.webp',
            actionImage: 'assets/images/sign/ventilation_on.webp',
            description: '곰팡이 발생 가능성이 높은 상태입니다.',
            actions: [
              '즉시 환기를 실시해주세요.',
              '벽면·창틀 주변의 결로를 닦아주세요.',
              '에어컨 제습 모드 활용을 권장합니다.',
            ],
          ),
          const SizedBox(height: 16),

          // 위험 (91~100%)
          _buildSignalCard(
            level: '위험',
            range: '91 ~ 100%',
            color: AppTheme.danger,
            riskImage: 'assets/images/sign/risk_danger.webp',
            actionImage: 'assets/images/sign/dehumidifier.webp',
            description: '곰팡이가 언제든 발생할 수 있는 환경입니다.',
            actions: [
              '제습기를 가동해주세요.',
              '환기와 제습을 동시에 진행하세요.',
              '가구 뒤, 벽 모서리 등을 점검하세요.',
              '이미 곰팡이가 보이면 즉시 제거해주세요.',
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // ── 경고등 카드 ──
  Widget _buildSignalCard({
    required String level,
    required String range,
    required Color color,
    required String riskImage,
    required String actionImage,
    required String description,
    required List<String> actions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 레벨 + 범위 + 경고등 이미지
          Row(
            children: [
              // 위험도 경고등
              ClipOval(
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      riskImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.warning_rounded,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 행동 경고등
              ClipOval(
                child: Container(
                  width: 44,
                  height: 44,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Image.asset(
                      actionImage,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.air,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            level,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          range,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 행동 지침
          const Text(
            '행동 지침',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray700,
            ),
          ),
          const SizedBox(height: 6),
          ...actions.map((action) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        action,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: AppTheme.gray600,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  // ── 공통 위젯 ──
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

  Widget _buildStep(String number, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppTheme.mintPrimary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: AppTheme.gray600,
            ),
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
