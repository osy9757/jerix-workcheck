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

/// 유저별 인증 오버라이드 다이얼로그 (근무지 무관, 8가지 인증 방법 모두 자유 편집)
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

  // 인증 방법별 편집 컨트롤러 저장 (methodType → field → controller)
  final Map<String, Map<String, TextEditingController>> _controllers = {};
  // 인증 방법별 enabled 상태
  final Map<String, bool> _enabledMap = {};

  @override
  void initState() {
    super.initState();
    _methods = List.from(widget.methods);
    _initControllers();
  }

  /// 각 인증 방법별 config 편집 컨트롤러 초기화
  void _initControllers() {
    for (final method in _methods) {
      _enabledMap[method.methodType] = method.enabled;
      final fields = _getFieldsFor(method.methodType);
      _controllers[method.methodType] = {
        for (final field in fields)
          field: TextEditingController(
            text: method.config[field]?.toString() ?? '',
          ),
      };
    }
  }

  @override
  void dispose() {
    // 컨트롤러 해제
    for (final group in _controllers.values) {
      for (final c in group.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  /// 인증 방법별 설정 필드 목록 (CLAUDE.md 인증방법표 기반)
  List<String> _getFieldsFor(String methodType) {
    switch (methodType) {
      case 'GPS':
        return ['latitude', 'longitude', 'radius_meters'];
      case 'GPS_QR':
        return ['latitude', 'longitude', 'radius_meters', 'qr_code'];
      case 'WIFI':
        return ['ssid', 'bssid'];
      case 'WIFI_QR':
        return ['ssid', 'bssid', 'qr_code'];
      case 'NFC':
        return ['tag_id'];
      case 'NFC_GPS':
        return ['tag_id', 'latitude', 'longitude', 'radius_meters'];
      case 'BEACON':
        return ['uuid', 'major', 'minor', 'rssi_threshold'];
      case 'BEACON_GPS':
        return ['uuid', 'major', 'minor', 'rssi_threshold', 'latitude', 'longitude', 'radius_meters'];
      default:
        return [];
    }
  }

  /// 숫자로 파싱해야 하는 필드 여부
  bool _isNumericField(String field) {
    return field == 'latitude' ||
        field == 'longitude' ||
        field == 'radius_meters' ||
        field == 'major' ||
        field == 'minor' ||
        field == 'rssi_threshold';
  }

  /// 필드명 한글 라벨
  String _fieldLabel(String field) {
    switch (field) {
      case 'latitude': return '위도';
      case 'longitude': return '경도';
      case 'radius_meters': return '반경(m)';
      case 'qr_code': return 'QR 코드';
      case 'ssid': return 'WiFi SSID';
      case 'bssid': return 'WiFi BSSID';
      case 'tag_id': return 'NFC 태그 ID';
      case 'uuid': return 'Beacon UUID';
      case 'major': return 'Major';
      case 'minor': return 'Minor';
      case 'rssi_threshold': return 'RSSI 임계값';
      default: return field;
    }
  }

  /// 컨트롤러 값을 config Map으로 변환 (숫자 필드는 파싱)
  Map<String, dynamic> _buildConfig(String methodType) {
    final ctrls = _controllers[methodType] ?? {};
    final result = <String, dynamic>{};
    ctrls.forEach((field, ctrl) {
      final text = ctrl.text.trim();
      if (text.isEmpty) return;
      if (_isNumericField(field)) {
        if (field == 'major' || field == 'minor' || field == 'rssi_threshold' || field == 'radius_meters') {
          final n = int.tryParse(text);
          if (n != null) result[field] = n;
        } else {
          final d = double.tryParse(text);
          if (d != null) result[field] = d;
        }
      } else {
        result[field] = text;
      }
    });
    return result;
  }

  /// 인증 방법 저장 (enabled + config)
  Future<void> _saveMethod(String methodType) async {
    setState(() => _saving = true);
    try {
      final config = _buildConfig(methodType);
      await widget.apiService.updateUserVerificationOverride(
        widget.employee.id,
        methodType: methodType,
        isEnabled: _enabledMap[methodType] ?? false,
        config: config,
      );
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_displayName(methodType)} 저장 완료')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했습니다')),
        );
      }
    }
  }

  /// 오버라이드 삭제 (기본값으로 복귀)
  Future<void> _resetMethod(String methodType) async {
    setState(() => _saving = true);
    try {
      await widget.apiService.deleteUserVerificationOverride(
        widget.employee.id, methodType,
      );
      // 새로고침
      final updated = await widget.apiService
          .getUserVerificationMethods(widget.employee.id);
      if (mounted) {
        setState(() {
          _methods = updated;
          _controllers.forEach((_, group) {
            for (final c in group.values) c.dispose();
          });
          _controllers.clear();
          _enabledMap.clear();
          _initControllers();
          _saving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_displayName(methodType)} 기본값으로 복귀')),
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
          Expanded(child: Text('${widget.employee.name} - 인증 설정')),
          if (widget.employee.workplaceName != null)
            Chip(
              label: Text(widget.employee.workplaceName!),
              backgroundColor: const Color(0xFF2DDAA9).withOpacity(0.1),
            ),
        ],
      ),
      content: SizedBox(
        width: 560,
        height: 520,
        child: _saving
            ? const Center(child: CircularProgressIndicator())
            : ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final enabled = _enabledMap[method.methodType] ?? false;
                  final fields = _getFieldsFor(method.methodType);
                  return ExpansionTile(
                    leading: Icon(
                      _getMethodIcon(method.methodType),
                      color: enabled ? const Color(0xFF2DDAA9) : Colors.grey,
                    ),
                    title: Text(_displayName(method.methodType)),
                    subtitle: Text(
                      (method.isOverridden ?? false) ? '개별 설정' : '기본값',
                      style: TextStyle(
                        fontSize: 12,
                        color: (method.isOverridden ?? false)
                            ? const Color(0xFF2DDAA9)
                            : Colors.grey[500],
                      ),
                    ),
                    trailing: Switch(
                      value: enabled,
                      onChanged: (v) => setState(() => _enabledMap[method.methodType] = v),
                      activeColor: const Color(0xFF2DDAA9),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      // config 편집 필드
                      ...fields.map((field) {
                        final ctrl = _controllers[method.methodType]?[field];
                        if (ctrl == null) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: TextField(
                            controller: ctrl,
                            keyboardType: _isNumericField(field)
                                ? const TextInputType.numberWithOptions(decimal: true, signed: true)
                                : TextInputType.text,
                            decoration: InputDecoration(
                              labelText: _fieldLabel(field),
                              border: const OutlineInputBorder(),
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10,
                              ),
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 8),
                      // 저장 / 기본값 복귀 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.restore, size: 18),
                            label: const Text('기본값 복귀'),
                            onPressed: () => _resetMethod(method.methodType),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('저장'),
                            onPressed: () => _saveMethod(method.methodType),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2DDAA9),
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
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
