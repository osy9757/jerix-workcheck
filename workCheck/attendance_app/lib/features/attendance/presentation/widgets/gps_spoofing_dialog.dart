import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// GPS 조작(가상 위치) 감지 경고 다이얼로그
///
/// Mock Location 앱이나 조작된 GPS가 감지되었을 때 표시.
/// 사용자에게 정상 GPS 사용을 요청하고 인증을 차단한다.
class GpsSpoofingDialog extends StatelessWidget {
  final String reason;

  const GpsSpoofingDialog({
    super.key,
    required this.reason,
  });

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show(BuildContext context, {String? reason}) {
    return showDialog(
      context: context,
      barrierDismissible: false, // 배경 터치로 닫기 불가
      builder: (_) => GpsSpoofingDialog(
        reason: reason ?? '가상 위치 앱이 감지되었습니다',
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
                    colorFilter: const ColorFilter.mode(
                      Color(0xFFEF4444),
                      BlendMode.srcIn,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // 제목
                  Text(
                    'GPS 조작 감지',
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
                  // 감지 사유
                  Text(
                    reason,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                      height: 1.4,
                      letterSpacing: 16.sp * -0.02,
                      color: const Color(0xFFEF4444),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  // 안내 메시지
                  Text(
                    '출퇴근 등록은 실제 GPS 위치로만 가능합니다.\n'
                    '가상 위치 앱을 종료하거나\n'
                    '개발자 옵션에서 모의 위치를 해제해주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 14.sp,
                      height: 1.5,
                      letterSpacing: 14.sp * -0.02,
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
