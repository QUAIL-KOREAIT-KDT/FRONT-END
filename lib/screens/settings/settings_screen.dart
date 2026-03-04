import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

                    // 🛠 개발 전용 (디버그 빌드에서만 표시)
                    if (kDebugMode) ..._buildDebugSection(context),
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
                      _notificationEnabled ? '곰팡이 예방 알림을 받습니다' : '알림이 꺼져있습니다',
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
본 약관은 팡팡팡(이하 "서비스")이 제공하는 곰팡이 예방 및 관리 서비스의 이용 조건 및 절차에 관한 사항을 규정합니다.

제2조 (서비스 내용)
서비스는 다음의 기능을 제공합니다.
  1) 곰팡이 위험도 예측: 기상청 공공 데이터와 사용자 주거 환경 정보를 기반으로 실내 곰팡이 발생 위험도를 4단계(안전/주의/경고/위험)로 예측합니다.
  2) 환기 추천 시간대: 기온, 습도, 강수 확률을 종합하여 적절한 환기 시간대를 안내합니다.
  3) AI 곰팡이 진단: 사진 촬영 또는 업로드를 통해 딥러닝(EfficientNet) 모델로 곰팡이 종류 및 위험도 등급을 분석하고, AI 기반 해결/예방법을 제공합니다.
  4) 곰팡이 정보 사전: 곰팡이 종류별 특징, 위험성, 대처법, 예방법을 제공하는 정보 사전입니다.
  5) 오늘의 팡이: AI 기반의 곰팡이 테마 운세 콘텐츠로, 하루 1회 이용 가능합니다.
  6) 팡이 게임: 곰팡이 테마의 숫자 퍼즐 미니게임입니다.
  7) 마이페이지: 과거 진단 기록을 조회, 필터링, 삭제할 수 있습니다.
  8) 푸시 알림: 매일 오전 8시 당일 위험도 및 환기 추천 시간 알림을 제공합니다.
  9) 스마트홈 연동 (BETA): IoT 기기(제습기, 에어컨 등) 원격 제어 기능을 제공하며, BETA 단계로 일부 제한이 있을 수 있습니다.

제3조 (면책 사항 – 위험도 예측)
본 서비스의 위험도 수치는 기상청 예보 데이터와 통계 모델을 활용한 예측값이며, 실제 환경과 차이가 있을 수 있습니다. 서비스 정보는 참고 용도로만 활용해 주시기 바랍니다.

제3조의2 (면책 사항 – AI 곰팡이 진단)
AI 곰팡이 진단 기능은 딥러닝 모델을 활용한 참고용 서비스이며, 진단 결과는 100% 정확하지 않을 수 있습니다. 곰팡이 종류 및 위험도 등급은 학습 데이터 기반의 추정 결과이며, 의학적·전문적 판단을 대체하지 않습니다. 건강에 이상이 있거나 심각한 오염이 의심되는 경우 전문가(환경 전문업체, 의료기관 등)에게 상담하시기 바랍니다. 진단 결과에 따른 조치로 발생한 손해에 대해 서비스 제공자는 책임을 지지 않습니다.

제3조의3 (면책 사항 – 오늘의 팡이)
오늘의 팡이(운세) 기능은 AI가 생성한 재미 요소의 콘텐츠로, 실제 운세나 예측과 무관합니다. 오락 목적으로만 제공되며, 해당 내용에 따른 결정이나 행동에 대한 책임은 이용자에게 있습니다.

제4조 (이용자의 의무)
이용자는 서비스를 정상적인 용도로 사용해야 하며, 타인의 정보를 도용하거나 서비스 운영을 방해하는 행위를 해서는 안 됩니다. 진단 기능 이용 시 곰팡이 사진 외의 부적절한 이미지를 업로드해서는 안 됩니다.

제5조 (서비스 변경 및 중단)
서비스는 운영상 필요에 따라 사전 공지 후 변경되거나 중단될 수 있습니다.

제6조 (외부 서비스 활용)
본 서비스는 다음의 외부 서비스를 활용합니다.
  - Google AI (Gemini): 진단 솔루션 생성, 운세 콘텐츠 생성, 곰팡이 사전 정보 보강
  - Firebase Cloud Messaging: 푸시 알림 전송
  - 카카오 로그인: 사용자 인증
  - 기상청 공공 데이터 API: 날씨 데이터 조회

부칙) 본 약관은 2026년 2월 27일부터 시행합니다.
''');
  }

  void _showPrivacyDialog(BuildContext context) {
    _showInfoDialog(context, '개인정보 처리 방침', '''
팡팡팡 개인정보 처리 방침

1. 수집하는 개인정보 항목
  ▶ 회원 정보
  - 카카오 계정 정보 (닉네임, 고유 ID)
  - 앱 내 닉네임 (사용자 설정)

  ▶ 주거 환경 정보
  - 거주지 주소 (기상청 격자 좌표 변환 포함)
  - 창문 방향 (북향/남향/기타)
  - 반지하 여부
  - 실내 온도 및 습도

  ▶ 진단 데이터
  - 곰팡이 사진 (카메라 촬영 또는 갤러리 업로드)
  - 진단 결과 (등급, 신뢰도, Grad-CAM 이미지)
  - 진단 장소 (창가/벽지/욕실/주방/음식/기타)

  ▶ 기기 정보
  - FCM 기기 토큰 (푸시 알림 전송용)

  ▶ 이용 기록
  - 운세 조회 기록 (점수, 상태, 메시지)
  - 알림 수신 설정 (ON/OFF)

2. 개인정보 수집 및 이용 목적
  - 지역별 곰팡이 위험도 분석 및 제공
  - AI 곰팡이 진단 및 결과 제공
  - 맞춤형 환기 추천 시간 안내
  - 곰팡이 예방 푸시 알림 발송
  - 오늘의 팡이 AI 콘텐츠 생성
  - 서비스 개선을 위한 통계 분석

3. 개인정보 보유 및 이용 기간
  - 회원 탈퇴 시까지 보유하며, 탈퇴 즉시 파기합니다.
  - 날씨 데이터는 서비스 제공 목적으로만 임시 저장되며, 주기적으로 갱신됩니다.
  - 진단 이미지는 서버에 저장되며, 회원 탈퇴 시 함께 삭제됩니다.
  - 인증 토큰(JWT)은 기기 내에만 저장되며, 로그아웃 시 삭제됩니다.

4. 외부 서비스 활용
  본 서비스는 다음의 외부 서비스를 활용합니다.
  - Google AI (Gemini): 진단 솔루션 생성, 운세 콘텐츠, 사전 정보 보강
  - Firebase Cloud Messaging: 푸시 알림 전송
  - AWS S3: 진단 이미지 저장
  - 카카오 로그인 API: 사용자 인증
  외부 서비스 제공자의 개인정보 처리는 해당 서비스의 약관을 따릅니다.

5. 개인정보의 제3자 제공
  - 이용자의 개인정보를 제3자에게 제공하지 않습니다.
  - 단, AI 진단 솔루션 생성 시 곰팡이 종류 정보(개인 식별 불가)가 Google AI에 전달될 수 있습니다.

6. 문의
  - 개인정보 관련 문의: gmldnjs1616@gmail.com

시행일: 2026년 2월 27일
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

■ 홈 화면

Q. 곰팡이 위험도는 어떻게 측정하나요?
기상청 날씨 데이터(기온, 습도, 강수 확률)와 사용자의 주거 환경 정보(창문 방향, 반지하 여부 등)를 종합하여 실내 곰팡이 발생 가능성을 분석합니다.

Q. 위험도 4단계는 무엇인가요?
  - 안전 (0~30%): 곰팡이 발생 가능성이 낮습니다.
  - 주의 (31~60%): 환기에 신경 써주세요.
  - 경고 (61~90%): 곰팡이 발생 가능성이 높습니다. 제습 및 환기를 권장합니다.
  - 위험 (91~100%): 곰팡이 발생 위험이 매우 높습니다. 즉시 조치가 필요합니다.

Q. 환기 추천은 어떤 기준인가요?
기온, 습도, 강수 확률이 모두 적정 범위에 있는 시간대를 자동으로 찾아 추천합니다. 2시간 이상 연속으로 조건을 충족하는 구간만 안내됩니다.

■ AI 곰팡이 진단

Q. 곰팡이 진단은 어떻게 사용하나요?
하단 탭 메뉴의 '진단'을 탭하세요. 카메라 촬영 또는 앨범에서 곰팡이 사진을 선택하고, 발생 장소(창가/벽지/욕실/주방/음식/기타)를 선택한 뒤 '분석하기'를 누르면 AI가 곰팡이 종류와 등급을 분석해 줍니다.

Q. 진단 결과는 어떻게 해석하나요?
  - G0: 곰팡이 미검출 (안전)
  - G1: 검은곰팡이
  - G2: 푸른/초록 곰팡이
  - G3: 하얀 곰팡이 / 백화현상
  - G4: 붉은 곰팡이 / 박테리아
신뢰도(%)와 함께 AI 기반 해결법, 예방법, 전문가 조언도 함께 제공됩니다.

Q. 진단 결과는 정확한가요?
AI 모델 기반의 참고용 서비스입니다. 100% 정확하지 않을 수 있으며, 심각한 곰팡이 오염이 의심되면 전문가에게 상담하시기 바랍니다.

Q. 과거 진단 기록은 어디서 확인하나요?
하단 탭 메뉴의 '마이'를 탭하면 진단 기록을 목록으로 확인할 수 있으며, 장소별 필터링 및 삭제가 가능합니다.

■ 곰팡이 사전

Q. 곰팡이 사전은 무엇인가요?
색상별 곰팡이 카테고리에서 세부 종류별 특징, 위험성, 대처법, 예방법을 확인할 수 있는 정보 사전입니다.

■ 오늘의 팡이 (운세)

Q. 오늘의 팡이는 무엇인가요?
곰팡이 테마의 AI 운세 콘텐츠입니다. 곰팡이를 터치하여 제거하면 AI가 재미있는 운세 메시지를 생성해 줍니다. 하루 1회 이용 가능합니다.

■ 팡이 게임

Q. 팡이 게임은 어떻게 하나요?
숫자가 적힌 곰팡이 타일을 드래그로 묶어 합이 10이 되면 제거되는 퍼즐 게임입니다. 100초 내에 최대한 많은 점수를 획득해 보세요! 더 많은 곰팡이를 한 번에 묶으면 콤보 보너스 점수를 받을 수 있습니다.

■ 알림

Q. 알림은 어떻게 받나요?
설정에서 알림을 활성화하면, 매일 오전 8시에 당일 곰팡이 위험도와 환기 추천 시간 알림을 받을 수 있습니다.

■ 스마트홈 연동 (BETA)

Q. 스마트홈 연동이란?
IoT 기기(제습기, 에어컨, 선풍기 등)를 앱에서 원격으로 ON/OFF 제어할 수 있는 기능입니다. 현재 BETA 단계로 일부 제한이 있을 수 있습니다.

■ 기타

Q. 위치 정보를 변경하고 싶어요.
햄버거 메뉴의 '집 정보 수정'에서 주소를 다시 검색하여 변경할 수 있습니다.

Q. 회원 탈퇴하면 어떻게 되나요?
모든 데이터(진단 기록, 이미지, 설정 등)가 즉시 삭제되며, 카카오 서비스 동의도 초기화됩니다. 탈퇴 후 복구는 불가능합니다.

Q. 문의하고 싶어요.
gmldnjs1616@gmail.com으로 연락해 주세요.
''');
  }

  // 🛠 개발 전용 디버그 섹션 (kDebugMode일 때만 표시됨)
  List<Widget> _buildDebugSection(BuildContext context) {
    return [
      const SizedBox(height: 24),
      _buildSectionTitle('🛠 개발자 도구 (Debug Only)'),
      _buildSettingItem(
        icon: Icons.refresh_rounded,
        title: '진단 면책 동의 초기화',
        subtitle: '다음 진단 시 면책 바텀시트가 다시 표시됩니다',
        titleColor: Colors.orange.shade700,
        onTap: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('diagnosis_disclaimer_agreed');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('✅ 면책 동의 초기화 완료 — 다음 진단 시 바텀시트가 표시됩니다'),
                backgroundColor: Colors.orange.shade700,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          }
        },
      ),
    ];
  }
}
