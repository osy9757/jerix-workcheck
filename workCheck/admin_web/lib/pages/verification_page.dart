import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// MVP 시연용 인증 설정 페이지
/// - 대상 선택: 근무지 기본값 OR 특정 유저 오버라이드
/// - 방법별 ON/OFF + 설정값 인라인 편집
/// - QR 방법은 QR 모달 버튼 제공
class VerificationPage extends StatefulWidget {
  final ApiService apiService;
  const VerificationPage({super.key, required this.apiService});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  List<Workplace> _workplaces = [];
  List<Employee> _users = [];
  Workplace? _selectedWorkplace;
  Employee? _selectedUser; // null → 근무지 기본값 모드
  List<VerificationMethod> _methods = [];
  bool _loading = true;
  String? _error;

  // 펼쳐진 카드 인덱스 (인라인 편집용)
  int? _expandedIndex;

  /// 유저 모드 여부 (true: 유저 오버라이드, false: 근무지 기본값)
  bool get _isUserMode => _selectedUser != null;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// 근무지 + 유저 목록 동시 로드
  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        widget.apiService.getWorkplaces(),
        widget.apiService.getUsers(),
      ]);
      if (mounted) {
        setState(() {
          _workplaces = results[0] as List<Workplace>;
          _users = results[1] as List<Employee>;
          _loading = false;
          if (_workplaces.isNotEmpty && _selectedWorkplace == null) {
            _selectedWorkplace = _workplaces.first;
            _loadMethods();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '데이터를 불러올 수 없습니다'; _loading = false; });
    }
  }

  /// 현재 대상의 인증 방법 로드
  /// - 유저 모드: 해당 유저의 머지된 설정 (근무지 기본 + 오버라이드)
  /// - 근무지 모드: 근무지 기본값
  Future<void> _loadMethods() async {
    setState(() => _error = null);
    try {
      List<VerificationMethod> methods;
      if (_isUserMode) {
        methods = await widget.apiService
            .getUserVerificationMethods(_selectedUser!.id);
      } else {
        if (_selectedWorkplace == null) return;
        methods = await widget.apiService
            .getWorkplaceVerificationMethods(_selectedWorkplace!.id);
      }
      if (mounted) setState(() => _methods = methods);
    } catch (e) {
      if (mounted) setState(() => _error = '인증 방법을 불러올 수 없습니다');
    }
  }

  /// 유저 선택 변경
  void _onUserChanged(Employee? user) {
    setState(() {
      _selectedUser = user;
      _expandedIndex = null;
      // 유저 선택 시 해당 유저의 근무지로 자동 이동 (UI 표시용)
      if (user?.workplaceId != null) {
        final wp = _workplaces.firstWhere(
          (w) => w.id == user!.workplaceId,
          orElse: () => _selectedWorkplace!,
        );
        _selectedWorkplace = wp;
      }
    });
    _loadMethods();
  }

  /// ON/OFF 토글 (모드에 따라 다른 API 호출)
  Future<void> _toggleMethod(VerificationMethod method) async {
    try {
      if (_isUserMode) {
        await widget.apiService.updateUserVerificationOverride(
          _selectedUser!.id,
          methodType: method.methodType,
          isEnabled: !method.enabled,
          config: method.config,
        );
      } else {
        if (_selectedWorkplace == null) return;
        await widget.apiService.updateWorkplaceVerificationMethod(
          _selectedWorkplace!.id, method.id!,
          enabled: !method.enabled, config: method.config,
        );
      }
      _loadMethods();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 변경 실패')),
        );
      }
    }
  }

  /// 설정값 저장 (모드에 따라 다른 API 호출)
  Future<void> _saveConfig(VerificationMethod method, Map<String, dynamic> newConfig) async {
    try {
      if (_isUserMode) {
        await widget.apiService.updateUserVerificationOverride(
          _selectedUser!.id,
          methodType: method.methodType,
          isEnabled: method.enabled,
          config: newConfig,
        );
      } else {
        if (_selectedWorkplace == null) return;
        await widget.apiService.updateWorkplaceVerificationMethod(
          _selectedWorkplace!.id, method.id!,
          enabled: method.enabled, config: newConfig,
        );
      }
      _loadMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 완료'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장 실패')),
        );
      }
    }
  }

  /// 유저 오버라이드 제거 → 근무지 기본값으로 복귀
  Future<void> _resetUserOverride(VerificationMethod method) async {
    if (!_isUserMode) return;
    try {
      await widget.apiService.deleteUserVerificationOverride(
        _selectedUser!.id, method.methodType,
      );
      _loadMethods();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기본값으로 복귀'), duration: Duration(seconds: 1)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('복귀 실패')),
        );
      }
    }
  }

  /// QR 타입인지 확인
  bool _hasQr(String methodType) {
    return const {'GPS_QR', 'WIFI_QR'}.contains(methodType);
  }

  IconData _getIcon(String methodType) {
    switch (methodType) {
      case 'GPS': case 'GPS_QR': return Icons.location_on;
      case 'WIFI': case 'WIFI_QR': return Icons.wifi;
      case 'NFC': case 'NFC_GPS': return Icons.nfc;
      case 'BEACON': case 'BEACON_GPS': return Icons.bluetooth;
      default: return Icons.settings;
    }
  }

  Color _getColor(String methodType) {
    switch (methodType) {
      case 'GPS': case 'GPS_QR': return Colors.green;
      case 'WIFI': case 'WIFI_QR': return Colors.blue;
      case 'NFC': case 'NFC_GPS': return Colors.orange;
      case 'BEACON': case 'BEACON_GPS': return Colors.purple;
      default: return Colors.grey;
    }
  }

  /// 해당 방법의 편집 가능한 필드 목록 반환
  List<_ConfigField> _getConfigFields(String methodType) {
    switch (methodType) {
      case 'GPS':
      case 'GPS_QR':
        return [
          _ConfigField('latitude', '위도', '예: 37.5665', _FieldType.double_),
          _ConfigField('longitude', '경도', '예: 126.9780', _FieldType.double_),
          _ConfigField('radius_meters', '반경 (m)', '미터 단위', _FieldType.int_),
        ];
      case 'WIFI':
      case 'WIFI_QR':
        return [
          _ConfigField('ssid', 'WiFi SSID', '네트워크 이름', _FieldType.string),
          _ConfigField('bssid', 'WiFi BSSID', 'MAC 주소', _FieldType.string),
        ];
      case 'NFC':
        return [
          _ConfigField('tag_id', 'NFC 태그 ID', '태그 고유 ID', _FieldType.string),
        ];
      case 'NFC_GPS':
        return [
          _ConfigField('tag_id', 'NFC 태그 ID', '태그 고유 ID', _FieldType.string),
          _ConfigField('latitude', '위도', '예: 37.5665', _FieldType.double_),
          _ConfigField('longitude', '경도', '예: 126.9780', _FieldType.double_),
          _ConfigField('radius_meters', '반경 (m)', '미터 단위', _FieldType.int_),
        ];
      case 'BEACON':
        return [
          _ConfigField('uuid', 'Beacon UUID', 'UUID', _FieldType.string),
          _ConfigField('major', 'Major', '정수값', _FieldType.int_),
          _ConfigField('minor', 'Minor', '정수값', _FieldType.int_),
          _ConfigField('rssi_threshold', 'RSSI 임계값', '음수 (예: -70)', _FieldType.double_),
        ];
      case 'BEACON_GPS':
        return [
          _ConfigField('uuid', 'Beacon UUID', 'UUID', _FieldType.string),
          _ConfigField('major', 'Major', '정수값', _FieldType.int_),
          _ConfigField('minor', 'Minor', '정수값', _FieldType.int_),
          _ConfigField('rssi_threshold', 'RSSI 임계값', '음수 (예: -70)', _FieldType.double_),
          _ConfigField('latitude', '위도', '예: 37.5665', _FieldType.double_),
          _ConfigField('longitude', '경도', '예: 126.9780', _FieldType.double_),
          _ConfigField('radius_meters', '반경 (m)', '미터 단위', _FieldType.int_),
        ];
      default:
        return [];
    }
  }

  /// QR 코드 모달
  void _showQrModal(Workplace workplace) {
    String randomQr = _generateRandomQr();
    String? realQr;
    bool loading = true;
    String? error;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          if (loading && realQr == null && error == null) {
            widget.apiService.getWorkplaceQrCode(workplace.id).then((qr) {
              setDialogState(() { realQr = qr; loading = false; });
            }).catchError((e) {
              setDialogState(() { error = 'QR 로드 실패'; loading = false; });
            });
          }

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.qr_code, color: Color(0xFF2DDAA9)),
                const SizedBox(width: 8),
                Text('${workplace.name} - QR 코드'),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: loading
                  ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
                  : error != null
                      ? SizedBox(height: 200, child: Center(child: Text(error!, style: const TextStyle(color: Colors.red))))
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildQrCard(
                              label: '인증용 QR', subtitle: '스캔 → 인증 성공',
                              data: realQr!, color: const Color(0xFF2DDAA9),
                            )),
                            const SizedBox(width: 24),
                            Expanded(child: _buildQrCard(
                              label: '테스트 (랜덤)', subtitle: '스캔 → 인증 실패',
                              data: randomQr, color: Colors.grey,
                            )),
                          ],
                        ),
            ),
            actions: [
              TextButton.icon(
                icon: const Icon(Icons.shuffle, size: 18),
                label: const Text('랜덤 QR 변경'),
                onPressed: () => setDialogState(() => randomQr = _generateRandomQr()),
              ),
              TextButton.icon(
                icon: const Icon(Icons.refresh, size: 18, color: Colors.orange),
                label: const Text('인증 QR 재생성', style: TextStyle(color: Colors.orange)),
                onPressed: () async {
                  setDialogState(() { loading = true; error = null; });
                  try {
                    final newQr = await widget.apiService.regenerateWorkplaceQrCode(workplace.id);
                    setDialogState(() { realQr = newQr; loading = false; });
                  } catch (e) {
                    setDialogState(() { error = 'QR 재생성 실패'; loading = false; });
                  }
                },
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DDAA9),
                  foregroundColor: Colors.white,
                ),
                child: const Text('닫기'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildQrCard({
    required String label, required String subtitle,
    required String data, required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color, fontSize: 14)),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: QrImageView(
            data: data, version: QrVersions.auto, size: 180,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square, color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SelectableText(
          data.length > 20 ? '${data.substring(0, 20)}...' : data,
          style: TextStyle(fontSize: 10, color: Colors.grey[400]),
        ),
      ],
    );
  }

  String _generateRandomQr() {
    final r = Random();
    const c = 'abcdef0123456789';
    String s(int len) => List.generate(len, (_) => c[r.nextInt(c.length)]).join();
    return '${s(8)}-${s(4)}-${s(4)}-${s(4)}-${s(12)}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text('인증 설정',
                style: Theme.of(context).textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              if (_selectedWorkplace != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code, size: 20),
                  label: const Text('QR 보기'),
                  onPressed: () => _showQrModal(_selectedWorkplace!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DDAA9),
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: () { _loadInitialData(); _loadMethods(); },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _isUserMode
                ? '유저 "${_selectedUser!.name}"의 인증 방법을 수정합니다 (오버라이드)'
                : '근무지 기본 인증 설정을 수정합니다 (모든 유저에 적용)',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // 대상 선택 영역
          _buildTargetSelector(),
          const SizedBox(height: 20),

          // 에러 표시
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          // 인증 방법 리스트
          if (_selectedWorkplace != null)
            Expanded(
              child: ListView.builder(
                itemCount: _methods.length,
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  final isExpanded = _expandedIndex == index;
                  return _buildMethodCard(method, index, isExpanded);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 대상(근무지/유저) 선택 UI
  Widget _buildTargetSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _isUserMode
            ? Colors.orange.withOpacity(0.05)
            : const Color(0xFF2DDAA9).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isUserMode
              ? Colors.orange.withOpacity(0.3)
              : const Color(0xFF2DDAA9).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // 근무지 드롭다운
          _buildDropdown(
            icon: Icons.business,
            label: '근무지',
            child: DropdownButton<int>(
              value: _selectedWorkplace?.id,
              hint: const Text('근무지'),
              isDense: true,
              underline: const SizedBox(),
              items: _workplaces.map((wp) {
                return DropdownMenuItem(
                  value: wp.id,
                  child: Text(wp.name),
                );
              }).toList(),
              onChanged: _isUserMode ? null : (id) {
                if (id == null) return;
                setState(() {
                  _selectedWorkplace = _workplaces.firstWhere((w) => w.id == id);
                  _expandedIndex = null;
                });
                _loadMethods();
              },
            ),
          ),
          const SizedBox(width: 12),
          const Text('→', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const SizedBox(width: 12),

          // 유저 드롭다운
          _buildDropdown(
            icon: Icons.person,
            label: '대상 유저',
            child: DropdownButton<Employee?>(
              value: _selectedUser,
              hint: const Text('근무지 기본값'),
              isDense: true,
              underline: const SizedBox(),
              items: [
                const DropdownMenuItem<Employee?>(
                  value: null,
                  child: Text('🏢 근무지 기본값',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                ..._users.map((u) {
                  return DropdownMenuItem<Employee?>(
                    value: u,
                    child: Text('👤 ${u.name} (${u.employeeId})'),
                  );
                }),
              ],
              onChanged: _onUserChanged,
            ),
          ),

          const Spacer(),

          // 모드 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isUserMode ? Colors.orange : const Color(0xFF2DDAA9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _isUserMode ? '유저 오버라이드 모드' : '근무지 기본 모드',
              style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 드롭다운 래퍼 (아이콘 + 라벨 + 값)
  Widget _buildDropdown({
    required IconData icon,
    required String label,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Text('$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          DropdownButtonHideUnderline(child: child),
        ],
      ),
    );
  }

  /// 인증 방법 카드
  Widget _buildMethodCard(VerificationMethod method, int index, bool isExpanded) {
    final color = _getColor(method.methodType);
    final fields = _getConfigFields(method.methodType);
    final isOverridden = method.isOverridden == true;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isExpanded ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: method.enabled ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.2),
          width: method.enabled ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expandedIndex = isExpanded ? null : index),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (method.enabled ? color : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getIcon(method.methodType),
                      color: method.enabled ? color : Colors.grey, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(method.displayName,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            // 유저 모드에서 오버라이드 적용된 경우 배지
                            if (_isUserMode && isOverridden)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  '오버라이드',
                                  style: TextStyle(
                                    fontSize: 10, color: Colors.orange, fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          method.enabled ? '활성' : '비활성',
                          style: TextStyle(
                            fontSize: 12,
                            color: method.enabled ? color : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey),
                  const SizedBox(width: 8),
                  Switch(
                    value: method.enabled,
                    onChanged: (_) => _toggleMethod(method),
                    activeColor: color,
                  ),
                ],
              ),
            ),
          ),

          // 펼침: 인라인 설정 편집
          if (isExpanded)
            _MethodConfigEditor(
              key: ValueKey('${method.methodType}-${_selectedUser?.id ?? 0}'),
              apiService: widget.apiService,
              method: method,
              fields: fields,
              hasQr: _hasQr(method.methodType),
              color: color,
              isUserMode: _isUserMode,
              isOverridden: isOverridden,
              onSave: (newConfig) => _saveConfig(method, newConfig),
              onReset: _isUserMode && isOverridden
                  ? () => _resetUserOverride(method)
                  : null,
              onShowQr: _selectedWorkplace != null
                  ? () => _showQrModal(_selectedWorkplace!)
                  : null,
            ),
        ],
      ),
    );
  }
}

enum _FieldType { int_, double_, string }

class _ConfigField {
  final String key;
  final String label;
  final String hint;
  final _FieldType type;
  _ConfigField(this.key, this.label, this.hint, this.type);
}

/// 인라인 설정값 편집 위젯
class _MethodConfigEditor extends StatefulWidget {
  final ApiService apiService; // 프리셋 API 호출용
  final VerificationMethod method;
  final List<_ConfigField> fields;
  final bool hasQr;
  final Color color;
  final bool isUserMode;
  final bool isOverridden;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onReset;
  final VoidCallback? onShowQr;

  const _MethodConfigEditor({
    super.key,
    required this.apiService,
    required this.method,
    required this.fields,
    required this.hasQr,
    required this.color,
    required this.isUserMode,
    required this.isOverridden,
    required this.onSave,
    this.onReset,
    this.onShowQr,
  });

  @override
  State<_MethodConfigEditor> createState() => _MethodConfigEditorState();
}

class _MethodConfigEditorState extends State<_MethodConfigEditor> {
  late Map<String, TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    for (final field in widget.fields) {
      final value = widget.method.config[field.key];
      _controllers[field.key] = TextEditingController(
        text: value?.toString() ?? '',
      );
    }
  }

  @override
  void didUpdateWidget(covariant _MethodConfigEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.method.config != widget.method.config) {
      for (final field in widget.fields) {
        final value = widget.method.config[field.key];
        _controllers[field.key]?.text = value?.toString() ?? '';
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    final newConfig = Map<String, dynamic>.from(widget.method.config);
    for (final field in widget.fields) {
      final text = _controllers[field.key]?.text ?? '';
      switch (field.type) {
        case _FieldType.int_:
          newConfig[field.key] = int.tryParse(text) ?? text;
          break;
        case _FieldType.double_:
          newConfig[field.key] = double.tryParse(text) ?? text;
          break;
        case _FieldType.string:
          newConfig[field.key] = text;
          break;
      }
    }
    widget.onSave(newConfig);
  }

  /// 프리셋 불러오기 다이얼로그
  /// 같은 method_type의 프리셋 목록을 보여주고, 선택 시 입력 필드를 자동으로 채움
  Future<void> _showLoadPresetDialog() async {
    List<VerificationPreset> presets = [];
    try {
      presets = await widget.apiService.getPresets(
        methodType: widget.method.methodType,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프리셋을 불러올 수 없습니다')),
        );
      }
      return;
    }

    if (!mounted) return;

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.method.displayName} 프리셋이 없습니다'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final selected = await showDialog<VerificationPreset>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${widget.method.displayName} 프리셋 선택'),
        content: SizedBox(
          width: 480,
          height: 360,
          child: ListView.separated(
            itemCount: presets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = presets[index];
              return ListTile(
                title: Text(p.name),
                subtitle: Text(
                  p.memo ?? p.configData.entries
                      .map((e) => '${e.key}: ${e.value}')
                      .join(' / '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pop(ctx, p),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
        ],
      ),
    );

    if (selected == null || !mounted) return;

    // 선택된 프리셋 값으로 컨트롤러 채우기
    setState(() {
      for (final field in widget.fields) {
        final value = selected.configData[field.key];
        if (value != null) {
          _controllers[field.key]?.text = value.toString();
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${selected.name}" 프리셋을 불러왔습니다 (저장 버튼을 눌러 적용)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 현재 입력값을 프리셋으로 저장
  Future<void> _showSaveAsPresetDialog() async {
    final nameCtrl = TextEditingController();
    final memoCtrl = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${widget.method.displayName} 프리셋으로 저장'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  hintText: '예: 사무실 정문 NFC',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: memoCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: '메모',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이름을 입력하세요')),
        );
      }
      return;
    }

    // 현재 입력값을 config로 변환 (프리셋용 - 위치 좌표는 제외)
    final config = <String, dynamic>{};
    for (final field in widget.fields) {
      // GPS 좌표는 근무지 종속이므로 프리셋에 저장하지 않음
      if (field.key == 'latitude' || field.key == 'longitude') continue;
      final text = _controllers[field.key]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      switch (field.type) {
        case _FieldType.int_:
          config[field.key] = int.tryParse(text) ?? text;
          break;
        case _FieldType.double_:
          config[field.key] = double.tryParse(text) ?? text;
          break;
        case _FieldType.string:
          config[field.key] = text;
          break;
      }
    }

    try {
      await widget.apiService.createPreset(
        name: name,
        methodType: widget.method.methodType,
        configData: config,
        memo: memoCtrl.text.trim().isEmpty ? null : memoCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"$name" 프리셋이 저장되었습니다'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('프리셋 저장에 실패했습니다')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 8),

          // 유저 모드에서 비오버라이드 안내
          if (widget.isUserMode && !widget.isOverridden)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '근무지 기본값이 적용 중입니다. 저장하면 이 유저만의 오버라이드가 생성됩니다.',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),

          // 필드들
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: widget.fields.map((field) {
              return SizedBox(
                width: 240,
                child: TextField(
                  controller: _controllers[field.key],
                  decoration: InputDecoration(
                    labelText: field.label,
                    helperText: field.hint,
                    border: const OutlineInputBorder(),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 버튼 행 (좌측: QR/프리셋 / 우측: 복귀/저장)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (widget.hasQr && widget.onShowQr != null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.qr_code, size: 18),
                  label: const Text('QR 보기'),
                  onPressed: widget.onShowQr,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: widget.color,
                    side: BorderSide(color: widget.color),
                  ),
                ),
              // 프리셋 불러오기
              OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_outline, size: 18),
                label: const Text('프리셋 불러오기'),
                onPressed: _showLoadPresetDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.color,
                  side: BorderSide(color: widget.color.withOpacity(0.6)),
                ),
              ),
              // 현재 값을 프리셋으로 저장
              OutlinedButton.icon(
                icon: const Icon(Icons.bookmark_add_outlined, size: 18),
                label: const Text('프리셋으로 저장'),
                onPressed: _showSaveAsPresetDialog,
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.color,
                  side: BorderSide(color: widget.color.withOpacity(0.6)),
                ),
              ),
              // 기본값으로 복귀 (유저 모드에서 오버라이드 있을 때만)
              if (widget.onReset != null)
                TextButton.icon(
                  icon: const Icon(Icons.restore, size: 18),
                  label: const Text('기본값 복귀'),
                  onPressed: widget.onReset,
                  style: TextButton.styleFrom(foregroundColor: Colors.orange),
                ),
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('저장'),
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
