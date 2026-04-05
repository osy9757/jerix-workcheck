part of 'attendance_bloc.dart';

@freezed
class AttendanceEvent with _$AttendanceEvent {
  /// 화면 초기 로드 - 오늘 출퇴근 상태 조회
  const factory AttendanceEvent.started() = AttendanceStarted;

  /// 출퇴근 버튼 클릭 → 인증 + 등록
  const factory AttendanceEvent.clockRequested() = AttendanceClockRequested;

  /// 사용 가능한 인증 방식 조회
  const factory AttendanceEvent.availableMethodsRequested() =
      AttendanceAvailableMethodsRequested;
}
