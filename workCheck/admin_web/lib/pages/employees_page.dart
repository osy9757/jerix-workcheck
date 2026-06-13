import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../theme/admin_theme.dart'; // 디자인 토큰
import '../widgets/ui_kit.dart'; // 공통 UI 컴포넌트

/// 직원 관리 페이지 (api_contract v2 — workplace 폐기)
/// - 직원 목록 조회 + 등록
/// - 등록 시 백엔드가 5 method row 자동 생성. 인증 설정은 "인증 설정" 페이지에서.
class EmployeesPage extends StatefulWidget {
  final ApiService apiService;
  const EmployeesPage({super.key, required this.apiService});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> _employees = []; // 직원 목록
  bool _loading = true; // 로딩 상태
  String? _error; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 직원 목록 로드
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final users = await widget.apiService.getUsers();
      if (mounted) {
        setState(() {
          _employees = users;
          _loading = false;
        });
      }
    } catch (e) {
      debugPrint('[직원] 목록 로드 실패: $e');
      if (mounted) {
        setState(() {
          _error = '직원 목록을 불러올 수 없습니다';
          _loading = false;
        });
      }
    }
  }

  /// 직원 등록 다이얼로그 (workplace 드롭다운 제거됨)
  void _showAddDialog() {
    // [D3] 비밀번호 입력 제거 — 직원이 앱 회원가입에서 직접 설정(미가입 상태로 사전 등록)
    final companyCodeCtrl = TextEditingController(text: 'jerix');
    final employeeIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final departmentCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('직원 등록'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 입력 필드 — 보더/채움은 테마 inputDecorationTheme 의존
                TextField(
                  controller: companyCodeCtrl,
                  decoration: const InputDecoration(labelText: '회사 코드'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: employeeIdCtrl,
                  decoration: const InputDecoration(labelText: '사원 번호'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: '이름'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: '이메일 (선택)'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: departmentCtrl,
                  decoration: const InputDecoration(labelText: '부서 (선택)'),
                ),
                const SizedBox(height: 12),
                // 안내 박스 (비밀번호 없음 구조 안내 — 문구 불변)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.primarySoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: AdminColors.primaryDark),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '비밀번호는 직원이 앱 회원가입에서 직접 설정합니다(미가입 상태로 등록). 등록 시 백엔드가 5개 인증 method(GPS/WiFi/NFC/Beacon/QR)를 자동 생성하며, 이후 "인증 설정"에서 켜고 편집하세요.',
                          style: TextStyle(
                              fontSize: 12, color: AdminColors.primaryDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          FilledButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty || employeeIdCtrl.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('필수 항목을 입력하세요')),
                );
                return;
              }
              try {
                await widget.apiService.createUser(
                  companyCode: companyCodeCtrl.text.trim(),
                  employeeId: employeeIdCtrl.text.trim(),
                  name: nameCtrl.text.trim(),
                  email: emailCtrl.text.trim().isEmpty
                      ? null
                      : emailCtrl.text.trim(),
                  department: departmentCtrl.text.trim().isEmpty
                      ? null
                      : departmentCtrl.text.trim(),
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadData();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('직원이 등록되었습니다')),
                  );
                }
              } catch (e) {
                debugPrint('[직원] 등록 실패: $e');
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('등록에 실패했습니다')),
                  );
                }
              }
            },
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AdminTokens.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 페이지 헤더 (타이틀 + 캡션 + 우측 액션)
          PageHeader(
            title: '직원 관리',
            subtitle: '인증 설정은 좌측 "인증 설정" 메뉴에서 유저 단위로 5개 방식을 ON/OFF 합니다.',
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: _loadData,
              ),
              FilledButton.icon(
                icon: const Icon(Icons.person_add, size: 18),
                label: const Text('직원 등록'),
                onPressed: _showAddDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child: Text(_error!,
                    style: const TextStyle(color: AdminColors.danger)))
          else if (_employees.isEmpty)
            // 직원이 없을 때 빈 상태 표시
            const Expanded(
              child: EmptyState(
                icon: Icons.people_outline,
                message: '등록된 직원이 없습니다',
              ),
            )
          else
            Expanded(
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  // 헤더 모서리 잘림 방지
                  borderRadius:
                      BorderRadius.circular(AdminTokens.radiusCard),
                  child: SingleChildScrollView(
                    child: SizedBox(
                      width: double.infinity,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('ID')),
                          DataColumn(label: Text('사원 번호')),
                          DataColumn(label: Text('이름')),
                          DataColumn(label: Text('부서')),
                          DataColumn(label: Text('이메일')),
                          DataColumn(label: Text('등록일')),
                        ],
                        rows: _employees.map((emp) {
                          final created = emp.createdAt.isEmpty
                              ? '-'
                              : emp.createdAt.substring(
                                  0,
                                  emp.createdAt.length >= 10
                                      ? 10
                                      : emp.createdAt.length);
                          return DataRow(
                            // 행 호버 시 옅은 배경
                            color: WidgetStateProperty.resolveWith((s) =>
                                s.contains(WidgetState.hovered)
                                    ? AdminColors.surfaceAlt
                                    : null),
                            cells: [
                              DataCell(Text('${emp.id}')),
                              DataCell(Text(emp.employeeId)),
                              DataCell(Text(emp.name)),
                              DataCell(Text(emp.department ?? '-')),
                              DataCell(Text(emp.email ?? '-')),
                              DataCell(Text(created)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
