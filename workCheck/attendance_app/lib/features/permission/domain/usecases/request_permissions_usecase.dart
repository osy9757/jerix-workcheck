import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/permission_status_entity.dart';
import '../repositories/permission_repository.dart';

/// 앱 권한을 일괄 요청하는 유스케이스
///
/// 앱에서 필요한 모든 권한을 시스템에 요청.
/// 성공 시 요청 후 상태가 담긴 [List<PermissionItem>] 반환,
/// 실패 시 [UnknownFailure] 반환.
@lazySingleton
class RequestPermissionsUseCase
    implements UseCase<List<PermissionItem>, NoParams> {
  final PermissionRepository _repository;

  const RequestPermissionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PermissionItem>>> call(NoParams params) async {
    try {
      final items = await _repository.requestAllPermissions();
      return Right(items);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
