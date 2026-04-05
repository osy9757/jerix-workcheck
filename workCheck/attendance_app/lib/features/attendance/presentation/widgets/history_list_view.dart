import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/history_entity.dart';
import 'history_day_row.dart';

/// 리스트 형태의 히스토리 뷰
class HistoryListView extends StatelessWidget {
  const HistoryListView({
    super.key,
    required this.currentMonth,
    required this.records,
  });

  final DateTime currentMonth;
  final Map<int, DailyRecordEntity> records;

  /// DateTime → HH:mm 포맷 변환
  String? _formatTime(DateTime? time) {
    if (time == null) return null;
    return DateFormat('HH:mm').format(time);
  }

  /// 출퇴근 시간으로 근무시간 계산
  String? _calculateTotalHours(DateTime? clockIn, DateTime? clockOut) {
    if (clockIn == null || clockOut == null) return null;
    final diff = clockOut.difference(clockIn);
    if (diff.isNegative) return null;
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    if (minutes == 0) {
      return '${hours.toString().padLeft(2, '0')}시간';
    }
    return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분';
  }

  @override
  Widget build(BuildContext context) {
    final lastDay = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    final today = DateTime.now();

    final days = List.generate(
      lastDay.day,
      (index) => DateTime(currentMonth.year, currentMonth.month, index + 1),
    );

    final rows = days.map((date) {
      final isToday =
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day;

      final record = records[date.day];
      final clockIn = _formatTime(record?.clockIn?.timestamp);
      final clockOut = _formatTime(record?.clockOut?.timestamp);
      final totalHours = _calculateTotalHours(
        record?.clockIn?.timestamp,
        record?.clockOut?.timestamp,
      );

      return HistoryDayRow(
        day: date.day,
        weekday: date.weekday,
        isToday: isToday,
        clockIn: clockIn,
        clockOut: clockOut,
        totalHours: totalHours,
      );
    }).toList();

    final divider = Container(
      width: 343.w,
      height: 1,
      color: const Color(0xFFE5E5EA),
    );

    final children = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(divider);
      }
    }

    return SizedBox(
      width: 343.w,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }
}
