import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/permission_status_entity.dart';
import '../repositories/permission_repository.dart';

/// 현재 권한 상태를 조회하는 유스케이스
///
/// 앱에서 필요한 모든 권한의 현재 허용 상태를 조회.
/// 성공 시 [List<PermissionItem>] 반환, 실패 시 [UnknownFailure] 반환.
@lazySingleton
class CheckPermissionsUseCase
    implements UseCase<List<PermissionItem>, NoParams> {
  final PermissionRepository _repository;

  const CheckPermissionsUseCase(this._repository);

  @override
  Future<Either<Failure, List<PermissionItem>>> call(NoParams params) async {
    try {
      final items = await _repository.checkAllPermissions();
      return Right(items);
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }
}
