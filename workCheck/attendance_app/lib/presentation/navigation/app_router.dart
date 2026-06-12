import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/history_screen.dart';
import '../../features/attendance/presentation/screens/qr_scan_screen.dart';
import '../../features/auth/presentation/screens/device_waiting_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/settings_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/debug/presentation/screens/debug_scan_screen.dart';
import 'root_navigator_key.dart';

// rootNavigatorKey 는 별도 파일에 두고 여기서 re-export (순환참조 회피).
// 기존에 app_router.dart 에서 rootNavigatorKey 를 import 하던 코드는 무변경 동작.
export 'root_navigator_key.dart';

abstract class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const attendance = '/';
  static const history = '/history';
  static const register = '/register';
  static const settings = '/settings';
  static const qrScan = '/qr-scan';
  static const debugScan = '/debug-scan';
  static const deviceWaiting = '/device-waiting';
}

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  // 앱 시작 시 스플래시에서 영속 자동로그인(세션 체크) 후 홈/로그인으로 분기
  initialLocation: AppRoutes.splash,
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: AppRoutes.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.attendance,
      builder: (context, state) => BlocProvider(
        create: (_) => getIt<AttendanceBloc>()
          ..add(const AttendanceEvent.started()),
        child: const AttendanceScreen(),
      ),
    ),
    GoRoute(
      path: AppRoutes.qrScan,
      builder: (context, state) => const QrScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.history,
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: AppRoutes.debugScan,
      builder: (context, state) => const DebugScanScreen(),
    ),
    GoRoute(
      path: AppRoutes.deviceWaiting,
      builder: (context, state) {
        // 로그인/가입 경로에서 전달한 자격증명(extra)을 대기화면에 넘김 (D11 폴링/취소용).
        // 딥링크/예외 진입 시 extra가 null이면 폴백(폴링·취소 비활성).
        final extra = state.extra as Map<String, String>?;
        return DeviceWaitingScreen(
          companyCode: extra?['companyCode'],
          employeeId: extra?['employeeId'],
          password: extra?['password'],
        );
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
