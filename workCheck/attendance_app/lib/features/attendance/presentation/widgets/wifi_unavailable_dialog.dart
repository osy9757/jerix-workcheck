import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// WiFi 인증 불가 다이얼로그
///
/// 출퇴근 등록 가능한 WiFi 범위 밖일 때 표시.
/// 사용자가 허용된 WiFi 위치로 이동하도록 안내함.
class WifiUnavailableDialog extends StatelessWidget {
  const WifiUnavailableDialog({super.key});

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 불가
      builder: (_) => const WifiUnavailableDialog(),
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
            // 콘텐츠 영역
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 26.w),
              child: Column(
                children: [
                  // 경고 아이콘
                  SvgPicture.asset(
                    'assets/icons/mark.svg',
                    width: 56.w,
                    height: 56.w,
                  ),
                  SizedBox(height: 16.h),
                  // 제목
                  Text(
                    '출퇴근 등록 불가',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 18.sp,
                      height: 1.4,
                      letterSpacing: 18.sp * -0.02,
                      color: const Color(0xFF000000),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 안내 메시지
                  Text(
                    '출퇴근 등록 가능한 위치가 아닙니다\n근태 체크 가능한 WIFI로 이동하세요',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: 16.sp * -0.02,
                      color: const Color(0xFF374151),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 26.h),
            // 확인 버튼
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
