import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/navigation/app_router.dart';

/// 기기 접속 승인 대기 화면 (기기 바인딩)
///
/// 기기 접속 허용 요청을 보낸 뒤 표시되는 대기 안내 화면.
/// - 인사 담당자의 승인을 기다리는 동안 노출
/// - [요청취소] → 로그인 화면으로 복귀
/// - [접속하기] → 로그인 화면으로 복귀해 다시 로그인 시도
class DeviceWaitingScreen extends StatelessWidget {
  const DeviceWaitingScreen({super.key});

  /// 메인 컬러
  static const Color _mainColor = Color(0xFF2DDAA9);

  /// 로그인 화면으로 복귀 (요청취소 / 재시도 공통 동작)
  void _goToLogin(BuildContext context) {
    context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              // 대기 아이콘
              Container(
                width: 96.w,
                height: 96.w,
                decoration: const BoxDecoration(
                  color: Color(0x1A2DDAA9), // 메인 컬러 10% 배경
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.hourglass_top_rounded,
                  size: 48.w,
                  color: _mainColor,
                ),
              ),
              SizedBox(height: 32.h),
              // 대기 제목 (PPT 원문)
              Text(
                '접속이 허용된 기기가 아닙니다.',
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
              // 대기 안내 본문 (PPT 원문)
              Text(
                '접속 허용 요청에 대해서 인사 담당자의 확인 대기 중입니다.\n'
                '잠시만 기다려 주시기 바랍니다.\n\n'
                '대기가 길어지면 인사부서에 문의 하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                  height: 1.5,
                  letterSpacing: 14.sp * -0.02,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              // 접속하기 버튼 (승인 후 재로그인, 동작 동일)
              SizedBox(
                width: double.infinity,
                height: 57.h,
                child: ElevatedButton(
                  onPressed: () => _goToLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '접속하기',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      height: 1.4,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              // 요청취소 버튼 (로그인 복귀)
              SizedBox(
                width: double.infinity,
                height: 57.h,
                child: OutlinedButton(
                  onPressed: () => _goToLogin(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _mainColor,
                    side: const BorderSide(color: _mainColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '요청취소',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      height: 1.4,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}
