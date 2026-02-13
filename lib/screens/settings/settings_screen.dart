import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
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
                      onTap: () => _showTermsDialog(context),
                    ),
                    _buildSettingItem(
                      icon: Icons.privacy_tip_outlined,
                      title: '개인정보 처리방침',
                      onTap: () => _showPrivacyDialog(context),
                    ),
                    _buildSettingItem(
                      icon: Icons.help_outline_rounded,
                      title: '도움말',
                      onTap: () => _showHelpDialog(context),
                    ),

                    const SizedBox(height: 24),

                    // 계정 섹션
                    _buildSectionTitle('계정'),
                    _buildSettingItem(
                      icon: Icons.person_remove_rounded,
                      title: '회원탈퇴',
                      titleColor: Colors.red.shade400,
                      onTap: () => _showWithdrawDialog(context),
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

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.gray800,
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.gray600,
              height: 1.6,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '확인',
              style: TextStyle(color: AppTheme.mintPrimary),
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    _showInfoDialog(context, '이용약관', '''
팡팡팡 서비스 이용 약관

제1조 (목적)
본 약관은 팡팡팡(이하 "서비스")이 제공하는 곰팡이 위험도 예측 서비스의 이용 조건 및 절차에 관한 사항을 규정합니다.

제2조 (서비스 내용)
서비스는 기상청 공공 데이터를 기반으로 실내 곰팡이 발생 위험도를 예측하며, 환기 추천 시간대 안내, 곰팡이 정보 사전 등의 기능을 제공합니다.

제3조 (면책 사항)
본 서비스의 위험도 수치는 기상청 예보 데이터와 통계 모델을 활용한 예측값이며, 실제 환경과 차이가 있을 수 있습니다. 서비스 정보는 참고 용도로만 활용해 주시기 바랍니다.

제4조 (이용자의 의무)
이용자는 서비스를 정상적인 용도로 사용해야 하며, 타인의 정보를 도용하거나 서비스 운영을 방해하는 행위를 해서는 안 됩니다.

제5조 (서비스 변경 및 중단)
서비스는 운영상 필요에 따라 사전 공지 후 변경되거나 중단될 수 있습니다.
''');
  }

  void _showPrivacyDialog(BuildContext context) {
    _showInfoDialog(context, '개인정보 처리 방침', '''
팡팡팡 개인정보 처리 방침

1. 수집하는 개인정보 항목
  - 카카오 계정 정보(닉네임, 고유 ID)
  - 위치 정보(지역 주소, 기상청 격자 좌표)
  - 주거 환경 정보(창문 방향, 층수 등)

2. 개인정보 수집 및 이용 목적
  - 지역별 곰팡이 위험도 분석 및 제공
  - 맞춤형 환기 추천 시간 안내
  - 곰팡이 예방 알림 발송
  - 서비스 개선을 위한 통계 분석

3. 개인정보 보유 및 이용 기간
  - 회원 탈퇴 시까지 보유하며, 탈퇴 즉시 파기합니다.
  - 날씨 데이터는 서비스 제공 목적으로만 임시 저장되며, 주기적으로 갱신됩니다.

4. 개인정보의 제3자 제공
  - 이용자의 개인정보를 제3자에게 제공하지 않습니다.

5. 문의
  - 개인정보 관련 문의 사항은 앱 내 설정 메뉴를 통해 접수해 주세요.
''');
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('회원탈퇴'),
        content: const Text(
          '탈퇴 시 모든 데이터가 삭제되고 '
          '카카오 서비스 동의도 초기화됩니다.\n\n'
          '정말 탈퇴하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().deleteAccount();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (route) => false,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('탈퇴하기'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    _showInfoDialog(context, '도움말', '''
팡팡팡 사용 가이드

Q. 곰팡이 위험도는 어떻게 측정하나요?
기상청 날씨 데이터(기온, 습도, 강수 확률)와 사용자의 주거 환경 정보(창문 방향, 층수)를 종합하여 실내 곰팡이 발생 가능성을 분석합니다.

Q. 환기 추천은 어떤 기준인가요?
기온, 습도, 강수 확률이 모두 적정 범위에 있는 시간대를 자동으로 찾아 추천합니다. 2시간 이상 연속으로 조건을 충족하는 구간만 안내됩니다.

Q. 곰팡이 사전은 무엇인가요?
생활 속에서 자주 발생하는 곰팡이의 종류별 특징, 위험성, 대처법을 확인할 수 있는 정보 사전입니다.

Q. 알림은 어떻게 받나요?
설정에서 알림을 활성화하면, 곰팡이 위험도가 높아지거나 환기 적정 시간이 다가올 때 푸시 알림을 보내 드립니다.

Q. 위치 정보를 변경하고 싶어요.
메뉴의 '집 정보 수정'에서 주소를 다시 검색하여 변경할 수 있습니다.
''');
  }
}
