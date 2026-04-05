import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/workplace_config_entity.dart';
import '../repositories/workplace_repository.dart';

/// 근무지 설정 조회 유스케이스
///
/// 활성화된 인증 방법 목록과 방법별 설정값을 가져온다.
/// 파라미터 없이 호출되며 [NoParams]를 사용한다.
@lazySingleton
class GetWorkplaceConfigUseCase
    implements UseCase<WorkplaceConfigEntity, NoParams> {
  final WorkplaceRepository _repository;

  const GetWorkplaceConfigUseCase(this._repository);

  /// 근무지 설정을 조회하고 성공/실패를 Either로 반환
  @override
  Future<Either<Failure, WorkplaceConfigEntity>> call(NoParams params) {
    return _repository.getConfig();
  }
}
