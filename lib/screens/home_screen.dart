import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../config/theme.dart';
import '../widgets/notification_modal.dart';
import '../services/home_service.dart';
import '../providers/notification_provider.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onMenuTap;
  final ScrollController? scrollController;

  const HomeScreen({super.key, this.onMenuTap, this.scrollController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();

  // API 데이터
  HomeInfoResponse? _homeInfo;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHomeInfo();
    // 알림 목록 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
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

  // 캐릭터 이미지 위젯
  Widget _buildCharacterImage() {
    return ClipRect(
      child: SizedBox(
        width: 220, // ← 이미지 영역 가로 크기 조절
        height: 220, // ← 이미지 영역 세로 크기 조절
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 좌측: 새 게이지 위젯
            RiskGaugeBarWidget(
              currentPercentage: _riskPercentage,
              currentTime: _homeInfo?.currentHourWeather?.time ?? '',
              maxPercentage: _homeInfo?.maxRisk?.percentage,
              maxTime: _homeInfo?.maxRisk?.time,
              minPercentage: _homeInfo?.minRisk?.percentage,
              minTime: _homeInfo?.minRisk?.time,
            ),

            const SizedBox(width: 16),

            // 우측: 캐릭터 이미지 + 상태 정보 + MAX/MIN 칩
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
//  RiskGaugeBarWidget
//  LayoutBuilder + Stack 기반 수직 게이지 바
//  - 바 내부 하단: 현재 퍼센트 (흰색 텍스트)
//  - 바 바깥 좌측: MAX(빨강) / MIN(파랑) 마커 + 지시선
//  - 바 아래: 현재 시간 안내 문구
// ─────────────────────────────────────────────────────────────
class RiskGaugeBarWidget extends StatefulWidget {
  final int currentPercentage;
  final String currentTime;
  final int? maxPercentage;
  final String? maxTime;
  final int? minPercentage;
  final String? minTime;

  const RiskGaugeBarWidget({
    super.key,
    required this.currentPercentage,
    required this.currentTime,
    this.maxPercentage,
    this.maxTime,
    this.minPercentage,
    this.minTime,
  });

  @override
  State<RiskGaugeBarWidget> createState() => _RiskGaugeBarWidgetState();
}

class _RiskGaugeBarWidgetState extends State<RiskGaugeBarWidget> {
  // 애니메이션용 표시 퍼센트 (0에서 시작해 실제값으로 전환)
  double _animatedPercentage = 0;

  @override
  void initState() {
    super.initState();
    // 첫 프레임 렌더 후 애니메이션 시작
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _animatedPercentage = widget.currentPercentage.toDouble();
        });
      }
    });
  }

  @override
  void didUpdateWidget(RiskGaugeBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 데이터가 새로 갱신될 때도 애니메이션 재실행
    if (oldWidget.currentPercentage != widget.currentPercentage) {
      setState(() {
        _animatedPercentage = widget.currentPercentage.toDouble();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 220;
    const double barWidth = 36;
    // 좌측 마커(MAX/MIN) 영역 너비
    const double markerAreaWidth = 76;
    // 우측 눈금(30/60/90) 영역 너비
    const double tickAreaWidth = 28;
    // 전체 Stack 너비 = 좌측 마커 + 바 + 우측 눈금
    const double totalWidth = markerAreaWidth + barWidth + tickAreaWidth;

    final currentColor = AppTheme.getRiskColor(widget.currentPercentage);

    // 우측 눈금 정의
    const thresholds = [
      (value: 30, color: Color(0xFF4DD9BC)), // safe (green)
      (value: 60, color: Color(0xFFFFD93D)), // caution (yellow)
      (value: 90, color: Color(0xFFFF6B6B)), // danger (red)
    ];

    // ③ 전체를 Padding(right)으로 감싸서 캐릭터와 간격 확보
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      // ② Column에 crossAxisAlignment.center → 하단 텍스트 중앙 정렬
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── 게이지 바 + 좌측 마커 + 우측 눈금 ──
          SizedBox(
            width: totalWidth,
            height: barHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // ── 좌측: MAX/MIN 마커 ──
                if (widget.maxPercentage != null)
                  _buildMarker(
                    barHeight: barHeight,
                    markerAreaWidth: markerAreaWidth,
                    percentage: widget.maxPercentage!,
                    time: widget.maxTime ?? '',
                    isMax: true,
                  ),
                if (widget.minPercentage != null)
                  _buildMarker(
                    barHeight: barHeight,
                    markerAreaWidth: markerAreaWidth,
                    percentage: widget.minPercentage!,
                    time: widget.minTime ?? '',
                    isMax: false,
                  ),

                // ── 게이지 바 본체 (중앙에 배치) ──
                Positioned(
                  left: markerAreaWidth,
                  top: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: barWidth,
                    height: barHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // 배경 그라데이션 (위험 구간 표시)
                          Container(
                            width: barWidth,
                            height: barHeight,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0x4D4DD9BC), // safe 30%
                                  Color(0x4DFFD93D), // caution 30%
                                  Color(0x4DFF9F43), // warning 30%
                                  Color(0x4DFF6B6B), // danger 30%
                                ],
                                stops: [0.0, 0.3, 0.6, 1.0],
                              ),
                            ),
                          ),

                          // 채워진 게이지 (0 → 실제값 애니메이션)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 900),
                            curve: Curves.easeOutCubic,
                            width: barWidth,
                            height: barHeight * (_animatedPercentage / 100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  currentColor.withValues(alpha: 0.75),
                                  currentColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: currentColor.withValues(alpha: 0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, -3),
                                ),
                              ],
                            ),
                          ),

                          // 현재 퍼센트 - 바 내부 하단 고정
                          Positioned(
                            bottom: 10,
                            child: Text(
                              '${widget.currentPercentage}%',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: widget.currentPercentage > 15
                                    ? Colors.white
                                    : currentColor,
                                shadows: widget.currentPercentage > 15
                                    ? [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.25),
                                          blurRadius: 4,
                                        )
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // ① 우측 눈금 (30 / 60 / 90)
                ...thresholds.map((t) {
                  final double bottomOffset = barHeight * (t.value / 100);
                  return Positioned(
                    bottom: bottomOffset - 5,
                    left: markerAreaWidth + barWidth,
                    child: SizedBox(
                      width: tickAreaWidth,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // 지시선
                          Container(
                            width: 8,
                            height: 1.5,
                            color: t.color.withValues(alpha: 0.85),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${t.value}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.color.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── 현재 시간 안내 문구 : 막대(barWidth) 중앙에 정확히 맞춤 ──
          // 텍스트 영역 제한을 풀고, Transform.translate로 물리적 중심을 이동
          Transform.translate(
            offset: const Offset((markerAreaWidth - tickAreaWidth) / 2, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.currentTime.isNotEmpty
                      ? '${widget.currentTime} 기준'
                      : '현재 위험도',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.gray400, // 필요시 Color(0xFF9E9E9E) 등으로 수정
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '곰팡이 위험도',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.gray500, // 필요시 Color(0xFF757575) 등으로 수정
                  ),
                ),
              ],
            ),
          ),
        ], // Stack/Column 종료 괄호들
      ),
    );
  }

  /// MAX 또는 MIN 마커 위젯
  /// [bottom] = barHeight * percentage / 100 으로 Y 위치 결정
  Widget _buildMarker({
    required double barHeight,
    required double markerAreaWidth,
    required int percentage,
    required String time,
    required bool isMax,
  }) {
    // 마커 중앙을 percentage 높이에 맞춤
    final double bottomOffset = barHeight * (percentage / 100);

    // 시간 한 줄(12px) + 라벨 한 줄(12px) + 줄 간격 = 약 30px → 절반
    const double markerHalfHeight = 15.0;

    final Color markerColor = isMax
        ? const Color(0xFFE55353) // 빨강 계열
        : const Color(0xFF3B82F6); // 파랑 계열

    final String label = isMax ? '최고' : '최저';

    return Positioned(
      bottom: bottomOffset - markerHalfHeight,
      left: 0,
      child: SizedBox(
        width: markerAreaWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 텍스트 (시간 + 라벨 + 퍼센트)
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (time.isNotEmpty)
                    Text(
                      '$time 기준', // "기준" 제거 → 너비 절약
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: markerColor.withValues(alpha: 0.8),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  Text(
                    '$label $percentage%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: markerColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 3),
            // 지시선
            Container(
              width: 10,
              height: 1.5,
              color: markerColor,
            ),
          ],
        ),
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
