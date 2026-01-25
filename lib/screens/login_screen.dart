import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/routes.dart';
import '../providers/auth_provider.dart';

// 개발 모드 여부 확인용
bool get _isDevMode => AuthProvider.isDevMode;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleKakaoLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.loginWithKakao();

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // 로그인 성공 시 온보딩 또는 홈으로 이동
        final user = authProvider.user;
        if (user != null && user.isOnboardingCompleted) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        }
      } else {
        // 로그인 실패 시 에러 메시지
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
            backgroundColor: AppTheme.danger,
          ),
        );
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
            colors: [
              AppTheme.mintLight,
              Colors.white,
              AppTheme.pinkLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),

              // 로고 및 캐릭터
              Column(
                children: [
                  // 로고 이미지
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.mintLight2,
                          AppTheme.pinkLight2,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.mintPrimary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Image.asset(
                          'assets/images/character/pangpangpang_logo_small.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Text('🧚', style: TextStyle(fontSize: 80)),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // 앱 이름
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppTheme.mintPrimary, AppTheme.pinkPrimary],
                    ).createShader(bounds),
                    child: const Text(
                      '팡팡팡',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 슬로건
                  Text(
                    '곰팡이 없는 쾌적한 우리 집',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.gray600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 로그인 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // 카카오 로그인 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleKakaoLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFEE500), // 카카오 노란색
                          foregroundColor: const Color(0xFF3C1E1E),
                          elevation: 0,
                          shadowColor: Colors.black.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF3C1E1E),
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/icons/kakao_logo.png',
                                    width: 24,
                                    height: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      // 로고 이미지가 없을 경우 텍스트로 대체
                                      return const Text(
                                        '💬',
                                        style: TextStyle(fontSize: 20),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _isDevMode ? '🔧 개발 모드로 시작하기' : '카카오로 시작하기',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 안내 문구
                    Text(
                      '카카오 계정으로 간편하게 시작하세요',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
