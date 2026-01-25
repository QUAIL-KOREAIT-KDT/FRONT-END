import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_screen.dart';
import '../screens/diagnosis_screen.dart';
import '../screens/diagnosis_result_screen.dart';
import '../screens/dictionary_screen.dart';
import '../screens/dictionary_detail_screen.dart';
import '../screens/fortune_screen.dart';
import '../screens/mypage/mypage_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/home_info_screen.dart';
import '../screens/settings/iot_settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String home = '/home';
  static const String diagnosis = '/diagnosis';
  static const String diagnosisResult = '/diagnosis/result';
  static const String dictionary = '/dictionary';
  static const String dictionaryDetail = '/dictionary/detail';
  static const String fortune = '/fortune';
  static const String mypage = '/mypage';
  static const String settings = '/settings';
  static const String homeInfo = '/settings/home-info';
  static const String iotSettings = '/settings/iot';

  static Map<String, WidgetBuilder> get routes {
    return {
      splash: (context) => const SplashScreen(),
      login: (context) => const LoginScreen(),
      onboarding: (context) => const OnboardingScreen(),
      main: (context) => const MainScreen(),
      home: (context) => const MainScreen(initialIndex: 0),
      diagnosis: (context) => const DiagnosisScreen(),
      diagnosisResult: (context) => const DiagnosisResultScreen(),
      dictionary: (context) => const DictionaryScreen(),
      dictionaryDetail: (context) => const DictionaryDetailScreen(),
      fortune: (context) => const FortuneScreen(),
      mypage: (context) => const MypageScreen(),
      settings: (context) => const SettingsScreen(),
      homeInfo: (context) => const HomeInfoScreen(),
      iotSettings: (context) => const IotSettingsScreen(),
    };
  }
}
