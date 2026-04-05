import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

/// WorkCheck 관리자 웹 앱 엔트리포인트
void main() {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2DDAA9),
        ),
        useMaterial3: true,
      ),
      // 로그인 상태에 따라 초기 화면 결정
      initialRoute: apiService.isLoggedIn ? '/dashboard' : '/login',
      routes: {
        '/login': (_) => LoginPage(apiService: apiService),
        '/dashboard': (_) => DashboardPage(apiService: apiService),
      },
    );
  }
}
