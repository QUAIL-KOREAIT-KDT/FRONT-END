import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_icons.dart';
import '../config/theme.dart';
import '../services/fortune_service.dart';

/// 화면 진행 단계
enum FortunePhase { tapping, loading, result }

/// 이미지 종류별 최대 HP (mold1=3, mold2=4, mold3=5)
const List<int> _moldMaxHp = [3, 4, 5];

// 이미지 경로
const List<String> _moldImages = [
  'assets/images/fortune/mold_1.webp',
  'assets/images/fortune/mold_2.webp',
  'assets/images/fortune/mold_3.webp',
];

// 플레이스홀더 색상
const List<Color> _moldPlaceholderColors = [
  Color(0xFF8BC34A),
  Color(0xFF4CAF50),
  Color(0xFF009688),
];

/// 개별 곰팡이 데이터
class MoldItem {
  final int id;
  final double x;
  final double y;
  final double rotation;
  final double scale;
  final int imageIndex;
  int currentHp;
  bool fullyDead; // 사망 애니메이션까지 완전히 끝난 상태

  MoldItem({
    required this.id,
    required this.x,
    required this.y,
    required this.rotation,
    required this.scale,
    required this.imageIndex,
  })  : currentHp = _moldMaxHp[imageIndex],
        fullyDead = false;

  bool get isAlive => currentHp > 0;
}

// ─────────────────────────────────────────────────────────
// 개별 곰팡이 — 터치 시 해당 곰팡이만 rebuild
// ─────────────────────────────────────────────────────────
class _MoldWidget extends StatefulWidget {
  final MoldItem mold;
  final double posX;
  final double posY;
  final double moldSize;
  final VoidCallback onDied; // 사망 애니메이션 완료 시
  final VoidCallback onHit; // 피격(HP 감소) 시

  const _MoldWidget({
    required Key key,
    required this.mold,
    required this.posX,
    required this.posY,
    required this.moldSize,
    required this.onDied,
    required this.onHit,
  }) : super(key: key);

  @override
  State<_MoldWidget> createState() => _MoldWidgetState();
}

class _MoldWidgetState extends State<_MoldWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  _MoldAnimState _animState = _MoldAnimState.idle;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this);
    _animController.addStatusListener(_onAnimStatus);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onAnimStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      if (_animState == _MoldAnimState.dying) {
        widget.onDied();
      }
      if (mounted) {
        setState(() => _animState = _MoldAnimState.idle);
      }
    }
  }

  void playHit() {
    if (!mounted) return;
    _animController.duration = const Duration(milliseconds: 280);
    _animState = _MoldAnimState.hit;
    _animController.forward(from: 0);
    setState(() {});
  }

  void playDeath() {
    if (!mounted) return;
    _animController.duration = const Duration(milliseconds: 380);
    _animState = _MoldAnimState.dying;
    _animController.forward(from: 0);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mold = widget.mold;
    final size = widget.moldSize;

    // HP 관계없이 항상 동일한 외형 표시
    final Widget image = _MoldImage(
      imageIndex: mold.imageIndex,
      size: size,
    );

    // 사망 애니메이션: 살짝 커졌다 쏙 빠짐
    if (_animState == _MoldAnimState.dying) {
      return Positioned(
        left: widget.posX,
        top: widget.posY,
        child: AnimatedBuilder(
          animation: _animController,
          child: Transform.rotate(angle: mold.rotation, child: image),
          builder: (context, child) {
            final v = _animController.value;
            final double scale;
            final double opacity;
            if (v < 0.25) {
              scale = 1.0 + (v / 0.25) * 0.15;
              opacity = 1.0;
            } else {
              final t = (v - 0.25) / 0.75;
              scale = 1.15 * (1.0 - t);
              opacity = 1.0 - t;
            }
            return Transform.scale(
              scale: scale,
              child: Opacity(opacity: opacity.clamp(0.0, 1.0), child: child),
            );
          },
        ),
      );
    }

    // 피격 흔들림 애니메이션
    if (_animState == _MoldAnimState.hit) {
      return Positioned(
        left: widget.posX,
        top: widget.posY,
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedBuilder(
            animation: _animController,
            child: Transform.rotate(angle: mold.rotation, child: image),
            builder: (context, child) {
              final shake = sin(_animController.value * pi * 4) * 5.0;
              return Transform.translate(
                  offset: Offset(shake, 0), child: child);
            },
          ),
        ),
      );
    }

    // 기본 상태
    return Positioned(
      left: widget.posX,
      top: widget.posY,
      child: GestureDetector(
        onTap: _handleTap,
        child: Transform.rotate(angle: mold.rotation, child: image),
      ),
    );
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    final mold = widget.mold;
    setState(() => mold.currentHp -= 1);
    widget.onHit();

    if (mold.currentHp <= 0) {
      playDeath();
    } else {
      playHit();
    }
  }
}

enum _MoldAnimState { idle, hit, dying }

// ─────────────────────────────────────────────────────────
// 곰팡이 이미지 (HP 관련 로직 제거)
// ─────────────────────────────────────────────────────────
class _MoldImage extends StatelessWidget {
  final int imageIndex;
  final double size;

  const _MoldImage({
    required this.imageIndex,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        _moldImages[imageIndex],
        width: size,
        height: size,
        fit: BoxFit.contain,
        cacheWidth: (size * 2).toInt(),
        errorBuilder: (_, __, ___) => _Placeholder(
          size: size,
          color: _moldPlaceholderColors[imageIndex],
        ),
      ),
    );
  }
}

// 플레이스홀더
class _Placeholder extends StatelessWidget {
  final double size;
  final Color color;

  const _Placeholder({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.75),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text('🦠', style: TextStyle(fontSize: size * 0.45)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 메인 화면
// ─────────────────────────────────────────────────────────
class FortuneScreen extends StatefulWidget {
  const FortuneScreen({super.key});

  @override
  State<FortuneScreen> createState() => _FortuneScreenState();
}

class _FortuneScreenState extends State<FortuneScreen>
    with SingleTickerProviderStateMixin {
  final FortuneService _fortuneService = FortuneService();
  final Random _random = Random();

  FortunePhase _phase = FortunePhase.tapping;
  late List<MoldItem> _molds;

  // 살아있는 곰팡이 수 (모두 제거 감지용)
  int _aliveCount = 0;

  // GlobalKey: 위젯 트리 제거 판단 시 null-safe 접근용
  final List<GlobalKey<_MoldWidgetState>> _moldKeys = [];

  FortuneResponse? _fortuneResult;
  late final String _formattedDate;

  late final AnimationController _resultAnimController;
  late final Animation<double> _resultSlideAnim;
  late final Animation<double> _resultFadeAnim;

  // LayoutBuilder 측정값 캐싱
  double _cachedAreaSize = 0;
  double _cachedTotalWidth = 0;

  @override
  void initState() {
    super.initState();
    _formattedDate = _formatDate(DateTime.now());
    _molds = [];

    _resultAnimController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _resultSlideAnim = Tween<double>(begin: 80.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _resultAnimController, curve: Curves.easeOutCubic),
    );
    _resultFadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultAnimController, curve: Curves.easeOut),
    );

    _checkTodayFortune();
  }

  @override
  void dispose() {
    _resultAnimController.dispose();
    super.dispose();
  }

  Future<void> _checkTodayFortune() async {
    final prefs = await SharedPreferences.getInstance();
    final savedDate = prefs.getString('fortune_date');
    final today = DateTime.now().toIso8601String().substring(0, 10);

    if (savedDate == today) {
      final savedResult = prefs.getString('fortune_result');
      if (savedResult != null) {
        final json = jsonDecode(savedResult) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _fortuneResult = FortuneResponse.fromJson(json);
            _phase = FortunePhase.result;
          });
          _resultAnimController.forward();
        }
        return;
      }
    }
    _generateMolds();
  }

  void _generateMolds() {
    const count = 27;
    _moldKeys.clear();
    final molds = <MoldItem>[];
    final placed = <List<double>>[]; // 배치된 곰팡이 중심 좌표 (0~1 정규화)
    const double minDist = 0.15; // 곰팡이 간 최소 거리 (정규화 좌표)
    const double circleRadius = 0.44; // 원형 영역 반지름
    const double circleCenterX = 0.50;
    const double circleCenterY = 0.50;

    for (int i = 0; i < count; i++) {
      _moldKeys.add(GlobalKey<_MoldWidgetState>());

      double x = 0, y = 0;
      bool valid = false;

      // 원형 영역 내에서 최소 거리를 유지하며 배치 (최대 200회 시도)
      for (int attempt = 0; attempt < 200; attempt++) {
        // 원형 영역 내 균등 분포: 각도 + 반지름 제곱근 방식
        final angle = _random.nextDouble() * 2 * pi;
        final r = circleRadius * sqrt(_random.nextDouble());
        x = circleCenterX + r * cos(angle);
        y = circleCenterY + r * sin(angle);

        // 영역 경계 체크 (0~1 범위)
        if (x < 0.02 || x > 0.98 || y < 0.02 || y > 0.98) continue;

        // 기존 곰팡이와의 최소 거리 체크
        bool tooClose = false;
        for (final p in placed) {
          final dx = x - p[0];
          final dy = y - p[1];
          if (dx * dx + dy * dy < minDist * minDist) {
            tooClose = true;
            break;
          }
        }
        if (!tooClose) {
          valid = true;
          break;
        }
      }

      // 200회 안에 못 찾으면 거리 조건 완화하여 재시도
      if (!valid) {
        for (int attempt = 0; attempt < 100; attempt++) {
          final angle = _random.nextDouble() * 2 * pi;
          final r = circleRadius * sqrt(_random.nextDouble());
          x = circleCenterX + r * cos(angle);
          y = circleCenterY + r * sin(angle);
          if (x >= 0.02 && x <= 0.98 && y >= 0.02 && y <= 0.98) break;
        }
      }

      placed.add([x, y]);
      molds.add(MoldItem(
        id: i,
        x: x,
        y: y,
        rotation: (_random.nextDouble() - 0.5) * 0.7,
        scale: 0.75 + _random.nextDouble() * 0.5,
        imageIndex: _random.nextInt(_moldImages.length),
      ));
    }

    setState(() {
      _molds = molds;
      _aliveCount = count;
      _phase = FortunePhase.tapping;
    });
  }

  void _onMoldDied(MoldItem mold) {
    mold.fullyDead = true;
    _aliveCount -= 1;
    // setState로 죽은 곰팡이를 즉시 위젯 트리에서 제거
    if (mounted) setState(() {});
    if (_aliveCount == 0) {
      _onAllMoldsRemoved();
    }
  }

  void _onMoldHit() {
    // 카운터 UI 제거됐으므로 setState 불필요
  }

  Future<void> _onAllMoldsRemoved() async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    setState(() => _phase = FortunePhase.loading);

    try {
      final result = await _fortuneService.getTodayFortune();
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await prefs.setString('fortune_date', today);
      await prefs.setString(
          'fortune_result',
          jsonEncode({
            'score': result.score,
            'status': result.status,
            'message': result.message,
          }));

      if (mounted) {
        setState(() {
          _fortuneResult = result;
          _phase = FortunePhase.result;
        });
        _resultAnimController.forward();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fortuneResult = FortuneResponse.dummy();
          _phase = FortunePhase.result;
        });
        _resultAnimController.forward();
      }
    }
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
            stops: [0.0, 0.5],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.gray700,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Row(
            children: [
              Icon(AppIcons.fortune, size: 24, color: AppTheme.mintPrimary),
              SizedBox(width: 8),
              Text(
                '오늘의 팡이',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (kDebugMode)
            IconButton(
              onPressed: _debugClearCache,
              tooltip: '캐시 초기화 (개발용)',
              icon: const Icon(
                Icons.bug_report_outlined,
                color: AppTheme.gray400,
                size: 20,
              ),
            ),
          IconButton(
            onPressed: () => _showHelpModal(context),
            tooltip: '도움말',
            icon: const Icon(
              Icons.help_outline_rounded,
              color: AppTheme.gray500,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _debugClearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fortune_date');
    await prefs.remove('fortune_result');

    if (!mounted) return;

    _resultAnimController.reset();
    setState(() {
      _fortuneResult = null;
      _phase = FortunePhase.tapping;
    });
    _generateMolds();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('[DEV] 캐시 초기화 완료'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.black87,
      ),
    );
  }

  void _showHelpModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppTheme.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text(
              '🧫 오늘의 팡이란?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '매일 화면에 나타나는 곰팡이를 터치해서\n'
              '모두 제거하면 오늘의 팡이력(운세)을\n'
              '확인할 수 있어요!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.gray600,
                height: 1.7,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.mintLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  _HelpRow(emoji: '👆', text: '화면을 터치하면 곰팡이가 제거돼요'),
                  SizedBox(height: 10),
                  _HelpRow(emoji: '🔢', text: '곰팡이마다 필요한 터치 횟수가 달라요'),
                  SizedBox(height: 10),
                  _HelpRow(emoji: '✨', text: '모두 제거하면 오늘의 운세가 나타나요'),
                  SizedBox(height: 10),
                  _HelpRow(emoji: '📅', text: '하루에 한 번만 확인할 수 있어요'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  backgroundColor: AppTheme.mintPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  '확인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_phase) {
      case FortunePhase.tapping:
        return _buildTappingPhase();
      case FortunePhase.loading:
        return _buildLoadingPhase();
      case FortunePhase.result:
        return _buildResultPhase();
    }
  }

  Widget _buildTappingPhase() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          _formattedDate,
          style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
        ),
        const SizedBox(height: 8),
        const Text(
          '오늘의 팡이력은?',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.gray800,
          ),
        ),
        const SizedBox(height: 16),

        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (_cachedTotalWidth != constraints.maxWidth) {
                _cachedTotalWidth = constraints.maxWidth;
                _cachedAreaSize = constraints.maxWidth * 0.92;
              }
              final areaSize = _cachedAreaSize;
              final totalWidth = _cachedTotalWidth;

              final availableHeight = constraints.maxHeight;

              return GestureDetector(
                onTap: _tapRandomAliveMold,
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // 배경 원 — RepaintBoundary로 터치 시 재paint 방지
                    RepaintBoundary(
                      child: Center(
                        child: Container(
                          width: areaSize,
                          height: areaSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [AppTheme.pinkLight2, AppTheme.pinkLight],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.pinkPrimary
                                    .withValues(alpha: 0.15),
                                blurRadius: 30,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    ..._buildMoldWidgets(totalWidth, areaSize, availableHeight),
                  ],
                ),
              );
            },
          ),
        ),

        // 안내 문구만 표시 (카운터 제거)
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Text(
            '곰팡이를 터치해서 떼어내세요!',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
            ),
          ),
        ),
      ],
    );
  }

  /// 살아있는 곰팡이 중 랜덤으로 하나를 타격 (화면 아무 곳 탭 시)
  void _tapRandomAliveMold() {
    final aliveIndices = [
      for (int i = 0; i < _molds.length; i++)
        if (!_molds[i].fullyDead && _molds[i].isAlive) i,
    ];
    if (aliveIndices.isEmpty) return;
    final idx = aliveIndices[_random.nextInt(aliveIndices.length)];
    _moldKeys[idx].currentState?._handleTap();
  }

  List<Widget> _buildMoldWidgets(
      double totalWidth, double areaSize, double availableHeight) {
    final result = <Widget>[];
    for (int i = 0; i < _molds.length; i++) {
      final mold = _molds[i];

      // fullyDead == true면 위젯 트리에서 완전히 제거
      if (mold.fullyDead) continue;

      final moldSize = 100.0 * mold.scale; // 27마리에 맞게 크기 조정
      final offsetX = (totalWidth - areaSize) / 2;
      final offsetY = (availableHeight - areaSize) / 2; // 분홍 원과 수직 정렬
      // 중심 좌표 기준 배치 (mold.x, mold.y는 0~1 정규화 좌표)
      final posX = offsetX + mold.x * areaSize - moldSize / 2;
      final posY = offsetY + mold.y * areaSize - moldSize / 2;

      result.add(_MoldWidget(
        key: _moldKeys[i],
        mold: mold,
        posX: posX,
        posY: posY,
        moldSize: moldSize,
        onDied: () => _onMoldDied(mold),
        onHit: _onMoldHit,
      ));
    }
    return result;
  }

  Widget _buildLoadingPhase() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.mintPrimary),
            ),
          ),
          SizedBox(height: 24),
          Text(
            '팡이가 오늘의 운세를 점치는 중...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultPhase() {
    if (_fortuneResult == null) return const SizedBox.shrink();
    final result = _fortuneResult!;

    return AnimatedBuilder(
      animation: _resultAnimController,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text(
              _formattedDate,
              style: const TextStyle(fontSize: 14, color: AppTheme.gray500),
            ),
            const SizedBox(height: 8),
            const Text(
              '오늘의 팡이력은?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppTheme.gray800,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [
                        Color(result.colorValue),
                        Color(result.colorValue).withValues(alpha: 0.7),
                      ],
                    ).createShader(bounds),
                    child: Text(
                      '${result.score}%',
                      style: const TextStyle(
                        fontSize: 64,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '팡이력',
                    style: TextStyle(fontSize: 16, color: AppTheme.gray500),
                  ),
                  const SizedBox(height: 20),
                  Container(height: 1, color: AppTheme.gray200),
                  const SizedBox(height: 20),
                  Text(
                    '${result.emoji} ${result.status}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.gray800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    result.message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.gray500,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _resultSlideAnim.value),
          child: Opacity(opacity: _resultFadeAnim.value, child: child),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    const weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
  }
}

/// 도움말 모달 내 항목 행
class _HelpRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _HelpRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.gray700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
