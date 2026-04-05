import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 앱 공통 텍스트 입력 필드 위젯
///
/// 디자인 시스템에 맞게 통일된 스타일의 TextField.
/// 오류 메시지가 있으면 필드 아래에 빨간 텍스트로 표시.
/// 포커스 시 테두리 색상 강조 가능.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.controller,
    this.onChanged,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
    this.focusedBorderColor,
    this.errorText,
  });

  /// 플레이스홀더 텍스트
  final String hintText;

  /// 비밀번호 모드 여부 (true이면 입력 내용 마스킹)
  final bool obscureText;

  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  /// 읽기 전용 여부 (보안 키패드와 함께 사용 시 true)
  final bool readOnly;

  final VoidCallback? onTap;
  final FocusNode? focusNode;

  /// 포커스 시 테두리 색상 (null이면 기본 색상)
  final Color? focusedBorderColor;

  /// 오류 메시지 (null이면 오류 없음)
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    const errorColor = Color(0xFFDC2626);
    // 기본 테두리 색상
    const defaultBorderColor = Color(0xFFE9EBF1);

    return SizedBox(
      width: 343.w,
      height: 56.h,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          TextField(
            controller: controller,
            obscureText: obscureText,
            onChanged: onChanged,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            focusNode: focusNode,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: const Color(0xFFB0B3C0),
              ),
              filled: true,
              fillColor: const Color(0xFFFFFFFF),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
              // 비포커스 테두리: 오류 시 빨강, 정상 시 기본 색
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: hasError ? errorColor : defaultBorderColor,
                  width: hasError ? 2 : 1,
                ),
              ),
              // 포커스 테두리: 오류 시 빨강, 정상 시 지정 색 또는 기본 색
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: hasError
                      ? errorColor
                      : focusedBorderColor ?? defaultBorderColor,
                  width: (hasError || focusedBorderColor != null) ? 2 : 1,
                ),
              ),
            ),
          ),
          // 오류 메시지 (필드 바로 아래 표시)
          if (hasError)
            Positioned(
              left: 0,
              top: 56.h,
              child: Text(
                errorText!,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  height: 1.4,
                  letterSpacing: 12.sp * -0.02,
                  color: errorColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
