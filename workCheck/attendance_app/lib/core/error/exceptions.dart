/// 서버 응답 오류 예외
/// HTTP 요청 실패 또는 서버 측 오류 발생 시 사용
class ServerException implements Exception {
  final String message;

  /// HTTP 상태 코드 (nullable)
  final int? statusCode;

  const ServerException({required this.message, this.statusCode});
}

/// 로컬 캐시(SharedPreferences 등) 오류 예외
class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

/// 인증 실패 예외 (401 Unauthorized)
/// 토큰 만료 또는 미인증 접근 시 사용
class UnauthorizedException implements Exception {
  final String message;

  const UnauthorizedException({this.message = 'Unauthorized'});
}
