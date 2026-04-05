import 'package:equatable/equatable.dart';

import 'attendance_entity.dart';

/// 오늘의 출퇴근 상태 엔티티
class TodayStatusEntity extends Equatable {
  /// 오늘 출근 기록 (없으면 null)
  final AttendanceEntity? clockIn;

  /// 오늘 퇴근 기록 (없으면 null)
  final AttendanceEntity? clockOut;

  const TodayStatusEntity({this.clockIn, this.clockOut});

  /// 출근 완료 여부
  bool get isClockedIn => clockIn != null;

  /// 퇴근 완료 여부
  bool get isClockedOut => clockOut != null;

  /// 출퇴근 모두 완료 여부
  bool get isCompleted => isClockedIn && isClockedOut;

  /// 다음 가능한 액션: 출근 전 → clockIn, 출근 후 → clockOut, 둘 다 완료 → null
  String? get nextAction {
    if (!isClockedIn) return '출근';
    if (!isClockedOut) return '퇴근';
    return null;
  }

  @override
  List<Object?> get props => [clockIn, clockOut];
}
