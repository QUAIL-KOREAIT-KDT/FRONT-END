import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class AppConstants {
  // 환경 모드 (빌드 시 --dart-define=PRODUCTION=true로 설정)
  static const bool isProduction = bool.fromEnvironment(
    'PRODUCTION',
    defaultValue: false, // 기본값은 개발 모드
  );

  // API URLs - 환경별 자동 설정
  static String get baseUrl {
    if (isProduction) {
      // 🚀 프로덕션 환경: Nginx 도메인
      return 'https://pangpangpangs.com/api';
    } else {
      // 🛠️ 개발 환경: 로컬 서버
      if (kIsWeb) {
        // 웹: localhost 사용
        return 'http://localhost:8000/api';
      } else {
        try {
          if (Platform.isAndroid) {
            // Android 에뮬레이터: 10.0.2.2는 호스트 PC의 localhost를 가리킴
            return 'http://10.0.2.2:8000/api'; // 에뮬레이터용
            // return 'http://192.168.162.42:8000/api'; // 실제 핸드폰용 (같은 와이파이)
          } else if (Platform.isIOS) {
            // iOS 시뮬레이터: localhost 사용 가능
            return 'http://localhost:8000/api';
          }
        } catch (e) {
          // Platform 접근 실패 시 기본값
        }
        return 'http://localhost:8000/api';
      }
    }
  }

  // 카카오 로그인 키
  static const String kakaoNativeAppKey = '14cd88ec2188fe6269f64fca08013069';
  static const String kakaoJavaScriptKey = '27933cda9860739d03f4eb0a5263e68c';

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
