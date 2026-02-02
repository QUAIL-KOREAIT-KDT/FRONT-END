import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';

class HamburgerMenu extends StatefulWidget {
  const HamburgerMenu({super.key});

  @override
  State<HamburgerMenu> createState() => _HamburgerMenuState();
}

class _HamburgerMenuState extends State<HamburgerMenu>
    with SingleTickerProviderStateMixin {
  late AnimationController _badgeAnimController;
  late Animation<double> _badgeGlowAnimation;

  @override
  void initState() {
    super.initState();
    _badgeAnimController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _badgeGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _badgeAnimController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _badgeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 프로필 섹션
            _buildProfileSection(context),

            const SizedBox(height: 16),

            // 메뉴 아이템들
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMenuItem(
                      context,
                      icon: Icons.emoji_emotions_rounded,
                      iconColor: AppTheme.pinkPrimary,
                      label: '오늘의 팡이',
                      route: AppRoutes.fortune,
                      badge: 'HOT',
                      badgeColors: const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                      badgeIcon: '🔥',
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.videogame_asset_rounded,
                      iconColor: const Color(0xFF4CAF50),
                      label: '팡이 게임',
                      route: AppRoutes.moldGame,
                      badge: 'NEW',
                      badgeColors: const [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                      badgeIcon: '🍄',
                    ),
                    const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.settings_rounded,
                      iconColor: AppTheme.gray400,
                      label: '설정',
                      route: AppRoutes.settings,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.home_rounded,
                      iconColor: AppTheme.mintPrimary,
                      label: '집 정보 수정',
                      route: AppRoutes.homeInfo,
                    ),
                    _buildMenuItem(
                      context,
                      icon: Icons.devices_rounded,
                      iconColor: AppTheme.mintPrimary,
                      label: '스마트홈 연동',
                      route: AppRoutes.iotSettings,
                      badge: 'BETA',
                      badgeColors: const [Color(0xFF7C83FD), Color(0xFFA78BFA)],
                      badgeIcon: '🧪',
                    ),
                  ],
                ),
              ),
            ),

            // 하단 메뉴
            _buildBottomSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.mintLight,
                  AppTheme.pinkLight,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.person_rounded,
                color: AppTheme.gray400,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 사용자 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '회원님',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'user@kakao.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String route,
    String? badge,
    List<Color>? badgeColors,
    String? badgeIcon,
  }) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    final isSelected = currentRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: isSelected ? AppTheme.mintLight : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.pop(context); // 드로어 닫기
            if (currentRoute != route) {
              Navigator.pushNamed(context, route);
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // 아이콘 배경
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // 라벨
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? AppTheme.mintPrimary : AppTheme.gray700,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(width: 8),
                  _buildAnimatedBadge(
                    badge,
                    badgeColors ?? const [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                    badgeIcon,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBadge(
    String text,
    List<Color> colors,
    String? icon,
  ) {
    return AnimatedBuilder(
      animation: _badgeGlowAnimation,
      builder: (context, child) {
        final glowOpacity = 0.40 + (_badgeGlowAnimation.value * 0.25);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: colors.first.withOpacity(glowOpacity),
                blurRadius: 8,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Text(
                  icon,
                  style: const TextStyle(fontSize: 10),
                ),
                const SizedBox(width: 2),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 도움말
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                // TODO: 도움말 페이지로 이동
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      '?',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.pinkPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '도움말',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          // 로그아웃
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRoutes.onboarding,
                    (route) => false,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppTheme.gray400,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '로그아웃',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
