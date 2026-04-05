import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/workplace_config_entity.dart';

/// 근무지 설정 리포지토리 인터페이스
abstract class WorkplaceRepository {
  /// 근무지 설정 (활성 인증 방법 + 설정값) 조회
  Future<Either<Failure, WorkplaceConfigEntity>> getConfig();
}
