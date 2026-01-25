class AppConstants {
  // API URLs
  static const String baseUrl = 'http://your-server-url.com/api';

  // 카카오 로그인 (나중에 설정)
  static const String kakaoNativeAppKey = '14cd88ec2188fe6269f64fca08013069';

  // 위험도 임계값
  static const int riskSafeMax = 30;
  static const int riskCautionMax = 60;
  static const int riskWarningMax = 90;

  // 알림 설정
  static const int notificationThreshold = 90;

  // 장소 옵션
  static const List<Map<String, String>> locationOptions = [
    {'icon': '🪟', 'label': '창가'},
    {'icon': '🧱', 'label': '벽지'},
    {'icon': '🚿', 'label': '욕실'},
    {'icon': '🍳', 'label': '주방'},
    {'icon': '🍞', 'label': '음식'},
    {'icon': '📦', 'label': '기타'},
  ];

  // 집 방향 옵션
  static const List<String> houseDirections = ['북향', '남향', '기타'];
}
