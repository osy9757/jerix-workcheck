import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/utils/device_id_provider.dart';
import '../../../../presentation/navigation/app_router.dart';
import '../../data/datasources/local/auth_local_datasource.dart';

/// 스플래시 화면 (영속 자동로그인)
///
/// 앱 시작 시 저장된 토큰으로 세션 체크(GET /auth/session)를 수행한다.
/// - 토큰 없음 → 로그인 화면
/// - 200(세션 유효) → 토큰/인증방법/이름 갱신 후 홈 진입
/// - 401/403/네트워크 오류/타임아웃 → 로그인 화면 폴백(안전)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// 메인 컬러
  static const Color _mainColor = Color(0xFF2DDAA9);

  final AuthLocalDatasource _authLocal = getIt<AuthLocalDatasource>();

  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  /// 저장된 토큰으로 세션을 확인하고 자동 로그인 또는 로그인 화면으로 분기
  Future<void> _checkAutoLogin() async {
    // 1. 저장된 토큰이 없으면 바로 로그인 화면
    final token = await _authLocal.getToken();
    if (token == null || token.isEmpty) {
      _goLogin();
      return;
    }

    try {
      // 2. 세션 체크 (Bearer 토큰은 _AuthInterceptor 가 자동 주입)
      final deviceId = await getIt<DeviceIdProvider>().getDeviceId();
      final dio = getIt<Dio>();
      final response = await dio.get(
        ApiConstants.session,
        queryParameters: {'device_id': deviceId},
      );

      // 3. 재발급 토큰/활성 인증방법/이름 갱신 저장
      final data = response.data as Map<String, dynamic>;
      final newToken = data['token'] as String?;
      if (newToken != null && newToken.isNotEmpty) {
        await _authLocal.saveToken(newToken);
      }
      final user = data['user'] as Map<String, dynamic>?;
      if (user != null && user['name'] != null) {
        await _authLocal.saveUserName(user['name'] as String);
      }
      final enabledMethods = (data['enabled_methods'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList();
      if (enabledMethods != null) {
        await _authLocal.saveEnabledMethods(enabledMethods);
      }

      // 4. 홈으로 진입
      if (mounted) context.go(AppRoutes.attendance);
    } on DioException catch (e) {
      // 401(만료/무효) → 모든 인증정보 삭제. 403(기기 차단) → 토큰만 삭제.
      // 둘 다 로그인 화면으로 폴백(로그인 시 기존 기기 바인딩 플로우 재사용).
      if (e.response?.statusCode == 401) {
        await _authLocal.clearAll();
      } else if (e.response?.statusCode == 403) {
        await _authLocal.clearToken();
      }
      _goLogin();
    } catch (_) {
      // 타임아웃/네트워크 오류 등 → 안전하게 로그인 화면 폴백
      _goLogin();
    }
  }

  /// 로그인 화면으로 이동
  void _goLogin() {
    if (mounted) context.go(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 로고 영역 (임시 플레이스홀더 — 로그인 화면과 동일 스타일)
            Container(
              width: 222.w,
              height: 130.h,
              decoration: BoxDecoration(
                color: const Color(0xFFD9D9D9),
                borderRadius: BorderRadius.circular(8.r),
              ),
              alignment: Alignment.center,
              child: Text(
                '로고영역',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black54,
                ),
              ),
            ),
            SizedBox(height: 40.h),
            SizedBox(
              width: 28.w,
              height: 28.w,
              child: const CircularProgressIndicator(
                color: _mainColor,
                strokeWidth: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
