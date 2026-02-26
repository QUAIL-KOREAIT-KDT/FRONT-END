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

  Widget _buildHighScore() {
    // TODO: SharedPreferences에서 최고 점수 불러오기
    const highScore = 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFFD700).withOpacity(0.2),
            const Color(0xFFFFA500).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFFFD700).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('👑', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '최고 기록',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.gray500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '$highScore점',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF8C00),
                ),
              ),
            ],
          ),
        ],
      ),
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
              _buildHelpItem('5', '올클리어 시 보너스 500점!'),
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
