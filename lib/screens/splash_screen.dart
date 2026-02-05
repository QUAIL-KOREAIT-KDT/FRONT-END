import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
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

    // 네이티브 스플래시 화면 제거
    FlutterNativeSplash.remove();

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
    try {
      // 애니메이션 완료 대기
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();

      // 자동 로그인 시도 (타임아웃 3초로 단축)
      bool isLoggedIn = false;
      try {
        isLoggedIn = await authProvider.autoLogin().timeout(
          const Duration(seconds: 3),
          onTimeout: () {
            debugPrint('⚠️ 자동 로그인 타임아웃 - 로그인 화면으로 이동');
            return false;
          },
        );
      } catch (e) {
        debugPrint('⚠️ 자동 로그인 실패: $e');
        isLoggedIn = false;
      }

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
      // 최종 안전장치: 어떤 에러가 나도 로그인 화면으로
      debugPrint('❌ Splash 화면 에러: $e');
      if (mounted) {
        try {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        } catch (navError) {
          debugPrint('❌ Navigator 에러: $navError');
        }
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
                      // 캐릭터 로고
                      Image.asset(
                        'assets/images/character/pangpangpang_logo_small.png',
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
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
