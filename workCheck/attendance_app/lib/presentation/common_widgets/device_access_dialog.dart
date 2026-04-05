import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 기기 접근 제한 안내 다이얼로그
///
/// 접속이 허용되지 않은 기기로 로그인 시도 시 표시.
/// 제목, 내용, 액션 버튼을 외부에서 주입받아 유연하게 사용 가능.
class DeviceAccessDialog extends StatelessWidget {
  const DeviceAccessDialog({
    super.key,
    required this.title,
    required this.content,
    required this.buttonText,
    this.onButtonPressed,
  });

  /// 다이얼로그 제목
  final String title;

  /// 안내 내용 본문
  final String content;

  /// 액션 버튼 텍스트
  final String buttonText;

  /// 액션 버튼 클릭 콜백 (null이면 버튼 비활성)
  final VoidCallback? onButtonPressed;

  /// 다이얼로그를 표시하는 정적 메서드
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    required String buttonText,
    VoidCallback? onButtonPressed,
    bool barrierDismissible = false,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => DeviceAccessDialog(
        title: title,
        content: content,
        buttonText: buttonText,
        onButtonPressed: onButtonPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Padding(
        padding: EdgeInsets.fromLTRB(26.w, 32.h, 26.w, 24.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22.sp,
                height: 1.4,
                letterSpacing: 22.sp * -0.02,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            // 안내 내용 본문
            SizedBox(
              width: double.infinity,
              child: Text(
                content,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  height: 1.4,
                  letterSpacing: 14.sp * -0.02,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            // 액션 버튼
            SizedBox(
              width: 295.w,
              height: 57.h,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDAA9),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(
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
