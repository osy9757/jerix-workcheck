import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/device_id_provider.dart';
import '../../../../presentation/navigation/app_router.dart';

/// 기기 접속 승인 대기 화면 (기기 바인딩)
///
/// 기기 접속 허용 요청을 보낸 뒤 표시되는 대기 안내 화면.
/// - [pollInterval] 주기로 서버 기기 상태를 폴링해 승인(APPROVED) 감지
/// - 승인되면 [접속하기] 버튼 활성화 → 사용자가 직접 탭하면 로그인 화면 복귀
/// - [요청취소] → 서버 PENDING row 삭제 후 로그인 화면 복귀
///
/// 자격증명([companyCode]/[employeeId]/[password])은 로그인·가입 경로에서
/// GoRouter extra로 전달된다. null이면(딥링크/예외 진입) 폴링·취소를 생략하고
/// 기존처럼 로그인 복귀만 한다(폴백).
class DeviceWaitingScreen extends StatefulWidget {
  const DeviceWaitingScreen({
    super.key,
    this.companyCode,
    this.employeeId,
    this.password,
  });

  /// 폴링·취소 API에 사용할 자격증명 (extra 미전달 시 null → 폴백)
  final String? companyCode;
  final String? employeeId;
  final String? password;

  /// 기기 상태 폴링 주기 (테스트용 설정값 — 줄이면 즉각 감지, 늘리면 지연 감지)
  static const Duration pollInterval = Duration(seconds: 5);

  @override
  State<DeviceWaitingScreen> createState() => _DeviceWaitingScreenState();
}

class _DeviceWaitingScreenState extends State<DeviceWaitingScreen> {
  /// 메인 컬러
  static const Color _mainColor = Color(0xFF2DDAA9);

  /// 폴링 타이머
  Timer? _pollTimer;

  /// 승인 완료 여부 (true면 [접속하기] 버튼 활성화)
  bool _approved = false;

  /// 폴링 가능 여부 (자격증명이 모두 있어야 함)
  bool get _canPoll =>
      widget.companyCode != null &&
      widget.employeeId != null &&
      widget.password != null;

  @override
  void initState() {
    super.initState();
    // 자격증명이 있을 때만 폴링 시작 (없으면 기존처럼 안내만)
    if (_canPoll) {
      _checkStatus(); // 즉시 1회
      _pollTimer =
          Timer.periodic(DeviceWaitingScreen.pollInterval, (_) => _checkStatus());
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  /// 로그인 화면으로 복귀 (요청취소 / 승인 후 접속하기 공통 동작)
  void _goToLogin(BuildContext context) {
    _pollTimer?.cancel();
    context.go(AppRoutes.login);
  }

  /// 기기 상태 폴링 (5초 주기)
  ///
  /// APPROVED: 타이머 취소 + 버튼 활성화. REJECTED/NONE: 안내 후 로그인 복귀.
  /// PENDING: 대기 유지. 네트워크 오류: 무시하고 다음 주기 재시도.
  Future<void> _checkStatus() async {
    try {
      final deviceId = await getIt<DeviceIdProvider>().getDeviceId();
      final dio = getIt<Dio>();
      final response = await dio.post(
        ApiConstants.deviceStatus,
        data: {
          'company_code': widget.companyCode,
          'employee_id': widget.employeeId,
          'device_id': deviceId,
        },
      );

      if (!mounted) return;
      final status = (response.data as Map<String, dynamic>)['status'] as String?;

      switch (status) {
        case 'APPROVED':
          // 승인 감지 → 폴링 중단 + 버튼 활성화 (자동 로그인 아님, PPT 일치)
          _pollTimer?.cancel();
          setState(() => _approved = true);
          break;
        case 'REJECTED':
        case 'NONE':
          // 거부 또는 요청 삭제됨 → 안내 후 로그인 복귀
          _pollTimer?.cancel();
          _showSnack(
            status == 'REJECTED'
                ? '기기 접속 요청이 거부되었습니다.'
                : '기기 접속 요청이 취소되었습니다.',
          );
          _goToLogin(context);
          break;
        default:
          // PENDING 등 → 대기 유지
          break;
      }
    } catch (_) {
      // 네트워크 오류: 무시하고 다음 주기에 재시도 (화면 유지)
    }
  }

  /// 요청취소 → 서버 PENDING row 삭제 후 로그인 복귀
  Future<void> _cancelRequest() async {
    // 자격증명이 없으면 서버 호출 없이 로그인 복귀 (폴백)
    if (!_canPoll) {
      _goToLogin(context);
      return;
    }
    try {
      final deviceId = await getIt<DeviceIdProvider>().getDeviceId();
      final dio = getIt<Dio>();
      await dio.post(
        ApiConstants.deviceCancel,
        data: {
          'company_code': widget.companyCode,
          'employee_id': widget.employeeId,
          'password': widget.password,
          'device_id': deviceId,
        },
      );
    } catch (_) {
      // 취소 실패해도 로그인 복귀 (안내만)
      if (mounted) _showSnack('요청 취소 처리 중 오류가 발생했습니다.');
    }
    if (mounted) _goToLogin(context);
  }

  /// 하단 스낵바 안내
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
              // 대기/승인 아이콘
              Container(
                width: 96.w,
                height: 96.w,
                decoration: const BoxDecoration(
                  color: Color(0x1A2DDAA9), // 메인 컬러 10% 배경
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _approved
                      ? Icons.check_circle_rounded
                      : Icons.hourglass_top_rounded,
                  size: 48.w,
                  color: _mainColor,
                ),
              ),
              SizedBox(height: 32.h),
              // 제목 (승인 시 완료 문구로 전환)
              Text(
                _approved ? '기기가 승인되었습니다.' : '접속이 허용된 기기가 아닙니다.',
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
              // 안내 본문 (승인 시 완료 문구로 전환)
              Text(
                _approved
                    ? '인사 담당자의 승인이 완료되었습니다.\n'
                        '아래 접속하기를 눌러 로그인 해주세요.'
                    : '접속 허용 요청에 대해서 인사 담당자의 확인 대기 중입니다.\n'
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
              // 접속하기 버튼 (승인 전 비활성 '승인 대기 중', 승인 후 활성 '접속하기')
              SizedBox(
                width: double.infinity,
                height: 57.h,
                child: ElevatedButton(
                  onPressed: _approved ? () => _goToLogin(context) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _mainColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFBDBDBD),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _approved ? '접속하기' : '승인 대기 중',
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
              // 요청취소 버튼 (서버 PENDING row 삭제 후 로그인 복귀)
              SizedBox(
                width: double.infinity,
                height: 57.h,
                child: OutlinedButton(
                  onPressed: _cancelRequest,
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
