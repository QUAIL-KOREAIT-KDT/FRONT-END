import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../models/notification.dart';
import '../widgets/notification_modal.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;

  const HomeScreen({super.key, this.onMenuTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  // 더미 데이터
  final int _riskPercentage = 20;
  final String _location = '서울특별시 강남구';

  // 더미 알림 데이터
  // TODO: 추후 백엔드 API 연동 시 NotificationService를 통해 데이터를 받아올 예정
  // GET /api/notifications -> List<NotificationItem>
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      type: NotificationType.riskAlert,
      title: '곰팡이 위험도 상승',
      message: '현재 습도가 높아 곰팡이 발생 위험이 증가했습니다. 환기를 권장합니다.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    NotificationItem(
      id: '2',
      type: NotificationType.tip,
      title: '오늘의 환기 팁',
      message: '오전 10시~12시 사이가 환기하기 가장 좋은 시간대입니다.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    NotificationItem(
      id: '3',
      type: NotificationType.diagnosis,
      title: '진단 결과 확인',
      message: '어제 촬영한 이미지의 곰팡이 진단 결과가 도착했습니다.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    NotificationItem(
      id: '4',
      type: NotificationType.update,
      title: '새로운 기능 추가',
      message: '곰팡이 사전에 새로운 정보가 업데이트되었습니다. 지금 확인해보세요!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    NotificationItem(
      id: '5',
      type: NotificationType.riskAlert,
      title: '위험 지역 알림',
      message: '욕실 습도가 70%를 넘었습니다. 곰팡이 발생 주의가 필요합니다.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  // 위험도에 따른 이미지 반환
  String _getRiskImage() {
    if (_riskPercentage <= 30) {
      return 'assets/images/character/pang_low.png';
    } else if (_riskPercentage <= 60) {
      return 'assets/images/character/pang_middle.png';
    } else {
      return 'assets/images/character/pang_high.png';
    }
  }

  // 위험도에 따른 메시지 반환
  String _getRiskMessage() {
    if (_riskPercentage <= 30) {
      return '곰팡이 걱정 없는 날이에요! 🎉';
    } else if (_riskPercentage <= 60) {
      return '환기가 필요해요! 💨';
    } else {
      return '곰팡이 주의가 필요해요! ⚠️';
    }
  }

  // 캐릭터 이미지 위젯
  Widget _buildCharacterImage() {
    return ClipRect(
      child: SizedBox(
        width: 250, // ← 이미지 영역 가로 크기 조절
        height: 250, // ← 이미지 영역 세로 크기 조절
        child: FittedBox(
          fit: BoxFit.cover, // ← 이미지 채우기 방식 (cover: 꽉 채움, contain: 비율 유지)
          child: Image.asset(
            _getRiskImage(),
            width: 200, // ← 원본 이미지 가로 크기 조절
            height: 200, // ← 원본 이미지 세로 크기 조절
            errorBuilder: (context, error, stackTrace) {
              // 이미지 로드 실패 시 기본 이모지 표시
              return Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.mintLight2, AppTheme.pinkLight2],
                  ),
                ),
                child: Center(
                  child: Text(
                    _riskPercentage <= 30
                        ? '😊'
                        : _riskPercentage <= 60
                            ? '😐'
                            : '😰',
                    style: const TextStyle(fontSize: 60),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppTheme.mintLight, Colors.white],
            stops: [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 헤더
                _buildHeader(),

                // 위치 바
                _buildLocationBar(),

                // 새로운 레이아웃: 바 게이지 + 캐릭터 이미지
                _buildRiskDisplaySection(),

                // 날씨 카드
                _buildWeatherCard(),

                // 환기 추천 카드
                _buildTipCard(),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 햄버거 메뉴 버튼
          GestureDetector(
            onTap: () => widget.onMenuTap?.call(),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => Container(
                    width: 20,
                    height: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppTheme.gray700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 로고
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppTheme.mintPrimary, AppTheme.pinkPrimary],
            ).createShader(bounds),
            child: const Text(
              '팡팡팡',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          // 알림 버튼
          GestureDetector(
            onTap: () => NotificationModal.show(context, _notifications),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: AppTheme.gray700,
                      size: 24,
                    ),
                  ),
                  // 읽지 않은 알림이 있을 때만 빨간 점 표시
                  if (_notifications.any((n) => !n.isRead))
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.pinkPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 16,
            color: AppTheme.mintPrimary,
          ),
          const SizedBox(width: 6),
          Text(
            _location,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.gray500,
            ),
          ),
        ],
      ),
    );
  }

  // 새로운 위험도 표시 섹션 (바 게이지 + 캐릭터)
  Widget _buildRiskDisplaySection() {
    final riskColor = AppTheme.getRiskColor(_riskPercentage);
    final riskStatus = AppTheme.getRiskStatus(_riskPercentage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 좌측: 수직 바 게이지
            _buildVerticalBarGauge(riskColor, riskStatus),

            const SizedBox(width: 24),

            // 우측: 캐릭터 이미지 + 상태 정보
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 캐릭터 이미지
                  _buildCharacterImage(),

                  const SizedBox(height: 16),

                  // 상태 메시지
                  Text(
                    _getRiskMessage(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.gray700,
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

  // 수직 바 게이지
  Widget _buildVerticalBarGauge(Color riskColor, String riskStatus) {
    return Column(
      children: [
        // 바 게이지
        Container(
          width: 40,
          height: 200,
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 배경 그라데이션 (위험도 구간 표시)
              Container(
                width: 40,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.safe.withOpacity(0.3),
                      AppTheme.caution.withOpacity(0.3),
                      AppTheme.warning.withOpacity(0.3),
                      AppTheme.danger.withOpacity(0.3),
                    ],
                    stops: const [0.0, 0.3, 0.6, 1.0],
                  ),
                ),
              ),

              // 채워진 게이지
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                width: 40,
                height: 200 * (_riskPercentage / 100),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      riskColor.withOpacity(0.8),
                      riskColor,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: riskColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
              ),

              // 퍼센트 표시
              Positioned(
                bottom: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    '$_riskPercentage%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: _riskPercentage > 20 ? Colors.white : riskColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 위험도 텍스트
        Text(
          '곰팡이',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray500,
          ),
        ),
        Text(
          '위험도',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.gray500,
          ),
        ),

        const SizedBox(height: 8),

        // 상태 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: riskColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            riskStatus,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: riskColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRiskGauge() {
    final riskColor = AppTheme.getRiskColor(_riskPercentage);
    final riskStatus = AppTheme.getRiskStatus(_riskPercentage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // 원형 게이지
          SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              children: [
                // 배경 게이지
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _GaugeBackgroundPainter(),
                ),
                // 채워진 게이지
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _GaugeFillPainter(
                    percentage: _riskPercentage,
                    color: riskColor,
                  ),
                ),
                // 중앙 원
                Center(
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 캐릭터
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.mintLight2,
                                AppTheme.pinkLight2
                              ],
                            ),
                            border: Border.all(
                              color: AppTheme.mintMedium,
                              width: 3,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: const Center(
                            child: Text('🧚', style: TextStyle(fontSize: 36)),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_riskPercentage%',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: riskColor,
                          ),
                        ),
                        Text(
                          '곰팡이 위험도',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 상태 뱃지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  riskColor.withOpacity(0.15),
                  riskColor.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: riskColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  riskStatus,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: riskColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '오늘의 날씨',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.gray700,
                ),
              ),
              Text(
                '1월 20일 월요일',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.gray400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildWeatherItem('🌡️', '-2°C', '기온'),
              _buildWeatherItem('💧', '45%', '습도'),
              _buildWeatherItem('☀️', '맑음', '날씨'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(String icon, String value, String label) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.gray400,
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.mintGradient,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('💨', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '오늘의 환기 추천',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '오전 10시~12시 사이에\n10분간 환기를 추천해요!',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.85),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 게이지 배경 페인터
class _GaugeBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      AppTheme.safe,
      AppTheme.caution,
      AppTheme.warning,
      AppTheme.danger,
    ];

    for (int i = 0; i < 4; i++) {
      final paint = Paint()
        ..color = colors[i].withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 20
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 15),
        -math.pi / 2 + (i * math.pi / 2),
        math.pi / 2,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// 게이지 채움 페인터
class _GaugeFillPainter extends CustomPainter {
  final int percentage;
  final Color color;

  _GaugeFillPainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 15),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
