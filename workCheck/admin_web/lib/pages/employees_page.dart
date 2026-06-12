import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

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
                TextField(
                  controller: companyCodeCtrl,
                  decoration: const InputDecoration(
                    labelText: '회사 코드',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: employeeIdCtrl,
                  decoration: const InputDecoration(
                    labelText: '사원 번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '이름',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: '이메일 (선택)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: departmentCtrl,
                  decoration: const InputDecoration(
                    labelText: '부서 (선택)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DDAA9).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline,
                          size: 16, color: Color(0xFF1B7E62)),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '비밀번호는 직원이 앱 회원가입에서 직접 설정합니다(미가입 상태로 등록). 등록 시 백엔드가 5개 인증 method(GPS/WiFi/NFC/Beacon/QR)를 자동 생성하며, 이후 "인증 설정"에서 켜고 편집하세요.',
                          style: TextStyle(
                              fontSize: 11, color: Color(0xFF1B7E62)),
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
          ElevatedButton(
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
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('등록에 실패했습니다')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DDAA9),
              foregroundColor: Colors.white,
            ),
            child: const Text('등록'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '직원 관리',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: _loadData,
              ),
              const SizedBox(width: 4),
              ElevatedButton.icon(
                icon: const Icon(Icons.person_add),
                label: const Text('직원 등록'),
                onPressed: _showAddDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDAA9),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '인증 설정은 좌측 "인증 설정" 메뉴에서 유저 단위로 5개 방식을 ON/OFF 합니다.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child:
                    Text(_error!, style: const TextStyle(color: Colors.red)))
          else
            Expanded(
              child: Card(
                elevation: 1,
                child: SingleChildScrollView(
                  child: SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFF2DDAA9).withOpacity(0.1),
                      ),
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
                        return DataRow(cells: [
                          DataCell(Text('${emp.id}')),
                          DataCell(Text(emp.employeeId)),
                          DataCell(Text(emp.name)),
                          DataCell(Text(emp.department ?? '-')),
                          DataCell(Text(emp.email ?? '-')),
                          DataCell(Text(created)),
                        ]);
                      }).toList(),
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
