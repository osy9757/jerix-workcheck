import 'package:flutter/material.dart';

/// WorkCheck 관리자 웹 디자인 토큰
/// - 모든 페이지는 하드코딩 색상 대신 이 토큰을 사용한다
class AdminColors {
  AdminColors._(); // 인스턴스화 방지

  // 브랜드
  static const Color primary = Color(0xFF2DDAA9); // 메인 브랜드
  static const Color primaryDark = Color(0xFF1B7E62); // 진한 브랜드 (텍스트/아이콘 대비용)
  static const Color primarySoft = Color(0xFFE7FAF3); // 연한 브랜드 배경 (안내 박스 등)

  // 배경/표면
  static const Color bg = Color(0xFFF6F8FA); // 페이지 배경
  static const Color surface = Colors.white; // 카드/다이얼로그 표면
  static const Color surfaceAlt = Color(0xFFF2F5F8); // 테이블 헤더/입력 채움 배경

  // 보더/구분선
  static const Color border = Color(0xFFE4E9EF);

  // 텍스트
  static const Color textMain = Color(0xFF1A212B); // 본문/제목
  static const Color textSub = Color(0xFF6B7684); // 보조 텍스트/캡션

  // 시맨틱
  static const Color danger = Color(0xFFE5484D); // 위험/삭제/에러
  static const Color dangerDark = Color(0xFFC53035); // 진한 danger (연한 배경 위 텍스트용)
  static const Color dangerSoft = Color(0xFFFDECEC); // 연한 danger 배경 (배지/에러 박스)
  static const Color warn = Color(0xFFF59E0B); // 경고/대기
  static const Color warnDark = Color(0xFFB45309); // 진한 warn (연한 배경 위 텍스트용)
  static const Color warnSoft = Color(0xFFFEF3E2); // 연한 warn 배경 (배지)
  static const Color info = Color(0xFF3B82F6); // 정보

  // 다크 사이드바
  static const Color sidebar = Color(0xFF1B2330); // 사이드바 배경
  static const Color sidebarText = Color(0xFF9AA4B2); // 사이드바 비활성 텍스트
}

/// 공통 radius/그림자 토큰
class AdminTokens {
  AdminTokens._();

  static const double radiusCard = 14; // 카드
  static const double radiusInput = 12; // 입력 필드
  static const double radiusDialog = 20; // 다이얼로그
  static const double pagePadding = 32; // 페이지 패딩
  static const double cardPadding = 24; // 카드 내부 패딩

  /// 카드용 낮은 그림자
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x0A101828), // 4% 블랙 계열
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];
}

/// 관리자 웹 Material 3 테마 생성
ThemeData buildAdminTheme() {
  // 브랜드 seed 기반 + 핵심 색은 명시적으로 고정
  final colorScheme = ColorScheme.fromSeed(
    seedColor: AdminColors.primary,
    primary: AdminColors.primary,
    onPrimary: Colors.white,
    surface: AdminColors.surface,
    onSurface: AdminColors.textMain,
    error: AdminColors.danger,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AdminColors.bg,

    // 타이포 스케일 (페이지 타이틀 22~24 w700 / 본문 14 / 캡션 12)
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: AdminColors.textMain,
        height: 1.3,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AdminColors.textMain,
      ),
      bodyMedium: TextStyle(fontSize: 14, color: AdminColors.textMain),
      bodySmall: TextStyle(fontSize: 12, color: AdminColors.textSub),
    ),

    // 카드: 흰 배경 + 미세 보더 + 그림자 없음 (그림자는 AppCard에서 부여)
    cardTheme: CardThemeData(
      color: AdminColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusCard),
        side: const BorderSide(color: AdminColors.border),
      ),
      margin: EdgeInsets.zero,
    ),

    // 버튼 위계: primary=Filled/Elevated, secondary=Outlined, 보조=Text
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AdminColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AdminColors.textMain,
        side: const BorderSide(color: AdminColors.border),
        minimumSize: const Size(0, 44),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AdminColors.primaryDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    ),

    // 입력 필드: 라운드 12 + 채움 배경 + 포커스 시 브랜드 보더
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AdminColors.surfaceAlt,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusInput),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusInput),
        borderSide: const BorderSide(color: AdminColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusInput),
        borderSide: const BorderSide(color: AdminColors.primary, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusInput),
        borderSide: const BorderSide(color: AdminColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusInput),
        borderSide: const BorderSide(color: AdminColors.danger, width: 1.6),
      ),
      labelStyle: const TextStyle(fontSize: 14, color: AdminColors.textSub),
      hintStyle: const TextStyle(fontSize: 14, color: AdminColors.textSub),
      helperStyle: const TextStyle(fontSize: 12, color: AdminColors.textSub),
    ),

    // 데이터 테이블: 연한 헤더 + 정돈된 행 높이
    dataTableTheme: DataTableThemeData(
      headingRowColor: const WidgetStatePropertyAll(AdminColors.surfaceAlt),
      headingRowHeight: 48,
      headingTextStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AdminColors.textSub,
      ),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 56,
      dataTextStyle: const TextStyle(
        fontSize: 14,
        color: AdminColors.textMain,
      ),
      dividerThickness: 1,
    ),

    // 다이얼로그: radius 20 흰 표면
    dialogTheme: DialogThemeData(
      backgroundColor: AdminColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AdminTokens.radiusDialog),
      ),
      titleTextStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AdminColors.textMain,
      ),
      contentTextStyle:
          const TextStyle(fontSize: 14, color: AdminColors.textMain),
    ),

    // 스낵바: 플로팅 + 다크 표면
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2A3441),
      contentTextStyle: const TextStyle(fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      width: 420,
    ),

    // 구분선
    dividerTheme: const DividerThemeData(
      color: AdminColors.border,
      thickness: 1,
      space: 1,
    ),

    // 칩: pill 형태 + 미세 보더
    chipTheme: ChipThemeData(
      backgroundColor: AdminColors.surface,
      selectedColor: AdminColors.primarySoft,
      side: const BorderSide(color: AdminColors.border),
      shape: const StadiumBorder(),
      labelStyle: const TextStyle(fontSize: 13, color: AdminColors.textMain),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    ),

    // 로딩 인디케이터 브랜드 컬러 통일
    progressIndicatorTheme:
        const ProgressIndicatorThemeData(color: AdminColors.primary),
  );
}
