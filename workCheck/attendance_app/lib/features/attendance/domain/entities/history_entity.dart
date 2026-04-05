import 'package:equatable/equatable.dart';

import 'attendance_entity.dart';

/// 월별 출퇴근 히스토리 엔티티
class HistoryEntity extends Equatable {
  /// 일별 출퇴근 기록 목록
  final List<DailyRecordEntity> records;

  /// 해당 기간 총 출근 일수
  final int total;

  const HistoryEntity({required this.records, required this.total});

  @override
  List<Object?> get props => [records, total];
}

/// 일별 출퇴근 기록 엔티티
class DailyRecordEntity extends Equatable {
  /// 날짜 문자열 (yyyy-MM-dd 형식)
  final String date;

  /// 해당일 출근 기록 (없으면 null)
  final AttendanceEntity? clockIn;

  /// 해당일 퇴근 기록 (없으면 null)
  final AttendanceEntity? clockOut;

  const DailyRecordEntity({
    required this.date,
    this.clockIn,
    this.clockOut,
  });

  @override
  List<Object?> get props => [date, clockIn, clockOut];
}
