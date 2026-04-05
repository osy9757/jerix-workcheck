import 'package:equatable/equatable.dart';

/// 실패(Failure) 기본 클래스
/// Repository에서 발생하는 오류를 UI 레이어에 전달하기 위한 추상 타입
/// Either<Failure, T>의 Left 값으로 사용
abstract class Failure extends Equatable {
  final String message;

  /// HTTP 상태 코드 (해당하는 경우)
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

/// 서버 통신 실패
class ServerFailure extends Failure {
  /// 서버에서 반환한 에러 코드 (예: BEACON_UUID_MISMATCH)
  final String? errorCode;

  const ServerFailure({required super.message, super.statusCode, this.errorCode});

  @override
  List<Object?> get props => [message, statusCode, errorCode];
}

/// 로컬 캐시 접근 실패
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// 네트워크 연결 실패
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = '네트워크 연결을 확인해주세요.'});
}

/// 인증 만료 또는 미인증 접근 실패
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = '인증이 만료되었습니다. 다시 로그인해주세요.'});
}

/// 분류되지 않은 알 수 없는 오류
class UnknownFailure extends Failure {
  const UnknownFailure({super.message = '알 수 없는 오류가 발생했습니다.'});
}
