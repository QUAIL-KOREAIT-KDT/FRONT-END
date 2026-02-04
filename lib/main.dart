import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/constants.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/mold_risk_provider.dart';
import 'providers/weather_provider.dart';
import 'providers/iot_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';

/// 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (에러 발생 시에도 앱 실행)
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase 초기화 성공');

    // FCM 백그라운드 핸들러 등록
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 알림 서비스 초기화
    await NotificationService().initialize();
    debugPrint('✅ 알림 서비스 초기화 성공');
  } catch (e) {
    debugPrint('⚠️ Firebase/알림 초기화 실패: $e');
    // Firebase 초기화 실패해도 앱은 실행되도록 함
  }

  // 카카오 SDK 초기화 (웹/네이티브 분기)
  try {
    if (kIsWeb) {
      KakaoSdk.init(javaScriptAppKey: AppConstants.kakaoJavaScriptKey);
    } else {
      KakaoSdk.init(nativeAppKey: AppConstants.kakaoNativeAppKey);
    }
    debugPrint('✅ 카카오 SDK 초기화 성공');
  } catch (e) {
    debugPrint('⚠️ 카카오 SDK 초기화 실패: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MoldRiskProvider()),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => IotProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: '팡팡팡',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
