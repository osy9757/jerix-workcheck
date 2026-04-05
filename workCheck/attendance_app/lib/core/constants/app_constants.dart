/// 앱 전역 상수 정의
abstract class AppConstants {
  /// 앱 이름
  static const String appName = 'App Name';

  // ──── 로컬 저장소 키 ────
  /// 액세스 토큰 저장 키
  static const String tokenKey = 'access_token';

  /// 리프레시 토큰 저장 키
  static const String refreshTokenKey = 'refresh_token';

  /// 사용자 정보 저장 키
  static const String userKey = 'user_data';

  // ──── 페이지네이션 ────
  /// 기본 페이지당 항목 수
  static const int defaultPageSize = 20;
}
