import '../entities/permission_status_entity.dart';

abstract class PermissionRepository {
  /// 모든 필수 권한의 현재 상태 조회
  Future<List<PermissionItem>> checkAllPermissions();

  /// 모든 필수 권한 일괄 요청
  Future<List<PermissionItem>> requestAllPermissions();

  /// 모든 권한이 허용되었는지 확인
  Future<bool> areAllPermissionsGranted();
}
