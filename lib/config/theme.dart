import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 민트 색상
  static const Color mintPrimary = Color(0xFF2EC4A8);
  static const Color mintLight = Color(0xFFE8FAF6);
  static const Color mintLight2 = Color(0xFFB8F0E4);
  static const Color mintMedium = Color(0xFF7DE5D0);
  static const Color mintDark = Color(0xFF1FA085);

  // 핑크 색상
  static const Color pinkPrimary = Color(0xFFFF6BA3);
  static const Color pinkLight = Color(0xFFFFF0F5);
  static const Color pinkLight2 = Color(0xFFFFD6E7);
  static const Color pinkMedium = Color(0xFFFFB3D1);

  // 그레이 색상
  static const Color gray100 = Color(0xFFF7F8FA);
  static const Color gray200 = Color(0xFFE8ECF1);
  static const Color gray300 = Color(0xFFC9D1DC);
  static const Color gray400 = Color(0xFF9BA5B4);
  static const Color gray500 = Color(0xFF6B7684);
  static const Color gray600 = Color(0xFF4E5968);
  static const Color gray700 = Color(0xFF333D4B);
  static const Color gray800 = Color(0xFF191F28);

  // 위험도 색상
  static const Color safe = Color(0xFF4DD9BC);
  static const Color caution = Color(0xFFFFD93D);
  static const Color warning = Color(0xFFFF9F43);
  static const Color danger = Color(0xFFFF6B6B);

  // 그라데이션
  static const LinearGradient mintGradient = LinearGradient(
    colors: [mintPrimary, Color(0xFF4DD9BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintPinkGradient = LinearGradient(
    colors: [mintPrimary, pinkPrimary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [mintLight, Colors.white, pinkLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );

  // 테마 데이터
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: mintPrimary,
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.notoSansTextTheme(),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: gray800),
        titleTextStyle: TextStyle(
          color: gray800,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      scaffoldBackgroundColor: Colors.white,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mintPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gray200, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: gray200, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: mintPrimary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
      ),
    );
  }

  // 위험도에 따른 색상 반환
  static Color getRiskColor(int riskLevel) {
    if (riskLevel <= 30) return safe;
    if (riskLevel <= 60) return caution;
    if (riskLevel <= 90) return warning;
    return danger;
  }

  // 위험도에 따른 상태 텍스트 반환
  static String getRiskStatus(int riskLevel) {
    if (riskLevel <= 30) return '안전해요! 😊';
    if (riskLevel <= 60) return '주의가 필요해요 🤔';
    if (riskLevel <= 90) return '경계 단계예요! 😰';
    return '위험해요! 😱';
  }
}
