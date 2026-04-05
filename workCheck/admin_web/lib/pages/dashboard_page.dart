import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import 'verification_page.dart';
import 'attendance_page.dart';
import 'employees_page.dart';
import 'workplaces_page.dart';

/// 대시보드 - 사이드바 네비게이션 포함 메인 화면
class DashboardPage extends StatefulWidget {
  final ApiService apiService;
  const DashboardPage({super.key, required this.apiService});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0; // 사이드바 선택 인덱스

  // 대시보드 요약 데이터
  int _activeMethodCount = 0; // 활성화된 인증 방법 수
  bool _loading = true; // 데이터 로딩 중 여부

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  /// 대시보드 요약 데이터 로드 (활성 인증 방법 수)
  Future<void> _loadDashboardData() async {
    try {
      final methods = await widget.apiService.getVerificationMethods();
      if (mounted) {
        setState(() {
          _activeMethodCount = methods.where((m) => m.enabled).length;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// 로그아웃 처리 - 토큰 삭제 후 로그인 화면으로 이동
  void _logout() {
    widget.apiService.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
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
                ],
              ),
            ),
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white54),
                    tooltip: '로그아웃',
                    onPressed: _logout,
                  ),
                ),
              ),
            ),
            selectedIconTheme: const IconThemeData(color: Color(0xFF2DDAA9)),
            unselectedIconTheme: const IconThemeData(color: Colors.white54),
            selectedLabelTextStyle: const TextStyle(color: Color(0xFF2DDAA9)),
            unselectedLabelTextStyle: const TextStyle(color: Colors.white54),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('대시보드'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.verified_user),
                label: Text('인증 설정'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.history),
                label: Text('출퇴근 기록'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people),
                label: Text('직원 관리'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.business),
                label: Text('근무지 관리'),
              ),
            ],
          ),

          // 메인 콘텐츠
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 선택된 탭에 따라 콘텐츠 페이지 반환
  Widget _buildContent() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardHome();
      case 1:
        return VerificationPage(apiService: widget.apiService);
      case 2:
        return AttendancePage(apiService: widget.apiService);
      case 3:
        return EmployeesPage(apiService: widget.apiService);
      case 4:
        return WorkplacesPage(apiService: widget.apiService);
      default:
        return _buildDashboardHome();
    }
  }

  /// 대시보드 홈 화면
  Widget _buildDashboardHome() {
    final now = DateTime.now();
    final dateStr = '${now.year}년 ${now.month}월 ${now.day}일';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '대시보드',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            dateStr,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 32),

          // 요약 카드들
          Row(
            children: [
              _buildSummaryCard(
                '활성 인증 방법',
                _loading ? '-' : '$_activeMethodCount',
                Icons.verified_user,
                const Color(0xFF2DDAA9),
              ),
              const SizedBox(width: 16),
              _buildSummaryCard(
                '오늘 날짜',
                dateStr,
                Icons.calendar_today,
                Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 요약 정보 카드 위젯 (아이콘 + 제목 + 값)
  Widget _buildSummaryCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Container(
        width: 250,
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
