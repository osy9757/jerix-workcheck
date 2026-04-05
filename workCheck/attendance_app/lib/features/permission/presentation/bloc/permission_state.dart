part of 'permission_bloc.dart';

/// 권한 BLoC 상태
@freezed
class PermissionState with _$PermissionState {
  const factory PermissionState({
    /// 권한 항목 목록
    @Default([]) List<PermissionItem> permissionItems,

    /// 모든 권한이 허용되었는지 여부
    @Default(false) bool allGranted,

    /// 현재 UI 상태
    @Default(PermissionUiState.initial) PermissionUiState uiState,

    /// 오류 메시지 (오류 상태일 때만 존재)
    @Default(null) String? errorMessage,
  }) = _PermissionState;
}

/// 권한 화면 UI 상태
enum PermissionUiState {
  /// 초기 상태
  initial,

  /// 권한 상태 조회 중
  loading,

  /// 조회 완료
  loaded,

  /// 권한 요청 중
  requesting,

  /// 모든 권한 허용됨
  allGranted,

  /// 일부 권한 거부됨
  partiallyDenied,

  /// 일부 권한 영구 거부됨 (설정에서만 변경 가능)
  permanentlyDenied,

  /// 오류 발생
  error,
}
