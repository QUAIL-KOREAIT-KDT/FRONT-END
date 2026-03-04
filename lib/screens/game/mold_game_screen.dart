import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// 게임 진입 화면 (게임 시작 전)
class MoldGameScreen extends StatelessWidget {
  const MoldGameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.gray700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // 게임 로고/타이틀
              _buildGameLogo(),

              const SizedBox(height: 48),

              // 게임 설명
              _buildGameDescription(),

              const Spacer(flex: 2),

              // 게임 시작 버튼
              _buildStartButton(context),

              const SizedBox(height: 16),

              // 게임 방법 버튼
              _buildHelpButton(context),

              const SizedBox(height: 8),

              // 랭킹 버튼
              _buildRankingButton(context),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameLogo() {
    return Column(
      children: [
        // 팡팡팡 로고 이미지
        Image.asset(
          'assets/images/character/pangpangpang_logo_small.webp',
          width: 120,
          height: 120,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.mintLight, AppTheme.mintPrimary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🍄', style: TextStyle(fontSize: 60)),
            ),
          ),
        ),
        const SizedBox(height: 24),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              AppTheme.mintPrimary,
              const Color(0xFF4CAF50),
            ],
          ).createShader(bounds),
          child: const Text(
            '곰팡이 팡!',
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGameDescription() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildDescriptionItem(
            '🎯',
            '드래그로 곰팡이를 묶어서',
          ),
          const SizedBox(height: 12),
          _buildDescriptionItem(
            '🔢',
            '합이 10이 되면 "팡!" 터짐',
          ),
          const SizedBox(height: 12),
          _buildDescriptionItem(
            '⏱️',
            '100초 안에 최대한 많이 터뜨리세요!',
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem(String emoji, String text) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.moldGamePlay);
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
            Icon(Icons.play_arrow_rounded, size: 28),
            SizedBox(width: 8),
            Text(
              '게임 시작',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankingButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, AppRoutes.gameRanking),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.leaderboard_rounded, color: const Color(0xFFFFD700)),
          const SizedBox(width: 8),
          Text(
            '랭킹',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFFFFD700),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpButton(BuildContext context) {
    return TextButton(
      onPressed: () => _showHelpDialog(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.help_outline_rounded, color: AppTheme.gray500),
          const SizedBox(width: 8),
          Text(
            '게임 방법',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('📖', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('게임 방법'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('1', '드래그로 곰팡이들을 묶으세요'),
              _buildHelpItem('2', '묶은 곰팡이 숫자의 합이 10이 되면 터집니다'),
              _buildHelpItem('3', '2개: 10점, 3개: 30점, 4개: 60점'),
              _buildHelpItem('4', '5개 이상: 개수 × 20점'),
              _buildHelpItem('5', '연속으로 터뜨릴수록 콤보 점수가 올라갑니다'),
              const SizedBox(height: 8),
              const Divider(),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '주의! 처음 곰팡이를 제거하면 빈 자리에 새 곰팡이가 6~8초마다 1마리씩 나타납니다.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Widget _buildHelpItem(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppTheme.mintPrimary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.gray700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
