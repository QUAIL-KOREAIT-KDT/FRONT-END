import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'config/constants.dart';
import 'config/theme.dart';
import 'config/routes.dart';
import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';
import 'providers/iot_provider.dart';
import 'providers/dictionary_provider.dart';
import 'providers/notification_provider.dart';
import 'services/notification_service.dart';
import 'services/api_service.dart'; // navigatorKey

/// 백그라운드 메시지 핸들러 (최상위 함수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('📩 백그라운드 메시지 수신: ${message.messageId}');
}

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // 네이티브 스플래시 화면 유지 (Flutter 스플래시 화면으로 전환될 때까지)
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

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
        ChangeNotifierProvider(create: (_) => IotProvider()),
        ChangeNotifierProvider(create: (_) => DictionaryProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: '팡팡팡',
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        routes: AppRoutes.routes,
        debugShowCheckedModeBanner: false,
        // 시스템 폰트 크기 설정이 너무 크거나 작을 때 UI 깨짐 방지
        builder: (context, child) {
          final mediaQueryData = MediaQuery.of(context);
          final clampedTextScaler = mediaQueryData.textScaler.clamp(
            minScaleFactor: 0.8,
            maxScaleFactor: 1.2,
          );
          return MediaQuery(
            data: mediaQueryData.copyWith(textScaler: clampedTextScaler),
            child: child!,
          );
        },
      ),
    );
  }
}
