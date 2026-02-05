import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../services/api_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _isLoadingNotification = true;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  /// 알림 설정 조회
  Future<void> _loadNotificationSettings() async {
    try {
      final response = await _apiService.dio.get('/notifications/settings');
      if (mounted) {
        setState(() {
          _notificationEnabled = response.data['notification_enabled'] ?? true;
          _isLoadingNotification = false;
        });
      }
    } catch (e) {
      debugPrint('[Settings] 알림 설정 조회 실패: $e');
      if (mounted) {
        setState(() {
          _isLoadingNotification = false;
        });
      }
    }
  }

  /// 알림 설정 변경
  Future<void> _updateNotificationSettings(bool enabled) async {
    setState(() {
      _notificationEnabled = enabled;
    });

    try {
      await _apiService.dio.put('/notifications/settings', data: {
        'notification_enabled': enabled,
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(enabled ? '알림이 활성화되었습니다.' : '알림이 비활성화되었습니다.'),
            backgroundColor: AppTheme.mintPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } on DioException catch (e) {
      debugPrint('[Settings] 알림 설정 변경 실패: $e');
      // 실패 시 원래 상태로 롤백
      if (mounted) {
        setState(() {
          _notificationEnabled = !enabled;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('알림 설정 변경에 실패했습니다.'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(context),

            // 설정 메뉴
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 알림 섹션
                    _buildSectionTitle('알림'),
                    _buildNotificationToggleItem(),

                    const SizedBox(height: 24),

                    // 앱 정보 섹션
                    _buildSectionTitle('앱 정보'),
                    _buildSettingItem(
                      icon: Icons.info_outline_rounded,
                      title: '앱 버전',
                      trailing: Text(
                        '1.0.0',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.gray400,
                        ),
                      ),
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: '이용약관',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보 처리방침',
                      onTap: () {},
                    ),
                    _buildSettingItem(
                      icon: Icons.help_outline_rounded,
                      title: '도움말',
                      onTap: () {},
                    ),

                    const SizedBox(height: 24),

                    // 로그아웃
                    _buildSettingItem(
                      icon: Icons.logout_rounded,
                      title: '로그아웃',
                      titleColor: AppTheme.danger,
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.gray800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.gray400,
        ),
      ),
    );
  }

  /// 알림 설정 토글 아이템
  Widget _buildNotificationToggleItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 24,
                color: AppTheme.gray600,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '알림 수신',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.gray800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _notificationEnabled
                          ? '곰팡이 예방 알림을 받습니다'
                          : '알림이 꺼져있습니다',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoadingNotification)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppTheme.mintPrimary,
                  ),
                )
              else
                Switch(
                  value: _notificationEnabled,
                  onChanged: _updateNotificationSettings,
                  activeColor: AppTheme.mintPrimary,
                  activeTrackColor: AppTheme.mintLight,
                  inactiveThumbColor: AppTheme.gray400,
                  inactiveTrackColor: AppTheme.gray200,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppTheme.gray100,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: titleColor ?? AppTheme.gray600,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: titleColor ?? AppTheme.gray800,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.gray400,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing
                else
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.gray400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppTheme.gray500),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.onboarding,
                (route) => false,
              );
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppTheme.danger),
            ),
          ),
        ],
      ),
    );
  }
}
