import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../utils/game/game_logic.dart';

/// 게임 결과 화면
class MoldGameResultScreen extends StatefulWidget {
  const MoldGameResultScreen({super.key});

  @override
  State<MoldGameResultScreen> createState() => _MoldGameResultScreenState();
}

class _MoldGameResultScreenState extends State<MoldGameResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _scoreController;
  late Animation<int> _scoreAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  int _score = 0;
  int _removedCount = 0;
  int _maxCombo = 0;
  int _highScore = 0;
  bool _isNewRecord = false;

  bool _isRestartingGame = false;

  @override
  void initState() {
    super.initState();
    // 가로 모드 유지
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadArguments();
    });
  }

  void _loadArguments() {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      setState(() {
        _score = args['score'] ?? 0;
        _removedCount = args['removedCount'] ?? 0;
        _maxCombo = args['maxCombo'] ?? 0;
        _highScore = args['highScore'] ?? 0;
        _isNewRecord = args['isNewRecord'] ?? false;
      });

      _scoreAnimation = IntTween(begin: 0, end: _score).animate(
        CurvedAnimation(parent: _scoreController, curve: Curves.easeOut),
      );

      _fadeController.forward();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scoreController.forward();
      });
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _fadeController.dispose();
    // 다시하기가 아닌 경우에만 세로 모드로 복원
    if (!_isRestartingGame) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(flex: 1),

                // 결과 타이틀
                _buildResultTitle(),

                const SizedBox(height: 40),

                // 점수 표시
                _buildScoreDisplay(),

                const SizedBox(height: 32),

                // 상세 통계
                _buildStats(),

                const Spacer(flex: 2),

                // 버튼들
                _buildButtons(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultTitle() {
    return Column(
      children: [
        if (_isNewRecord) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD700).withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🎉', style: TextStyle(fontSize: 24)),
                SizedBox(width: 8),
                Text(
                  '신기록 달성!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 8),
                Text('🎉', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        const Text(
          '게임 종료!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppTheme.gray800,
          ),
        ),
      ],
    );
  }

  Widget _buildScoreDisplay() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.mintLight,
            AppTheme.mintPrimary.withOpacity(0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.mintPrimary.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '최종 점수',
            style: TextStyle(
              fontSize: 18,
              color: AppTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: _scoreController,
            builder: (context, child) {
              final displayScore =
                  _scoreController.isAnimating ? _scoreAnimation.value : _score;
              return Text(
                GameLogic.formatScore(displayScore),
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.gray800,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildStatRow(
            icon: '🍄',
            label: '제거한 곰팡이',
            value: '$_removedCount개',
          ),
          const Divider(height: 24),
          _buildStatRow(
            icon: '🔥',
            label: '최대 콤보',
            value: '×$_maxCombo',
          ),
          const Divider(height: 24),
          _buildStatRow(
            icon: '👑',
            label: '최고 기록',
            value: GameLogic.formatScore(_isNewRecord ? _score : _highScore),
            highlight: _isNewRecord,
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
    bool highlight = false,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: highlight ? const Color(0xFFFF8C00) : AppTheme.gray800,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        // 다시 하기 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              _isRestartingGame = true;
              // 가로 모드로 설정 후 게임 시작
              SystemChrome.setPreferredOrientations([
                DeviceOrientation.landscapeLeft,
                DeviceOrientation.landscapeRight,
              ]).then((_) {
                Navigator.pushReplacementNamed(context, AppRoutes.moldGamePlay);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.mintPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              shadowColor: AppTheme.mintPrimary.withOpacity(0.4),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.refresh_rounded, size: 24),
                SizedBox(width: 8),
                Text(
                  '다시 하기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // 홈으로 버튼
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              Navigator.popUntil(
                context,
                (route) =>
                    route.settings.name == AppRoutes.main ||
                    route.settings.name == AppRoutes.moldGame ||
                    route.isFirst,
              );
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.gray700,
              side: BorderSide(color: AppTheme.gray300, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_rounded, size: 24),
                SizedBox(width: 8),
                Text(
                  '홈으로',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
