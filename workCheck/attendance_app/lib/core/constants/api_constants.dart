/// API 상수 정의
///
/// baseUrl은 Settings 화면에서 변경 가능. SharedPreferences에 저장됨.
/// 기본값: defaultBaseUrl (에뮬레이터/실기기 환경에 따라 변경)
abstract class ApiConstants {
  /// 기본 서버 URL (Settings에서 변경 전 사용)
  static const String defaultBaseUrl = 'http://175.126.191.135:8081';

  /// SharedPreferences 키 (settings_screen과 동일)
  static const String serverUrlKey = 'server_base_url';

  /// Dio 초기화 시 사용하는 baseUrl (기본값, 인터셉터가 동적으로 덮어씀)
  static const String baseUrl = defaultBaseUrl;
  static const String apiPrefix = '/api/v1';

  // 인증
  static const String login = '$apiPrefix/auth/login';

  // 출퇴근 - 2단계 호출 (v2 리팩토링)
  // init: 어떤 method 데이터를 모아야 하는지 안내
  // submit: 수집된 verification_data 일괄 검증 + 등록
  static const String clockInInit = '$apiPrefix/attendance/clock-in/init';
  static const String clockInSubmit = '$apiPrefix/attendance/clock-in/submit';
  static const String clockOutInit = '$apiPrefix/attendance/clock-out/init';
  static const String clockOutSubmit = '$apiPrefix/attendance/clock-out/submit';

  // 출퇴근 조회
  static const String todayStatus = '$apiPrefix/attendance/today';
  static const String history = '$apiPrefix/attendance/history';

  // 사용자
  static const String users = '$apiPrefix/users';
}
