import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

/// 출근/퇴근 완료 확인 다이얼로그
///
/// 출퇴근 처리 성공 후 시간과 메시지를 표시함.
/// [isClockOut]이 true이면 퇴근, false이면 출근 메시지 표시.
class ClockInConfirmDialog extends StatelessWidget {
  const ClockInConfirmDialog({
    super.key,
    required this.clockInTime,
    this.isClockOut = false,
  });

  /// 출퇴근 처리된 시간
  final DateTime clockInTime;

  /// true이면 퇴근 완료, false이면 출근 완료
  final bool isClockOut;

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(
    BuildContext context, {
    required DateTime clockInTime,
    bool isClockOut = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 불가
      builder: (_) => ClockInConfirmDialog(
        clockInTime: clockInTime,
        isClockOut: isClockOut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: 342.w,
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 체크 아이콘
            SvgPicture.asset(
              'assets/icons/check.svg',
              width: 80.w,
              height: 80.w,
            ),
            SizedBox(height: 16.h),
            // 처리된 시간 (HH:mm:ss 포맷)
            Text(
              DateFormat('HH:mm:ss').format(clockInTime),
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w500,
                fontSize: 18.sp,
                height: 1.4,
                letterSpacing: 18.sp * -0.02,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 6.h),
            // 출근/퇴근 완료 메시지
            Text(
              isClockOut ? '퇴근하였습니다' : '출근하였습니다',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontWeight: FontWeight.w700,
                fontSize: 18.sp,
                height: 1.4,
                letterSpacing: 18.sp * -0.02,
                color: const Color(0xFF000000),
              ),
            ),
            SizedBox(height: 26.h),
            // 확인 버튼: 누르면 다이얼로그 닫힘
            SizedBox(
              width: 295.w,
              height: 57.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDAA9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  '확인',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontWeight: FontWeight.w700,
                    fontSize: 18.sp,
                    height: 1.4,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
