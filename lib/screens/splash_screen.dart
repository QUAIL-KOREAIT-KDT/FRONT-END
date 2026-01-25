import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // 자동 로그인 체크
    _checkAutoLogin();
  }

  Future<void> _checkAutoLogin() async {
    // 애니메이션 완료 대기
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    try {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = await authProvider.autoLogin().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('자동 로그인 타임아웃');
          return false;
        },
      );

      if (!mounted) return;

      if (isLoggedIn) {
        // 자동 로그인 성공
        final user = authProvider.user;
        if (user != null && user.isOnboardingCompleted) {
          // 온보딩 완료한 사용자 → 홈으로
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          // 온보딩 미완료 사용자 → 온보딩으로
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      } else {
        // 자동 로그인 실패 → 로그인 화면으로
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    } catch (e) {
      debugPrint('자동 로그인 에러: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.mintLight,
              Colors.white,
              AppTheme.pinkLight,
            ],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 캐릭터
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.mintLight2,
                              AppTheme.pinkLight2,
                            ],
                          ),
                          border: Border.all(
                            color: AppTheme.mintPrimary.withValues(alpha: 0.5),
                            width: 4,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🧚',
                            style: TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // 로고
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [AppTheme.mintPrimary, AppTheme.pinkPrimary],
                        ).createShader(bounds),
                        child: const Text(
                          '팡팡팡',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '곰팡이 없는 쾌적한 우리 집',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
