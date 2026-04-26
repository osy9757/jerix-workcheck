import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'verification_page.dart';
import 'attendance_page.dart';
import 'verification_presets_page.dart';

/// 대시보드 - MVP 시연용 간략화 (인증 설정 + 인증 프리셋 + 출퇴근 기록)
class DashboardPage extends StatefulWidget {
  final ApiService apiService;
  const DashboardPage({super.key, required this.apiService});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;

  /// 사이드바 인덱스에 해당하는 페이지 반환
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return VerificationPage(apiService: widget.apiService);
      case 1:
        return VerificationPresetsPage(apiService: widget.apiService);
      case 2:
        return AttendancePage(apiService: widget.apiService);
      default:
        return VerificationPage(apiService: widget.apiService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드바
          NavigationRail(
            extended: MediaQuery.of(context).size.width > 900,
            backgroundColor: const Color(0xFF1E1E2D),
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = index);
            },
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  const Icon(Icons.work, color: Color(0xFF2DDAA9), size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'WorkCheck',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'MVP Demo',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            selectedIconTheme: const IconThemeData(color: Color(0xFF2DDAA9)),
            unselectedIconTheme: const IconThemeData(color: Colors.white54),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF2DDAA9)),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.tune),
                label: Text('인증 설정'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bookmark),
                label: Text('인증 프리셋'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('출퇴근 기록'),
              ),
            ],
          ),

          // 메인 콘텐츠
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }
}
