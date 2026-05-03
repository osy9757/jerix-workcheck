import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../utils/verification_targets.dart';

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

          // 펼침: 인라인 설정 편집 (동적 row UI)
          if (isExpanded)
            _MethodConfigEditor(
              key: ValueKey('${method.methodType}-${_selectedUser?.id ?? 0}'),
              apiService: widget.apiService,
              method: method,
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

// 부품/필드/타겟 추출 헬퍼는 lib/utils/verification_targets.dart 에 공유 정의됨.
// (PartGroup, ConfigField, partGroupsFor, hasQrCodesSection, partDisplayNameOf,
//  rowFieldsForPart, extractTargets, extractQrCodes)

/// 인라인 설정값 편집 위젯 (동적 row UI - 신 schema)
/// - 메서드별 부품 그룹마다 row 카드 N개 + "+ 추가" 버튼
/// - GPS_QR/WIFI_QR은 별도 QR 코드 섹션
/// - 최소 1 row 유지 (마지막 row 삭제 시 비움)
class _MethodConfigEditor extends StatefulWidget {
  final ApiService apiService; // 프리셋 API 호출용
  final VerificationMethod method;
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
  late final List<PartGroup> _partGroups;
  late final bool _hasQrSection;

  /// configKey → 부품 row 컨트롤러 리스트 (각 row는 field key → TextEditingController)
  final Map<String, List<Map<String, TextEditingController>>> _rowsByKey = {};

  /// QR 코드 컨트롤러 리스트 (qr_codes 섹션)
  final List<TextEditingController> _qrCodeCtrls = [];

  @override
  void initState() {
    super.initState();
    _partGroups = partGroupsFor(widget.method.methodType);
    _hasQrSection = hasQrCodesSection(widget.method.methodType);
    _initFromConfig();
  }

  /// widget.method.config로부터 부품별 row와 QR 코드를 초기화
  /// 신 schema(`*_targets`/`qr_codes`) 우선, 단일 dict는 1개 row로 폴백
  void _initFromConfig() {
    final config = widget.method.config;
    for (final group in _partGroups) {
      final fields = rowFieldsForPart(group.partType);
      var targets = extractTargets(config, group.configKey, fields);
      // 빈 상태 방지: 최소 1 row 유지
      if (targets.isEmpty) targets = [<String, dynamic>{}];
      _rowsByKey[group.configKey] =
          targets.map((t) => _makeRowControllers(fields, t)).toList();
    }
    if (_hasQrSection) {
      var codes = extractQrCodes(config);
      if (codes.isEmpty) codes = [''];
      for (final c in codes) {
        _qrCodeCtrls.add(TextEditingController(text: c));
      }
    }
  }

  /// row의 컨트롤러 맵 생성
  Map<String, TextEditingController> _makeRowControllers(
    List<ConfigField> fields,
    Map<String, dynamic> data,
  ) {
    final m = <String, TextEditingController>{};
    for (final f in fields) {
      final v = data[f.key];
      m[f.key] = TextEditingController(text: v?.toString() ?? '');
    }
    return m;
  }

  @override
  void dispose() {
    for (final list in _rowsByKey.values) {
      for (final row in list) {
        for (final c in row.values) {
          c.dispose();
        }
      }
    }
    for (final c in _qrCodeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  /// 부품 그룹에 빈 row 추가
  void _addRow(PartGroup group) {
    setState(() {
      final fields = rowFieldsForPart(group.partType);
      _rowsByKey[group.configKey]!
          .add(_makeRowControllers(fields, const <String, dynamic>{}));
    });
  }

  /// 부품 그룹의 row 삭제 (최소 1개 유지: 마지막 row면 비움 처리)
  void _removeRow(PartGroup group, int index) {
    setState(() {
      final list = _rowsByKey[group.configKey]!;
      if (list.length <= 1) {
        for (final c in list[0].values) {
          c.clear();
        }
        return;
      }
      for (final c in list[index].values) {
        c.dispose();
      }
      list.removeAt(index);
    });
  }

  /// QR 코드 추가
  void _addQr() {
    setState(() => _qrCodeCtrls.add(TextEditingController(text: '')));
  }

  /// QR 코드 삭제 (최소 1개 유지)
  void _removeQr(int index) {
    setState(() {
      if (_qrCodeCtrls.length <= 1) {
        _qrCodeCtrls[0].clear();
        return;
      }
      _qrCodeCtrls[index].dispose();
      _qrCodeCtrls.removeAt(index);
    });
  }

  /// row의 컨트롤러 텍스트를 타입에 맞춰 dict로 변환
  Map<String, dynamic> _rowToMap(
    Map<String, TextEditingController> row,
    List<ConfigField> fields,
  ) {
    final m = <String, dynamic>{};
    for (final f in fields) {
      final text = row[f.key]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      switch (f.type) {
        case ConfigFieldType.int_:
          m[f.key] = int.tryParse(text) ?? text;
          break;
        case ConfigFieldType.double_:
          m[f.key] = double.tryParse(text) ?? text;
          break;
        case ConfigFieldType.string:
          m[f.key] = text;
          break;
      }
    }
    return m;
  }

  /// 신 schema로 직렬화 후 onSave 호출 (빈 row는 제외)
  void _save() {
    final newConfig = <String, dynamic>{};
    for (final group in _partGroups) {
      final fields = rowFieldsForPart(group.partType);
      final list = _rowsByKey[group.configKey]!;
      final arr = <Map<String, dynamic>>[];
      for (final row in list) {
        final m = _rowToMap(row, fields);
        if (m.isNotEmpty) arr.add(m);
      }
      newConfig[group.configKey] = arr;
    }
    if (_hasQrSection) {
      final codes = _qrCodeCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      newConfig['qr_codes'] = codes;
    }
    widget.onSave(newConfig);
  }

  /// 프리셋 불러오기 다이얼로그 — 부품 그룹 단위
  /// 1) partType 프리셋 목록에서 1개 선택
  /// 2) 적용 방식 선택: "현재 row 채우기"(덮어쓰기) 또는 "새 row 추가"(append)
  Future<void> _showLoadPresetDialog(PartGroup group) async {
    final partLabel = partDisplayNameOf(group.partType);
    final fields = rowFieldsForPart(group.partType);

    List<VerificationPreset> presets = [];
    try {
      presets = await widget.apiService.getPresets(methodType: group.partType);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$partLabel 프리셋을 불러올 수 없습니다')),
        );
      }
      return;
    }
    if (!mounted) return;

    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$partLabel 프리셋이 없습니다'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 1) 프리셋 선택
    final selected = await showDialog<VerificationPreset>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('$partLabel 프리셋 선택'),
        content: SizedBox(
          width: 480,
          height: 360,
          child: ListView.separated(
            itemCount: presets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final p = presets[index];
              // 신 schema의 targets 배열 개수 표시
              final tList = extractTargets(p.configData, 'targets', fields);
              final summary = p.memo ??
                  (tList.isEmpty
                      ? '(빈 프리셋)'
                      : '${tList.length}개 대상 · ${tList.first.entries.map((e) => '${e.key}: ${e.value}').join(' / ')}');
              return ListTile(
                title: Text(p.name),
                subtitle: Text(
                  summary,
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

    // 프리셋의 타겟 추출 (신 schema 우선, 단일 dict 폴백)
    final presetTargets =
        extractTargets(selected.configData, 'targets', fields);
    if (presetTargets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${selected.name}" 프리셋에 적용 가능한 값이 없습니다'),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // 2) 적용 방식 선택
    final mode = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('"${selected.name}" 적용 방식'),
        content: Text(
            '이 프리셋에 ${presetTargets.length}개 대상이 있습니다.\n어떻게 적용할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          TextButton.icon(
            icon: const Icon(Icons.swap_horiz, size: 18),
            label: const Text('현재 row 채우기 (덮어쓰기)'),
            onPressed: () => Navigator.pop(ctx, 'replace'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('새 row 추가'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, 'append'),
          ),
        ],
      ),
    );
    if (mode == null || !mounted) return;

    // 적용
    setState(() {
      final list = _rowsByKey[group.configKey]!;
      if (mode == 'replace') {
        // 기존 row 모두 폐기 후 프리셋 row로 대체
        for (final row in list) {
          for (final c in row.values) {
            c.dispose();
          }
        }
        list.clear();
        for (final t in presetTargets) {
          list.add(_makeRowControllers(fields, t));
        }
        if (list.isEmpty) {
          list.add(_makeRowControllers(fields, const <String, dynamic>{}));
        }
      } else {
        // append: 기존 row 뒤에 프리셋 row 추가
        for (final t in presetTargets) {
          list.add(_makeRowControllers(fields, t));
        }
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '"${selected.name}" $partLabel 프리셋을 ${mode == 'replace' ? '덮어쓰기' : '추가'}했습니다 (저장 버튼을 눌러 적용)'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// 현재 입력값을 프리셋으로 저장 (신 schema 직렬화)
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

    // 현재 row들의 신 schema 직렬화 (빈 row 제외)
    final config = <String, dynamic>{};
    for (final group in _partGroups) {
      final fields = rowFieldsForPart(group.partType);
      final list = _rowsByKey[group.configKey]!;
      final arr = <Map<String, dynamic>>[];
      for (final row in list) {
        final m = _rowToMap(row, fields);
        if (m.isNotEmpty) arr.add(m);
      }
      if (arr.isNotEmpty) config[group.configKey] = arr;
    }
    if (_hasQrSection) {
      final codes = _qrCodeCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (codes.isNotEmpty) config['qr_codes'] = codes;
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

  /// 부품 그룹별 "프리셋 불러오기" 버튼 위젯 리스트
  List<Widget> _buildPresetLoadButtons() {
    if (_partGroups.length <= 1) {
      // 단일 부품: "프리셋 불러오기" 단일 버튼
      final group = _partGroups.first;
      return [
        OutlinedButton.icon(
          icon: const Icon(Icons.bookmark_outline, size: 18),
          label: const Text('프리셋 불러오기'),
          onPressed: () => _showLoadPresetDialog(group),
          style: OutlinedButton.styleFrom(
            foregroundColor: widget.color,
            side: BorderSide(color: widget.color.withOpacity(0.6)),
          ),
        ),
      ];
    }
    // 복합 메서드: 부품별 버튼 N개
    return _partGroups.map((group) {
      final label = '${partDisplayNameOf(group.partType)} 프리셋';
      return OutlinedButton.icon(
        icon: const Icon(Icons.bookmark_outline, size: 18),
        label: Text(label),
        onPressed: () => _showLoadPresetDialog(group),
        style: OutlinedButton.styleFrom(
          foregroundColor: widget.color,
          side: BorderSide(color: widget.color.withOpacity(0.6)),
        ),
      );
    }).toList();
  }

  /// 부품 그룹 섹션 빌드 (헤더 + row 카드들 + 추가 버튼)
  Widget _buildPartSection(PartGroup group) {
    final fields = rowFieldsForPart(group.partType);
    final rows = _rowsByKey[group.configKey]!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                group.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rows.length}개',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        // row 카드들
        ...List.generate(rows.length, (i) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // row 헤더 (인덱스 + 삭제)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: rows.length == 1 ? '값 비우기' : '이 row 삭제',
                        color: Colors.red,
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _removeRow(group, i),
                      ),
                    ],
                  ),
                  // row 필드
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: fields.map((field) {
                      return SizedBox(
                        width: 220,
                        child: TextField(
                          controller: rows[i][field.key],
                          decoration: InputDecoration(
                            labelText: field.label,
                            helperText: field.hint,
                            border: const OutlineInputBorder(),
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }),
        // "+ 추가" 버튼 (카드 아래)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text('${group.label} 추가'),
            onPressed: () => _addRow(group),
            style: TextButton.styleFrom(foregroundColor: widget.color),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// QR 코드 섹션 빌드 (GPS_QR/WIFI_QR 전용)
  Widget _buildQrCodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                'QR 코드',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: widget.color,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_qrCodeCtrls.length}개',
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...List.generate(_qrCodeCtrls.length, (i) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _qrCodeCtrls[i],
                      decoration: const InputDecoration(
                        labelText: 'QR 페이로드',
                        helperText: '예: WC-GN-QR-001',
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    tooltip: _qrCodeCtrls.length == 1 ? '값 비우기' : 'QR 삭제',
                    color: Colors.red,
                    visualDensity: VisualDensity.compact,
                    onPressed: () => _removeQr(i),
                  ),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('QR 코드 추가'),
            onPressed: _addQr,
            style: TextButton.styleFrom(foregroundColor: widget.color),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
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

          // 부품 그룹별 동적 row 섹션
          ..._partGroups.map(_buildPartSection),

          // QR 코드 섹션 (GPS_QR/WIFI_QR)
          if (_hasQrSection) _buildQrCodesSection(),

          const SizedBox(height: 8),

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
              // 프리셋 불러오기 (복합 메서드는 부품별 버튼으로 분리)
              ..._buildPresetLoadButtons(),
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
