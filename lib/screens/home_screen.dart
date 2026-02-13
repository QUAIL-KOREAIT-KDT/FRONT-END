import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../widgets/notification_modal.dart';
import '../widgets/risk_info_modal.dart';
import '../services/home_service.dart';
import '../providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final ScrollController? scrollController;

  const HomeScreen({super.key, this.onMenuTap, this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeService _homeService = HomeService();

  // API 데이터
  HomeInfoResponse? _homeInfo;
  bool _isLoading = true;
  String? _errorMessage;

  // 게이지 애니메이션
  late AnimationController _gaugeAnimController;
  late Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _gaugeAnimController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    );
    _gaugeAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _gaugeAnimController, curve: Curves.easeOutCubic),
    );
    _loadHomeInfo();
    // 알림 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  void dispose() {
    _gaugeAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadHomeInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final homeInfo = await _homeService.getHomeInfo();
      if (mounted) {
        setState(() {
          _homeInfo = homeInfo;
          _isLoading = false;
        });
        _startGaugeAnimation();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '데이터를 불러올 수 없습니다';
          _isLoading = false;
        });
      }
    }
  }

  void _startGaugeAnimation() {
    final target = (_homeInfo?.currentRisk?.percentage ?? 0).toDouble();
    _gaugeAnimation = Tween<double>(begin: 0, end: target).animate(
      CurvedAnimation(parent: _gaugeAnimController, curve: Curves.easeOutCubic),
    );
    _gaugeAnimController.forward(from: 0);
  }

  // 위험도 퍼센트 (실시간 CURRENT 기준)
  int get _riskPercentage => _homeInfo?.currentRisk?.percentage ?? 0;

  // 위치
  String get _location => _homeInfo?.regionAddress ?? '위치 정보 없음';

  // 위험도에 따른 이미지 반환
  String _getRiskImage() {
    if (_riskPercentage <= 30) {
      return 'assets/images/character/pang_low.png';
    } else if (_riskPercentage <= 60) {
      return 'assets/images/character/pang_middle.png';
    } else if (_riskPercentage <= 90) {
      return 'assets/images/character/pang_middle_high.png';
    } else {
      return 'assets/images/character/pang_high.png';
    }
  }

  // 위험도에 따른 메시지 반환
  String _getRiskMessage() {
    // 40% 이상이면 주의 메시지 표시
    if (_riskPercentage >= 40) {
      if (_riskPercentage <= 60) {
        return '곰팡이 주의가 필요해요! \n환기를 권장합니다.';
      } else {
        return '곰팡이 위험도가 높아요! \n즉시 환기해주세요.';
      }
    }
    // 40% 미만이면 안전 메시지
    if (_homeInfo?.currentRisk?.message != null && _riskPercentage < 40) {
      return _homeInfo!.currentRisk!.message;
    }
    return '현재 곰팡이로부터 안전한 환경입니다.';
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
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AppTheme.mintPrimary),
                )
              : RefreshIndicator(
                  onRefresh: _loadHomeInfo,
                  color: AppTheme.mintPrimary,
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // 헤더
                        _buildHeader(),

                        // 위치 바
                        _buildLocationBar(),

                        // 에러 메시지
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppTheme.danger),
                            ),
                          ),

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
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unreadCount = notificationProvider.unreadCount;

              return GestureDetector(
                onTap: () => NotificationModal.show(context),
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
                      if (unreadCount > 0)
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
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Row(
        children: [
          // 왼쪽 공간 (중앙 정렬을 위해)
          Expanded(
            child: SizedBox(),
          ),
          // 중앙에 위치 표시
          Row(
            mainAxisSize: MainAxisSize.min,
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
          // 우측 공간 및 물음표 버튼
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => RiskInfoModal.show(context),
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
                  child: const Center(
                    child: Icon(
                      Icons.help_outline,
                      color: AppTheme.gray700,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 마커 고정 색상
  static const Color _maxColor = Color(0xFFFF6B6B); // 최고: 빨간색
  static const Color _minColor = Color(0xFF54A0FF); // 최저: 파란색

  // 반원형 게이지 + 캐릭터 중앙 레이아웃 (계기판 스타일)
  Widget _buildRiskDisplaySection() {
    const double gaugeSize = 300;
    const double strokeWidth = 37.0; // 두께 확대 (20→35)
    final riskColor = AppTheme.getRiskColor(_riskPercentage);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── 반원 게이지 + 바늘 마커 + 캐릭터 영역 ──
            SizedBox(
              width: gaugeSize,
              height: gaugeSize / 2 + 44,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 배경 반원 게이지
                  CustomPaint(
                    size: Size(gaugeSize, gaugeSize / 2),
                    painter: _SemiCircleGaugePainter(
                      percentage: 100,
                      color: Colors.transparent,
                      strokeWidth: strokeWidth,
                      isBackground: true,
                    ),
                  ),

                  // 채워진 반원 게이지 (애니메이션)
                  AnimatedBuilder(
                    animation: _gaugeAnimation,
                    builder: (context, _) {
                      return CustomPaint(
                        size: Size(gaugeSize, gaugeSize / 2),
                        painter: _SemiCircleGaugePainter(
                          percentage: _gaugeAnimation.value,
                          color: riskColor,
                          strokeWidth: strokeWidth,
                          isBackground: false,
                        ),
                      );
                    },
                  ),

                  // 눈금 텍스트 (0, 30, 60, 90)
                  ..._buildTickLabels(gaugeSize, strokeWidth),

                  // 바늘 마커들 (MIN/MAX만 표시)
                  CustomPaint(
                    size: Size(gaugeSize, gaugeSize / 2),
                    painter: _NeedleMarkerPainter(
                      gaugeSize: gaugeSize,
                      strokeWidth: strokeWidth,
                      minPercentage: _homeInfo?.minRisk?.percentage,
                      maxPercentage: _homeInfo?.maxRisk?.percentage,
                      minColor: _minColor,
                      maxColor: _maxColor,
                    ),
                  ),

                  // 캐릭터 이미지 (반원 안쪽 하단 중앙)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SizedBox(
                        width: 150,
                        height: 150,
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: Image.asset(
                            _getRiskImage(),
                            width: 100,
                            height: 100,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.mintLight2,
                                      AppTheme.pinkLight2,
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    _riskPercentage <= 30
                                        ? '😊'
                                        : _riskPercentage <= 60
                                            ? '😐'
                                            : '😰',
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── 현재 시간 기준 + 퍼센트 + 상태 텍스트 ──
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '곰팡이 위험도',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${_homeInfo?.currentHourWeather?.time ?? ''} 기준',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black.withValues(alpha: 0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '$_riskPercentage%',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: riskColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getRiskMessage(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.gray700,
              ),
            ),

            // ── MAX / MIN 정보 칩 (고정 색상) ──
            if (_homeInfo?.maxRisk != null || _homeInfo?.minRisk != null) ...[
              const SizedBox(height: 16),
              _buildMaxMinChips(),
            ],
          ],
        ),
      ),
    );
  }

  // 눈금 라벨 (0, 30, 60, 90) 위치 계산
  List<Widget> _buildTickLabels(double gaugeSize, double strokeWidth) {
    const ticks = [
      (value: 30, color: AppTheme.safe),
      (value: 60, color: AppTheme.caution),
      (value: 90, color: AppTheme.warning),
    ];

    final radius = gaugeSize / 2;

    return ticks.map((t) {
      final angle = math.pi + (t.value / 100) * math.pi;
      // 두꺼운 게이지 바깥에 배치 (strokeWidth 반영)
      final textRadius = radius + 18;
      final dx = radius + textRadius * math.cos(angle);
      final dy = radius + textRadius * math.sin(angle);

      return Positioned(
        left: dx - 12,
        top: dy - 8,
        child: SizedBox(
          width: 24,
          child: Text(
            '${t.value}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: t.color.withValues(alpha: 0.9),
            ),
          ),
        ),
      );
    }).toList();
  }

  // MAX/MIN 칩 (고정 색상: 최고=빨강, 최저=파랑)
  Widget _buildMaxMinChips() {
    final maxRisk = _homeInfo?.maxRisk;
    final minRisk = _homeInfo?.minRisk;

    Widget buildChip({
      required IconData icon,
      required String label,
      required int percentage,
      required String time,
      required Color color,
    }) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$label $percentage%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  if (time.isNotEmpty)
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: color.withValues(alpha: 0.7),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        if (minRisk != null)
          buildChip(
            icon: Icons.arrow_downward_rounded,
            label: '최저',
            percentage: minRisk.percentage,
            time: minRisk.time,
            color: _minColor, // 고정 파란색
          ),
        if (maxRisk != null && minRisk != null) const SizedBox(width: 10),
        if (maxRisk != null)
          buildChip(
            icon: Icons.arrow_upward_rounded,
            label: '최고',
            percentage: maxRisk.percentage,
            time: maxRisk.time,
            color: _maxColor, // 고정 빨간색
          )
      ],
    );
  }

  Widget _buildWeatherCard() {
    final weather = _homeInfo?.currentHourWeather;
    final now = DateTime.now();
    final dateStr = '${now.month}월 ${now.day}일';
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final weekday = weekdays[now.weekday - 1];
    // 기준 시간대 표시 (API에서 받아온 time 필드 사용)
    final timeStr = weather?.time ?? '';

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
                '$dateStr ${weekday}요일${timeStr.isNotEmpty ? ' $timeStr 기준' : ''}',
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
              _buildWeatherItem(
                '🌡️',
                weather != null ? '${weather.temp.toStringAsFixed(0)}°C' : '-',
                '기온',
              ),
              _buildWeatherItem(
                '💧',
                weather != null ? '${weather.humid.toStringAsFixed(0)}%' : '-',
                '습도',
              ),
              _buildWeatherItem(
                _getConditionEmoji(weather?.condition ?? ''),
                weather?.condition ?? '-',
                '날씨',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getConditionEmoji(String condition) {
    if (condition.contains('맑') || condition.contains('쾌적')) return '☀️';
    if (condition.contains('흐림') || condition.contains('구름')) return '☁️';
    if (condition.contains('비')) return '🌧️';
    if (condition.contains('눈')) return '❄️';
    if (condition.contains('습')) return '💧';
    return '🌤️';
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
    final ventilationTimes = _homeInfo?.ventilationTimes ?? [];
    final hasVentilationTime = ventilationTimes.isNotEmpty;

    String tipMessage;
    String? timeRange;
    if (hasVentilationTime) {
      final first = ventilationTimes.first;
      timeRange = '${first.startTime} ~ ${first.endTime}';
      tipMessage = first.description.isNotEmpty
          ? first.description
          : '환기 찬스! (평균 습도 55%)';
    } else {
      tipMessage = '오늘은 환기하기 적합한\n시간이 없어요 🍄';
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: hasVentilationTime
            ? AppTheme.mintGradient
            : LinearGradient(colors: [AppTheme.gray400, AppTheme.gray500]),
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
            child: Center(
              child: Text(
                hasVentilationTime ? '💨' : '🍄',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '오늘의 환기 추천',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (timeRange != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          timeRange,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  tipMessage,
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

// ─────────────────────────────────────────────────────────────
//  반원형 게이지 페인터
//  - 왼쪽(0%) → 오른쪽(100%), 180도 아치
//  - isBackground=true: 4구간 그라데이션 배경
//  - isBackground=false: 현재 퍼센트까지 진한 색 채움
// ─────────────────────────────────────────────────────────────
class _SemiCircleGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  final double strokeWidth;
  final bool isBackground;

  _SemiCircleGaugePainter({
    required this.percentage,
    required this.color,
    required this.strokeWidth,
    required this.isBackground,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (isBackground) {
      // 4구간 배경 (safe → caution → warning → danger)
      const segments = [
        (start: 0.0, sweep: 0.30, color: AppTheme.safe),
        (start: 0.30, sweep: 0.30, color: AppTheme.caution),
        (start: 0.60, sweep: 0.30, color: AppTheme.warning),
        (start: 0.90, sweep: 0.10, color: AppTheme.danger),
      ];

      for (final seg in segments) {
        final paint = Paint()
          ..color = seg.color.withValues(alpha: 0.25)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt;

        canvas.drawArc(
          rect,
          math.pi + seg.start * math.pi,
          seg.sweep * math.pi,
          false,
          paint,
        );
      }
    } else {
      // 채워진 게이지
      if (percentage <= 0) return;

      final sweepAngle = (percentage / 100).clamp(0.0, 1.0) * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      // SweepGradient로 구간별 색상 적용
      paint.shader = SweepGradient(
        startAngle: math.pi,
        endAngle: 2 * math.pi,
        colors: const [
          AppTheme.safe,
          AppTheme.caution,
          AppTheme.warning,
          AppTheme.danger,
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(rect);

      canvas.drawArc(rect, math.pi, sweepAngle, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SemiCircleGaugePainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.color != color ||
        oldDelegate.isBackground != isBackground;
  }
}

// ─────────────────────────────────────────────────────────────
//  계기판 바늘(Needle) 마커 페인터
//  - 자동차 속도계 스타일의 뾰족한 바늘
//  - MIN(파랑), MAX(빨강), NOW(위험도 색상) 3개 바늘
//  - 바늘이 원호 중심을 향해 가리키는 방향으로 회전
// ─────────────────────────────────────────────────────────────
class _NeedleMarkerPainter extends CustomPainter {
  final double gaugeSize;
  final double strokeWidth;
  final int? minPercentage;
  final int? maxPercentage;
  final Color minColor;
  final Color maxColor;

  _NeedleMarkerPainter({
    required this.gaugeSize,
    required this.strokeWidth,
    required this.minPercentage,
    required this.maxPercentage,
    required this.minColor,
    required this.maxColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - strokeWidth / 2;

    // MIN 바늘
    if (minPercentage != null) {
      _drawNeedle(
        canvas,
        center,
        radius,
        percentage: minPercentage!,
        color: minColor,
        needleLength: 23,
        needleWidth: 5,
        label: 'MIN',
      );
    }

    // MAX 바늘
    if (maxPercentage != null) {
      _drawNeedle(
        canvas,
        center,
        radius,
        percentage: maxPercentage!,
        color: maxColor,
        needleLength: 23,
        needleWidth: 5,
        label: 'MAX',
      );
    }
  }

  void _drawNeedle(
    Canvas canvas,
    Offset center,
    double radius, {
    required int percentage,
    required Color color,
    required double needleLength,
    required double needleWidth,
    required String label,
  }) {
    // 각도 계산: 좌측(0%) = π, 우측(100%) = 2π
    final angle = math.pi + (percentage / 100) * math.pi;

    // 바늘 꼭짓점 (게이지 바 바깥 가장자리에 위치)
    final tipRadius = radius + strokeWidth / 2;
    final tipX = center.dx + tipRadius * math.cos(angle);
    final tipY = center.dy + tipRadius * math.sin(angle);

    // 바늘 밑변 (게이지 바 안쪽으로 뻗음, 중심 방향)
    final baseRadius = tipRadius - needleLength;
    final baseX = center.dx + baseRadius * math.cos(angle);
    final baseY = center.dy + baseRadius * math.sin(angle);

    // 밑변 양 끝 (각도에 수직으로 폭 생성)
    final perpAngle = angle + math.pi / 2;
    final halfWidth = needleWidth / 2;
    final baseLeft = Offset(
      baseX + halfWidth * math.cos(perpAngle),
      baseY + halfWidth * math.sin(perpAngle),
    );
    final baseRight = Offset(
      baseX - halfWidth * math.cos(perpAngle),
      baseY - halfWidth * math.sin(perpAngle),
    );

    // 이등변 삼각형 바늘 그리기 (바깥→안쪽 방향)
    final needlePath = Path()
      ..moveTo(tipX, tipY) // 뾰족한 끝 (바 바깥 가장자리)
      ..lineTo(baseLeft.dx, baseLeft.dy) // 밑변 왼쪽 (안쪽)
      ..lineTo(baseRight.dx, baseRight.dy) // 밑변 오른쪽 (안쪽)
      ..close();

    // 바늘 채우기
    final needlePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(needlePath, needlePaint);

    // 바늘 테두리
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    canvas.drawPath(needlePath, borderPaint);

    // 바늘 밑변 중앙에 동그란 핀 (작은 원)
    const pinRadius = 3.0;
    final pinPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(baseX, baseY), pinRadius, pinPaint);

    // 핀 위에 흰색 점
    final pinHighlight = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(baseX, baseY), pinRadius * 0.4, pinHighlight);

    // 라벨 텍스트 (게이지 바 안쪽 영역에 표시)
    if (label.isNotEmpty) {
      final textSpan = TextSpan(
        text: label,
        style: TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout();

      // 핀에서 안쪽으로 더 들어간 위치
      final labelRadius = baseRadius - 10;
      final labelX = center.dx + labelRadius * math.cos(angle);
      final labelY = center.dy + labelRadius * math.sin(angle);

      canvas.save();
      canvas.translate(
        labelX - textPainter.width / 2,
        labelY - textPainter.height / 2,
      );
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _NeedleMarkerPainter oldDelegate) {
    return oldDelegate.minPercentage != minPercentage ||
        oldDelegate.maxPercentage != maxPercentage;
  }
}
