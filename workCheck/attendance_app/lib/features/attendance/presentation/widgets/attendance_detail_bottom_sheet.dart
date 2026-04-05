import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 특정 날짜의 출퇴근 상세 정보를 바텀시트로 표시하는 위젯
///
/// 출근시간, 퇴근시간, 총 근무시간을 표시함.
class AttendanceDetailBottomSheet extends StatelessWidget {
  const AttendanceDetailBottomSheet({
    super.key,
    required this.day,
    required this.weekdayName,
    this.clockIn,
    this.clockOut,
  });

  /// 날짜 (일)
  final int day;

  /// 요일 이름 (예: '월요일')
  final String weekdayName;

  /// 출근 시간 문자열 (HH:mm 형식, null이면 미기록)
  final String? clockIn;

  /// 퇴근 시간 문자열 (HH:mm 형식, null이면 미기록)
  final String? clockOut;

  /// 바텀시트를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required int day,
    required String weekdayName,
    String? clockIn,
    String? clockOut,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => AttendanceDetailBottomSheet(
        day: day,
        weekdayName: weekdayName,
        clockIn: clockIn,
        clockOut: clockOut,
      ),
    );
  }

  /// 출퇴근 시간으로 총 근무시간 계산
  ///
  /// 퇴근 - 출근 시간의 차이를 'XX시간 YY분' 형식으로 반환.
  /// 계산 불가 시 '-' 반환.
  String _calculateWorkDuration() {
    final inTime = clockIn;
    final outTime = clockOut;

    // 출퇴근 시간 중 하나라도 없으면 계산 불가
    if (inTime == null || outTime == null || inTime == '-' || outTime == '-') {
      return '-';
    }

    try {
      final inParts = inTime.split(':');
      final outParts = outTime.split(':');

      if (inParts.length < 2 || outParts.length < 2) return '-';

      final inHour = int.parse(inParts[0]);
      final inMinute = int.parse(inParts[1]);
      final outHour = int.parse(outParts[0]);
      final outMinute = int.parse(outParts[1]);

      // 분 단위로 변환 후 차이 계산
      final inTotal = inHour * 60 + inMinute;
      final outTotal = outHour * 60 + outMinute;
      final diff = outTotal - inTotal;

      // 음수면 계산 불가
      if (diff < 0) return '-';

      final hours = diff ~/ 60;
      final minutes = diff % 60;

      if (minutes == 0) {
        return '${hours.toString().padLeft(2, '0')}시간';
      } else {
        return '${hours.toString().padLeft(2, '0')}시간 ${minutes.toString().padLeft(2, '0')}분';
      }
    } catch (_) {
      return '-';
    }
  }

  /// 출근/퇴근/근무시간 행 위젯 생성
  ///
  /// [barColor]: 좌측 구분 바 색상
  /// [iconPath]: SVG 아이콘 경로
  /// [label]: 항목 레이블
  /// [value]: 표시할 값
  Widget _buildRow({
    required Color barColor,
    required String iconPath,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        // 좌측 색상 바
        Container(
          width: 2.w,
          height: 30.h,
          color: barColor,
        ),
        SizedBox(width: 8.w),
        // 아이콘
        SvgPicture.asset(
          iconPath,
          width: 20.w,
          height: 20.h,
          colorFilter: const ColorFilter.mode(
            Color(0xFF5D5F6D),
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: 6.w),
        // 레이블
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
            height: 1.4,
            letterSpacing: 0,
            color: const Color(0xFF374151),
          ),
        ),
        const Spacer(),
        // 시간 값
        Text(
          value,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w600,
            fontSize: 22.sp,
            height: 1.4,
            letterSpacing: 0,
            color: const Color(0xFF000000),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 총 근무시간 계산
    final workDuration = _calculateWorkDuration();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 20.h,
        bottom: 42.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 날짜 헤더 (예: 15일 월요일)
          SizedBox(
            width: 343.w,
            height: 50.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$day일 $weekdayName',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontWeight: FontWeight.w600,
                  fontSize: 22.sp,
                  height: 1.4,
                  letterSpacing: 0,
                  color: const Color(0xFF000000),
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          // 출근 시간 행
          _buildRow(
            barColor: const Color(0xFF2DDAA9),
            iconPath: 'assets/icons/goWork.svg',
            label: '출근시간',
            value: clockIn ?? '-',
          ),
          SizedBox(height: 10.h),
          // 퇴근 시간 행
          _buildRow(
            barColor: const Color(0xFF8A38F5),
            iconPath: 'assets/icons/finishWork.svg',
            label: '퇴근시간',
            value: clockOut ?? '-',
          ),
          SizedBox(height: 20.h),
          // 총 근무시간 행
          _buildRow(
            barColor: const Color(0xFF1400FF),
            iconPath: 'assets/icons/time.svg',
            label: '총 근무시간',
            value: workDuration,
          ),
        ],
      ),
    );
  }
}
