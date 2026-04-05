import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 출퇴근 기록 한 행 위젯
///
/// 날짜 정보(좌측)와 출근/퇴근/근무시간 기록(우측)을 함께 표시.
class HistoryDayRow extends StatelessWidget {
  const HistoryDayRow({
    super.key,
    required this.day,
    required this.weekday,
    this.isToday = false,
    this.clockIn,
    this.clockOut,
    this.totalHours,
  });

  /// 날짜 (일)
  final int day;

  /// 요일 (1=월 ~ 7=일, DateTime.weekday 기준)
  final int weekday;

  /// 오늘 날짜 여부
  final bool isToday;

  /// 출근 시간 문자열 (null이면 미기록)
  final String? clockIn;

  /// 퇴근 시간 문자열 (null이면 미기록)
  final String? clockOut;

  /// 총 근무시간 문자열 (null이면 미기록)
  final String? totalHours;

  /// 요일 이름 매핑 (1=월 ~ 7=일)
  static const _weekdayNames = ['', '월', '화', '수', '목', '금', '토', '일'];

  /// 주말 여부 (토: 6, 일: 7)
  bool get _isWeekend => weekday == 6 || weekday == 7;

  /// 출퇴근 기록이 하나라도 있는지 여부
  bool get _hasRecord => clockIn != null || clockOut != null || totalHours != null;

  /// 요일에 따른 텍스트 색상
  Color get _weekdayColor {
    if (weekday == 7) return const Color(0xFFFF3B30); // 일요일: 빨강
    if (weekday == 6) return const Color(0xFF007AFF); // 토요일: 파랑
    return const Color(0xFF374151); // 평일: 기본
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 343.w,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 날짜 + 요일 섹션
          _DateSection(
            day: day,
            weekdayName: _weekdayNames[weekday],
            isToday: isToday,
            weekdayColor: _weekdayColor,
          ),
          // 날짜-기록 구분선
          Container(
            width: 1,
            height: 88.h,
            color: const Color(0xFFE5E5EA),
          ),
          // 출퇴근 기록 섹션 (기록이 있을 때만 표시)
          if (_hasRecord)
            _RecordSection(
              clockIn: clockIn,
              clockOut: clockOut,
              totalHours: totalHours,
            ),
        ],
      ),
    );
  }
}

/// 날짜와 요일을 표시하는 섹션
class _DateSection extends StatelessWidget {
  const _DateSection({
    required this.day,
    required this.weekdayName,
    required this.isToday,
    required this.weekdayColor,
  });

  final int day;
  final String weekdayName;
  final bool isToday;
  final Color weekdayColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      height: 88.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 날짜 숫자 (오늘이면 원형 강조)
          _DayNumber(
            day: day,
            isToday: isToday,
          ),
          SizedBox(height: 4.h),
          // 요일 텍스트
          Text(
            weekdayName,
            style: TextStyle(
              fontFamily: 'Pretendard',
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              height: 1.4,
              color: weekdayColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// 날짜 숫자 위젯
///
/// 오늘이면 원형 배경으로 강조 표시.
class _DayNumber extends StatelessWidget {
  const _DayNumber({
    required this.day,
    required this.isToday,
  });

  final int day;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    if (isToday) {
      // 오늘: 초록 원형 배경에 흰 텍스트
      return Container(
        width: 42.w,
        height: 42.w,
        decoration: const BoxDecoration(
          color: Color(0xFF2DDAA9),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w700,
            fontSize: 30.sp,
            height: 1.4,
            color: Colors.white,
          ),
        ),
      );
    }

    // 일반 날짜: 기본 텍스트
    return Text(
      '$day',
      style: TextStyle(
        fontFamily: 'Pretendard',
        fontWeight: FontWeight.w700,
        fontSize: 30.sp,
        height: 1.4,
        color: const Color(0xFF374151),
      ),
    );
  }
}

/// 출근/퇴근/총 근무시간 기록을 표시하는 섹션
class _RecordSection extends StatelessWidget {
  const _RecordSection({
    required this.clockIn,
    required this.clockOut,
    required this.totalHours,
  });

  final String? clockIn;
  final String? clockOut;
  final String? totalHours;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 278.w,
      height: 88.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _RecordRow(label: '출근', value: clockIn ?? '-'),
            _RecordRow(label: '퇴근', value: clockOut ?? '-'),
            _RecordRow(label: '총 근무시간', value: totalHours ?? '-'),
          ],
        ),
      ),
    );
  }
}

/// 레이블-값 쌍을 한 줄로 표시하는 행 위젯
class _RecordRow extends StatelessWidget {
  const _RecordRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            height: 1.2,
            color: const Color(0xFF374151),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 20.sp,
            height: 1.2,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }
}
