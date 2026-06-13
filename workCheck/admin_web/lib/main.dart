import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
import 'theme/admin_theme.dart';

/// WorkCheck 관리자 웹 앱 엔트리포인트
/// [BACKLOG] 관리자 API 인증 활성화 — 백엔드 /admin/** 인터셉터가 켜졌으므로
/// 로그인(JWT) 없이는 관리 API 가 401. 토큰 보유 시 대시보드, 없으면 로그인 페이지.
void main() {
  // 전역 Flutter 에러 핸들러 — 테스트 중 위젯/렌더 예외 원인 콘솔 노출 (웹 릴리스 자동 no-op)
  FlutterError.onError = (d) => debugPrint('[FlutterError] ${d.exception}\n${d.stack}');
  runApp(const AdminWebApp());
}

class AdminWebApp extends StatelessWidget {
  const AdminWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService();

    return MaterialApp(
      title: 'WorkCheck 관리자',
      debugShowCheckedModeBanner: false,
      // 관리자 웹 공통 테마 (theme/admin_theme.dart)
      theme: buildAdminTheme(),
      // [BACKLOG] 저장된 admin_token 유무로 초기 진입 분기 (named route)
      initialRoute: apiService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => LoginPage(apiService: apiService),
        '/dashboard': (context) => DashboardPage(apiService: apiService),
      },
    );
  }
}
