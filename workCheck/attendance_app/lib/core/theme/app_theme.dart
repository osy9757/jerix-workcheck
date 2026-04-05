import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 앱 테마 정의
/// 라이트/다크 테마를 정적 속성으로 제공
abstract class AppTheme {
  // ──── 기본 색상 ────

  /// 메인 브랜드 컬러 (민트 계열)
  static const _primaryColor = Color(0xFF2DDAA9);

  /// 오류 표시 색상 (레드 계열)
  static const _errorColor = Color(0xFFDC2626);

  // ──── 라이트 테마 ────
  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: _primaryColor,
        scaffoldBackgroundColor: Colors.white,
        // 전체 기본 폰트: Pretendard
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          // 스크롤 시 AppBar 하단 미세한 그림자
          scrolledUnderElevation: 0.5,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        // 텍스트 입력 필드 공통 스타일
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        // ElevatedButton 공통 스타일 (전체 너비, 높이 52)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  // ──── 다크 테마 ────
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: _primaryColor,
        fontFamily: 'Pretendard',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0.5,
        ),
      );
}
