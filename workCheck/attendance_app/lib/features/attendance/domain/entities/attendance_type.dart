/// 출퇴근 유형
enum AttendanceType {
  /// 출근
  clockIn('출근'),

  /// 퇴근
  clockOut('퇴근');

  /// UI 표시용 라벨
  final String label;
  const AttendanceType(this.label);
}
