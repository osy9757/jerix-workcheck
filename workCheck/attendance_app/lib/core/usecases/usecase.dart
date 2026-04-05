import 'package:dartz/dartz.dart';

import '../error/failures.dart';

/// UseCase 기본 인터페이스
/// Clean Architecture의 Domain 레이어에서 비즈니스 로직 단위를 정의
///
/// [Type] - 성공 시 반환할 데이터 타입
/// [Params] - 유스케이스 실행에 필요한 파라미터 타입
abstract class UseCase<Type, Params> {
  /// 유스케이스 실행
  /// 성공 시 Right(Type), 실패 시 Left(Failure) 반환
  Future<Either<Failure, Type>> call(Params params);
}

/// 파라미터가 없는 UseCase에 사용하는 빈 파라미터 클래스
/// 예: 로그아웃, 사용자 정보 조회 등
class NoParams {
  const NoParams();
}
