import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/admin_theme.dart';
import 'verification_page.dart';
import 'attendance_page.dart';
import 'verification_presets_page.dart';
import 'device_requests_page.dart';
import 'employees_page.dart';

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
      case 3:
        return DeviceRequestsPage(apiService: widget.apiService);
      case 4:
        // 직원 관리 — D3 가입 구조(사전 등록 직원만 가입 가능)의 등록 진입점
        return EmployeesPage(apiService: widget.apiService);
      default:
        return VerificationPage(apiService: widget.apiService);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // 사이드바 (다크 — 호버/클릭 오버레이가 보이도록 밝은 오버레이 색만 재정의)
          Theme(
            data: Theme.of(context).copyWith(
              hoverColor: Colors.white.withValues(alpha: 0.06),
              splashColor: Colors.white.withValues(alpha: 0.08),
              highlightColor: Colors.transparent,
            ),
            child: NavigationRail(
              extended: MediaQuery.of(context).size.width > 900,
              backgroundColor: AdminColors.sidebar,
              minExtendedWidth: 220,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                setState(() => _selectedIndex = index);
              },
              // 로고 영역: 브랜드 라운드 박스 + 워드마크 + 미세 구분선
              leading: Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 8),
                child: Column(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AdminColors.primary,
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: AdminColors.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fact_check_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'WorkCheck',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'MVP Demo',
                      style: TextStyle(
                        color: AdminColors.sidebarText,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // 로고와 메뉴 사이 미세 구분선
                    Container(
                      width: 40,
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ],
                ),
              ),
              // 선택 상태: 브랜드 톤 인디케이터 + primary 아이콘/라벨
              useIndicator: true,
              indicatorColor: AdminColors.primary.withValues(alpha: 0.16),
              indicatorShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              selectedIconTheme:
                  const IconThemeData(color: AdminColors.primary, size: 22),
              unselectedIconTheme:
                  const IconThemeData(color: AdminColors.sidebarText, size: 22),
              selectedLabelTextStyle: const TextStyle(
                color: AdminColors.primary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelTextStyle: const TextStyle(
                color: AdminColors.sidebarText,
                fontSize: 14,
              ),
              // [BACKLOG] 하단 로그아웃 버튼 — 토큰 삭제 후 로그인 페이지로 이동
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: const Icon(Icons.logout, size: 20),
                      tooltip: '로그아웃',
                      style: IconButton.styleFrom(
                        foregroundColor: AdminColors.sidebarText,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        hoverColor: Colors.white.withValues(alpha: 0.1),
                        minimumSize: const Size(42, 42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        widget.apiService.clearToken();
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                    ),
                  ),
                ),
              ),
              // 메뉴: 비선택=outlined / 선택=filled 아이콘, 항목 간 여백 정리
              destinations: const [
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  icon: Icon(Icons.tune),
                  label: Text('인증 설정'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  icon: Icon(Icons.bookmark_outline),
                  selectedIcon: Icon(Icons.bookmark),
                  label: Text('인증 프리셋'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  icon: Icon(Icons.history),
                  label: Text('출퇴근 기록'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  icon: Icon(Icons.phone_android),
                  label: Text('기기 승인'),
                ),
                NavigationRailDestination(
                  padding: EdgeInsets.symmetric(vertical: 2),
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people),
                  label: Text('직원 관리'),
                ),
              ],
            ),
          ),

          // 메인 콘텐츠
          Expanded(child: _buildPage()),
        ],
      ),
    );
  }
}
