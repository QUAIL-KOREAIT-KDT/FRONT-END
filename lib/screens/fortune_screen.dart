import 'package:flutter/material.dart';
import '../config/theme.dart';

class FortuneScreen extends StatefulWidget {
  const FortuneScreen({super.key});

  @override
  State<FortuneScreen> createState() => _FortuneScreenState();
}

class _FortuneScreenState extends State<FortuneScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  // 더미 데이터 - 실제로는 Provider나 API에서 가져옴
  final int _riskPercentage = 23;
  final String _statusEmoji = '🎉';
  final String _statusTitle = '뽀송뽀송한 하루!';
  final String _statusMessage = '오늘은 곰팡이 걱정 없이\n상쾌한 하루를 보낼 수 있어요!';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
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
          child: SingleChildScrollView(
            child: Column(
              children: [
                // 헤더
                _buildHeader(context),

                const SizedBox(height: 16),

                // 날짜
                Text(
                  _formatDate(now),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray500,
                  ),
                ),

                const SizedBox(height: 8),

                // 타이틀
                const Text(
                  '오늘의 팡이력은?',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.gray800,
                  ),
                ),

                const SizedBox(height: 32),

                // 캐릭터 영역
                _buildCharacterSection(),

                const SizedBox(height: 32),

                // 팡이력 카드
                _buildRiskCard(),

                const SizedBox(height: 24),

                // 팡이털기 버튼
                _buildShakeButton(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final weekdays = ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'];
    return '${date.year}년 ${date.month}월 ${date.day}일 ${weekdays[date.weekday - 1]}';
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppTheme.gray700,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          // 타이틀
          Row(
            children: [
              const Text(
                '🧫',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 8),
              const Text(
                '오늘의 팡이',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.gray800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharacterSection() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 배경 원
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.pinkLight2,
                      AppTheme.pinkLight,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.pinkPrimary.withOpacity(0.2),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              ),
              // 캐릭터 플레이스홀더
              Column(
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    child: const Center(
                      child: Text(
                        '팡이 캐릭터',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // 장식 요소들
              Positioned(
                top: 10,
                right: 30,
                child: Text('✨', style: TextStyle(fontSize: 24)),
              ),
              Positioned(
                top: 40,
                left: 20,
                child: Text('🌟', style: TextStyle(fontSize: 18)),
              ),
              Positioned(
                bottom: 30,
                left: 10,
                child: Text('⭐', style: TextStyle(fontSize: 20)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRiskCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // 퍼센티지
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [AppTheme.mintPrimary, AppTheme.safe],
            ).createShader(bounds),
            child: Text(
              '$_riskPercentage%',
              style: const TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(height: 4),

          Text(
            '팡이력',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray500,
            ),
          ),

          const SizedBox(height: 20),

          // 구분선
          Container(
            height: 1,
            color: AppTheme.gray200,
          ),

          const SizedBox(height: 20),

          // 상태 메시지
          Text(
            '$_statusEmoji $_statusTitle',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShakeButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            // TODO: 팡이털기 기능 구현
            _showShakeDialog();
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.gray200),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.pinkLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      '📱',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '팡이 털기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.gray800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '휴대폰을 흔들어서 곰팡이를 털어보세요!',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 18,
                  color: AppTheme.gray400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showShakeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          '📱 팡이 털기',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          '휴대폰을 흔들어서\n곰팡이를 털어보세요!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
