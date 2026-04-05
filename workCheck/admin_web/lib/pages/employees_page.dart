import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// 직원 관리 페이지 - 근무지 배정 + 유저별 인증 오버라이드
class EmployeesPage extends StatefulWidget {
  final ApiService apiService;
  const EmployeesPage({super.key, required this.apiService});

  @override
  State<EmployeesPage> createState() => _EmployeesPageState();
}

class _EmployeesPageState extends State<EmployeesPage> {
  List<Employee> _employees = []; // 직원 목록
  List<Workplace> _workplaces = []; // 근무지 목록 (드롭다운용)
  bool _loading = true; // 로딩 상태
  String? _error; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 직원 + 근무지 동시 로드
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        widget.apiService.getUsers(),
        widget.apiService.getWorkplaces(),
      ]);
      if (mounted) {
        setState(() {
          _employees = results[0] as List<Employee>;
          _workplaces = results[1] as List<Workplace>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '데이터를 불러올 수 없습니다'; _loading = false; });
    }
  }

  /// 직원 등록 다이얼로그
  void _showAddDialog() {
    final companyCodeCtrl = TextEditingController(text: 'CU01');
    final employeeIdCtrl = TextEditingController();
    final nameCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    int? selectedWorkplaceId = _workplaces.isNotEmpty ? _workplaces.first.id : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('직원 등록'),
          content: SizedBox(
            width: 400,
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
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // 근무지 선택 드롭다운
                DropdownButtonFormField<int>(
                  value: selectedWorkplaceId,
                  decoration: const InputDecoration(
                    labelText: '근무지',
                    border: OutlineInputBorder(),
                  ),
                  items: _workplaces.map((wp) {
                    return DropdownMenuItem(
                      value: wp.id,
                      child: Text(wp.name),
                    );
                  }).toList(),
                  onChanged: (v) => setDialogState(() => selectedWorkplaceId = v),
                ),
              ],
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
                  final emp = await widget.apiService.createUser(
                    companyCode: companyCodeCtrl.text,
                    employeeId: employeeIdCtrl.text,
                    name: nameCtrl.text,
                    password: passwordCtrl.text,
                  );
                  // 근무지 배정
                  if (selectedWorkplaceId != null) {
                    await widget.apiService.assignUserWorkplace(
                      emp.id, selectedWorkplaceId!,
                    );
                  }
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
      ),
    );
  }

  /// 근무지 변경 다이얼로그
  void _showWorkplaceChangeDialog(Employee emp) {
    int? selectedId = emp.workplaceId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('${emp.name} - 근무지 변경'),
          content: SizedBox(
            width: 300,
            child: DropdownButtonFormField<int>(
              value: selectedId,
              decoration: const InputDecoration(
                labelText: '근무지',
                border: OutlineInputBorder(),
              ),
              items: _workplaces.map((wp) {
                return DropdownMenuItem(
                  value: wp.id,
                  child: Text(wp.name),
                );
              }).toList(),
              onChanged: (v) => setDialogState(() => selectedId = v),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedId == null) return;
                try {
                  await widget.apiService.assignUserWorkplace(emp.id, selectedId!);
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadData();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('근무지가 변경되었습니다')),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('변경에 실패했습니다')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2DDAA9),
                foregroundColor: Colors.white,
              ),
              child: const Text('변경'),
            ),
          ],
        ),
      ),
    );
  }

  /// 유저별 인증 오버라이드 다이얼로그
  void _showOverrideDialog(Employee emp) async {
    // 유저의 현재 인증 방법 로드
    List<VerificationMethod> methods = [];
    try {
      methods = await widget.apiService.getUserVerificationMethods(emp.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 정보를 불러올 수 없습니다')),
        );
      }
      return;
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => _OverrideDialog(
        employee: emp,
        methods: methods,
        apiService: widget.apiService,
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
          const SizedBox(height: 16),

          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
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
                        DataColumn(label: Text('근무지')),
                        DataColumn(label: Text('등록일')),
                        DataColumn(label: Text('인증 관리')),
                      ],
                      rows: _employees.map((emp) {
                        return DataRow(cells: [
                          DataCell(Text('${emp.id}')),
                          DataCell(Text(emp.employeeId)),
                          DataCell(Text(emp.name)),
                          // 근무지 (클릭 시 변경)
                          DataCell(
                            InkWell(
                              onTap: () => _showWorkplaceChangeDialog(emp),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emp.workplaceName ?? '미배정',
                                    style: TextStyle(
                                      color: emp.workplaceName != null
                                          ? null
                                          : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.edit, size: 14,
                                    color: Colors.grey[400]),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(emp.createdAt.substring(0, 10))),
                          // 개별 설정 버튼
                          DataCell(
                            OutlinedButton.icon(
                              icon: const Icon(Icons.tune, size: 16),
                              label: const Text('개별 설정'),
                              onPressed: () => _showOverrideDialog(emp),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF2DDAA9),
                                side: const BorderSide(color: Color(0xFF2DDAA9)),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4,
                                ),
                              ),
                            ),
                          ),
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

/// 유저별 인증 오버라이드 다이얼로그 (StatefulWidget)
class _OverrideDialog extends StatefulWidget {
  final Employee employee;
  final List<VerificationMethod> methods;
  final ApiService apiService;

  const _OverrideDialog({
    required this.employee,
    required this.methods,
    required this.apiService,
  });

  @override
  State<_OverrideDialog> createState() => _OverrideDialogState();
}

class _OverrideDialogState extends State<_OverrideDialog> {
  late List<VerificationMethod> _methods; // 유저의 인증 방법 목록
  bool _saving = false; // 저장 중 여부

  @override
  void initState() {
    super.initState();
    _methods = List.from(widget.methods);
  }

  /// 개별 토글 오버라이드
  Future<void> _toggleOverride(VerificationMethod method) async {
    setState(() => _saving = true);
    try {
      await widget.apiService.updateUserVerificationOverride(
        widget.employee.id,
        methodType: method.methodType,
        isEnabled: !method.enabled,
        config: method.config,
      );
      // 목록 새로고침
      final updated = await widget.apiService
          .getUserVerificationMethods(widget.employee.id);
      if (mounted) setState(() { _methods = updated; _saving = false; });
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 변경에 실패했습니다')),
        );
      }
    }
  }

  /// 오버라이드 삭제 (근무지 기본값으로 복귀)
  Future<void> _resetToDefault(VerificationMethod method) async {
    setState(() => _saving = true);
    try {
      await widget.apiService.deleteUserVerificationOverride(
        widget.employee.id, method.methodType,
      );
      final updated = await widget.apiService
          .getUserVerificationMethods(widget.employee.id);
      if (mounted) {
        setState(() { _methods = updated; _saving = false; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기본값으로 복귀되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복귀에 실패했습니다')),
        );
      }
    }
  }

  /// 방법 타입의 한글 이름
  String _displayName(String methodType) {
    switch (methodType) {
      case 'GPS': return 'GPS';
      case 'GPS_QR': return 'GPS + QR';
      case 'WIFI': return 'WiFi';
      case 'WIFI_QR': return 'WiFi + QR';
      case 'NFC': return 'NFC';
      case 'NFC_GPS': return 'NFC + GPS';
      case 'BEACON': return 'Beacon';
      case 'BEACON_GPS': return 'Beacon + GPS';
      default: return methodType;
    }
  }

  /// 인증 방법별 아이콘 반환
  IconData _getMethodIcon(String methodType) {
    switch (methodType) {
      case 'GPS':
      case 'GPS_QR':
        return Icons.location_on;
      case 'WIFI':
      case 'WIFI_QR':
        return Icons.wifi;
      case 'NFC':
      case 'NFC_GPS':
        return Icons.nfc;
      case 'BEACON':
      case 'BEACON_GPS':
        return Icons.bluetooth;
      default:
        return Icons.settings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Text('${widget.employee.name} - 인증 설정'),
          const Spacer(),
          if (widget.employee.workplaceName != null)
            Chip(
              label: Text(widget.employee.workplaceName!),
              backgroundColor: const Color(0xFF2DDAA9).withOpacity(0.1),
            ),
        ],
      ),
      content: SizedBox(
        width: 500,
        height: 400,
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : _methods.isEmpty
                ? const Center(child: Text('근무지가 배정되지 않아 인증 방법이 없습니다'))
                : ListView.separated(
                    itemCount: _methods.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final method = _methods[index];
                      return ListTile(
                        leading: Icon(
                          _getMethodIcon(method.methodType),
                          color: method.enabled
                              ? const Color(0xFF2DDAA9)
                              : Colors.grey,
                        ),
                        title: Text(_displayName(method.methodType)),
                        subtitle: Text(
                          method.config.entries
                              .map((e) => '${e.key}: ${e.value}')
                              .join(', '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // ON/OFF 토글
                            Switch(
                              value: method.enabled,
                              onChanged: (_) => _toggleOverride(method),
                              activeColor: const Color(0xFF2DDAA9),
                            ),
                            // 기본값 복귀 버튼
                            IconButton(
                              icon: const Icon(Icons.restore, size: 20),
                              tooltip: '기본값으로 복귀',
                              onPressed: () => _resetToDefault(method),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
