import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../widgets/menu/hamburger_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // 더미 데이터
  final int _riskPercentage = 70;
  final String _location = '서울특별시 강남구';

  // 애니메이션 컨트롤러
  AnimationController? _animationController;
  Animation<double>? _swingAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _animationController?.dispose();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _swingAnimation = Tween<double>(begin: -10, end: 10).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

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
    return Image.asset(
      _getRiskImage(),
      width: 160,
      height: 160,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // 이미지 로드 실패 시 기본 이모지 표시
        return Container(
          width: 160,
          height: 160,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const HamburgerMenu(),
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
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
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
          Container(
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
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: AppTheme.gray700,
                    size: 24,
                  ),
                ),
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
                  // 애니메이션 캐릭터 이미지
                  _swingAnimation != null
                      ? AnimatedBuilder(
                          animation: _swingAnimation!,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(_swingAnimation!.value, 0),
                              child: child,
                            );
                          },
                          child: _buildCharacterImage(),
                        )
                      : _buildCharacterImage(),

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
              _buildWeatherItem('🌡️', '-2°', '기온'),
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
