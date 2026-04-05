part of 'permission_bloc.dart';

@freezed
class PermissionEvent with _$PermissionEvent {
  /// 권한 상태 조회
  const factory PermissionEvent.started() = PermissionStarted;

  /// 권한 일괄 요청
  const factory PermissionEvent.requested() = PermissionRequested;

  /// 설정으로 이동 (영구 거부 시)
  const factory PermissionEvent.openSettingsRequested() =
      PermissionOpenSettingsRequested;
}
