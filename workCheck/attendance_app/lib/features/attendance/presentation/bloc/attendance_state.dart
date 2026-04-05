part of 'attendance_bloc.dart';

@freezed
class AttendanceState with _$AttendanceState {
  const factory AttendanceState({
    /// 오늘 출퇴근 상태
    @Default(null) TodayStatusEntity? todayStatus,

    /// 사용 가능한 인증 방식 목록 (서버 활성 ∩ 디바이스 가용)
    @Default([]) List<VerificationMethod> availableMethods,

    /// 서버에서 활성화된 인증 방식 (아이콘 표시용)
    @Default([]) List<VerificationMethod> serverEnabledMethods,

    /// UI 상태
    @Default(AttendanceUiState.initial) AttendanceUiState uiState,

    /// 에러 메시지
    @Default(null) String? errorMessage,

    /// 서버 에러 코드 (예: BEACON_UUID_MISMATCH)
    @Default(null) String? errorCode,

    /// 성공 메시지
    @Default(null) String? successMessage,
  }) = _AttendanceState;
}

enum AttendanceUiState {
  initial,
  loading,        // 상태 조회 중
  loaded,         // 상태 조회 완료
  verifying,      // 인증 진행 중
  registering,    // 서버 등록 중
  success,        // 등록 성공
  error,          // 에러
}
