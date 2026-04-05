import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../features/attendance/presentation/bloc/attendance_bloc.dart';
import '../../features/attendance/presentation/screens/attendance_screen.dart';
import '../../features/attendance/presentation/screens/history_screen.dart';
import '../../features/attendance/presentation/screens/qr_scan_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/settings_screen.dart';

abstract class AppRoutes {
  static const login = '/login';
  static const attendance = '/';
  static const history = '/history';
  static const register = '/register';
  static const settings = '/settings';
  static const qrScan = '/qr-scan';
}

/// 글로벌 네비게이터 키 (서비스 레이어에서 다이얼로그 표시용)
final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.login,
  debugLogDiagnostics: true,
  routes: [
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
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
