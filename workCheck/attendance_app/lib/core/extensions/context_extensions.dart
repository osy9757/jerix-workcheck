import 'package:flutter/material.dart';

/// BuildContext 확장 메서드
/// 자주 사용하는 Theme, MediaQuery 접근을 단축어로 제공
extension BuildContextX on BuildContext {
  // ──── 테마 단축어 ────

  /// 현재 컨텍스트의 테마 데이터
  ThemeData get theme => Theme.of(this);

  /// 텍스트 테마
  TextTheme get textTheme => theme.textTheme;

  /// 색상 스킴
  ColorScheme get colorScheme => theme.colorScheme;

  // ──── MediaQuery 단축어 ────

  /// 화면 전체 크기
  Size get screenSize => MediaQuery.sizeOf(this);

  /// 화면 너비
  double get screenWidth => screenSize.width;

  /// 화면 높이
  double get screenHeight => screenSize.height;

  /// 시스템 UI(노치, 홈바 등)를 포함한 패딩
  EdgeInsets get viewPadding => MediaQuery.viewPaddingOf(this);

  // ──── 스낵바 ────

  /// 스낵바 표시
  /// [message] 표시할 메시지
  /// [isError] true이면 오류 색상으로 표시
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
