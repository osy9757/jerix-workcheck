import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'pages/dashboard_page.dart';

/// WorkCheck 관리자 웹 앱 엔트리포인트 (MVP 시연용 - 로그인 없음)
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
      // MVP: 로그인 없이 바로 대시보드
      home: DashboardPage(apiService: apiService),
    );
  }
}
