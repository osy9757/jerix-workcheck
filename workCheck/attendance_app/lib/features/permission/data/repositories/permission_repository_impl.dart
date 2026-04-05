import 'package:injectable/injectable.dart';

import '../../domain/entities/permission_status_entity.dart';
import '../../domain/repositories/permission_repository.dart';
import '../datasources/permission_local_datasource.dart';

/// [PermissionRepository] 구현체
///
/// [PermissionLocalDataSource]에 권한 조회/요청을 위임.
@LazySingleton(as: PermissionRepository)
class PermissionRepositoryImpl implements PermissionRepository {
  final PermissionLocalDataSource _localDataSource;

  const PermissionRepositoryImpl(this._localDataSource);

  /// 현재 권한 상태 조회
  @override
  Future<List<PermissionItem>> checkAllPermissions() {
    return _localDataSource.checkAll();
  }

  /// 모든 권한 일괄 요청
  @override
  Future<List<PermissionItem>> requestAllPermissions() {
    return _localDataSource.requestAll();
  }

  /// 모든 권한이 허용되었는지 확인
  @override
  Future<bool> areAllPermissionsGranted() {
    return _localDataSource.areAllGranted();
  }
}
