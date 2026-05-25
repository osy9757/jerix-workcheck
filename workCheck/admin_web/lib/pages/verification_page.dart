import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../utils/verification_targets.dart';
import '../widgets/gps_picker_dialog.dart';

/// 인증 설정 페이지 (api_contract v2)
///
/// - 유저 단일 선택 (workplace 개념 폐기)
/// - 5개 primitive 토글 카드 (GPS / WiFi / NFC / Beacon / QR)
/// - 활성 토글 ≥ 2일 때 "AND" 안내 + 카드 사이 AND 라벨
/// - WiFi: 식별자 타입 라디오 (bssid / ip) + 단일 identifier_value
/// - Beacon: 거리(m) + TxPower(dBm). rssi_threshold는 서버 자동 계산 (UI 표시 X)
/// - QR: codes[] 멀티 입력 (프리셋 카탈로그 끼워넣기 지원)
class VerificationPage extends StatefulWidget {
  final ApiService apiService;
  const VerificationPage({super.key, required this.apiService});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  List<Employee> _users = [];
  Employee? _selectedUser;
  List<VerificationMethod> _methods = []; // 5개 method row
  bool _loading = true;
  String? _error;

  /// 펼쳐진 primitive 카드 (인라인 편집)
  String? _expandedPrimitive;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  /// 유저 목록 로드 (첫 유저 자동 선택)
  Future<void> _loadInitialData() async {
    setState(() => _loading = true);
    try {
      final users = await widget.apiService.getUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
        _loading = false;
        if (_users.isNotEmpty && _selectedUser == null) {
          _selectedUser = _users.first;
          _loadMethods();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '직원 목록을 불러올 수 없습니다';
          _loading = false;
        });
      }
    }
  }

  /// 선택된 유저의 5개 method 로드
  Future<void> _loadMethods() async {
    if (_selectedUser == null) return;
    setState(() => _error = null);
    try {
      final methods = await widget.apiService.getUserMethods(_selectedUser!.id);
      if (mounted) setState(() => _methods = methods);
    } catch (e) {
      if (mounted) setState(() => _error = '인증 방법을 불러올 수 없습니다');
    }
  }

  void _onUserChanged(Employee? user) {
    if (user == null || user.id == _selectedUser?.id) return;
    setState(() {
      _selectedUser = user;
      _expandedPrimitive = null;
      _methods = [];
    });
    _loadMethods();
  }

  // -----------------------------------------------------------------
  // 백엔드 row 조회 헬퍼
  // -----------------------------------------------------------------

  VerificationMethod? _methodByType(String type) {
    for (final m in _methods) {
      if (m.methodType.toUpperCase() == type.toUpperCase()) return m;
    }
    return null;
  }

  /// 활성된 primitive 집합 (UI AND 시각화용)
  Set<String> _activePrimitives() {
    final out = <String>{};
    for (final m in _methods) {
      if (m.enabled) out.add(m.methodType.toUpperCase());
    }
    return out;
  }

  // -----------------------------------------------------------------
  // 저장 (per-card)
  // -----------------------------------------------------------------

  /// primitive 토글 ON/OFF — config는 유지
  Future<void> _togglePrimitive(String primitive, bool nextEnabled) async {
    final m = _methodByType(primitive);
    if (m == null) return;
    try {
      await widget.apiService.updateUserMethod(
        _selectedUser!.id,
        methodType: primitive,
        isEnabled: nextEnabled,
        configData: m.config,
      );
      await _loadMethods();
    } catch (e) {
      _showSnack('$primitive 토글 변경 실패');
    }
  }

  /// primitive config + enabled 저장
  Future<void> _savePrimitive({
    required String primitive,
    required bool enabled,
    required Map<String, dynamic> config,
  }) async {
    try {
      await widget.apiService.updateUserMethod(
        _selectedUser!.id,
        methodType: primitive,
        isEnabled: enabled,
        configData: config,
      );
      await _loadMethods();
      _showSnack('$primitive 저장 완료');
    } catch (e) {
      _showSnack('$primitive 저장 실패');
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  // -----------------------------------------------------------------
  // primitive 메타
  // -----------------------------------------------------------------
  static IconData _primitiveIcon(String p) {
    switch (p) {
      case 'GPS':
        return Icons.location_on;
      case 'WIFI':
        return Icons.wifi;
      case 'NFC':
        return Icons.nfc;
      case 'BEACON':
        return Icons.bluetooth;
      case 'QR':
        return Icons.qr_code;
      default:
        return Icons.settings;
    }
  }

  static Color _primitiveColor(String p) {
    switch (p) {
      case 'GPS':
        return Colors.green;
      case 'WIFI':
        return Colors.blue;
      case 'NFC':
        return Colors.orange;
      case 'BEACON':
        return Colors.purple;
      case 'QR':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  // -----------------------------------------------------------------
  // QR 모달 (선택된 유저의 QR codes 시각화)
  // -----------------------------------------------------------------
  void _showQrModal() {
    final qrMethod = _methodByType('QR');
    final codes = qrMethod == null
        ? <String>[]
        : extractQrCodes(qrMethod.config)
            .where((c) => c.trim().isNotEmpty)
            .toList();
    String randomQr = _generateRandomQr();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.qr_code, color: Color(0xFF2DDAA9)),
              const SizedBox(width: 8),
              Text('${_selectedUser?.name ?? "유저"} - QR 코드'),
            ],
          ),
          content: SizedBox(
            width: 720,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (codes.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: const Text(
                        '등록된 QR 코드가 없습니다.\n'
                        'QR 카드를 열어 codes 를 추가하세요.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    )
                  else ...[
                    const Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 8),
                      child: Text(
                        '인증용 QR',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2DDAA9),
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (int i = 0; i < codes.length; i++)
                          _buildQrCard(
                            label: 'QR #${i + 1}',
                            subtitle: '스캔 → 인증 성공',
                            data: codes[i],
                            color: const Color(0xFF2DDAA9),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(height: 24),
                  ],
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      '비교용 (랜덤)',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, color: Colors.grey),
                    ),
                  ),
                  _buildQrCard(
                    label: '테스트 (랜덤)',
                    subtitle: '스캔 → 인증 실패',
                    data: randomQr,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('랜덤 QR 변경'),
              onPressed: () =>
                  setDialogState(() => randomQr = _generateRandomQr()),
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
        ),
      ),
    );
  }

  Widget _buildQrCard({
    required String label,
    required String subtitle,
    required String data,
    required Color color,
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
          child: Text(label,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 14)),
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
            data: data,
            version: QrVersions.auto,
            size: 180,
            eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: color),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: Colors.black87,
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
    String s(int len) =>
        List.generate(len, (_) => c[r.nextInt(c.length)]).join();
    return '${s(8)}-${s(4)}-${s(4)}-${s(4)}-${s(12)}';
  }

  // =================================================================
  // 빌드
  // =================================================================
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
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (_selectedUser != null)
                ElevatedButton.icon(
                  icon: const Icon(Icons.qr_code, size: 20),
                  label: const Text('QR 보기'),
                  onPressed: _showQrModal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2DDAA9),
                    foregroundColor: Colors.white,
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: () {
                  _loadInitialData();
                  _loadMethods();
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _selectedUser == null
                ? '직원을 선택해 인증 방법을 설정하세요'
                : '"${_selectedUser!.name}"의 5개 인증 방법을 직접 ON/OFF 및 편집합니다',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          _buildUserSelector(),
          const SizedBox(height: 16),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),

          // AND 결합 안내 카드 + 5개 primitive 토글
          if (_selectedUser != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAndCombinationCard(),
                    const SizedBox(height: 16),
                    _buildPrimitiveListWithAndDividers(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 유저 단일 선택 드롭다운
  Widget _buildUserSelector() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2DDAA9).withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2DDAA9).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.person, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text('대상 유저: ',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _selectedUser?.id,
                    hint: const Text('유저 선택'),
                    isDense: true,
                    items: _users
                        .map((u) => DropdownMenuItem<int>(
                              value: u.id,
                              child: Text(
                                  '👤 ${u.name} (${u.employeeId})'
                                  '${u.department != null ? " · ${u.department}" : ""}'),
                            ))
                        .toList(),
                    onChanged: (id) {
                      if (id == null) return;
                      final u = _users.firstWhere((x) => x.id == id);
                      _onUserChanged(u);
                    },
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF2DDAA9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              '유저 단위 5-Primitive',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------
  // AND 결합 안내 카드
  // -----------------------------------------------------------------
  Widget _buildAndCombinationCard() {
    final active = _activePrimitives();

    Color outline;
    Color bg;
    String message;
    if (active.isEmpty) {
      outline = Colors.grey.withOpacity(0.3);
      bg = Colors.grey.withOpacity(0.03);
      message = '활성된 인증 방식이 없습니다. 아래에서 GPS/WiFi/NFC/Beacon/QR 토글을 켜세요.';
    } else if (active.length == 1) {
      outline = const Color(0xFF2DDAA9).withOpacity(0.5);
      bg = const Color(0xFF2DDAA9).withOpacity(0.05);
      message = '단일 인증입니다. 이 방식 1개만 통과하면 출퇴근이 인정됩니다.';
    } else {
      outline = const Color(0xFF2DDAA9).withOpacity(0.6);
      bg = const Color(0xFF2DDAA9).withOpacity(0.08);
      message = '선택된 방식 ${active.length}개 모두 통과해야 인증 (AND 결합)';
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: outline, width: 1.5),
      ),
      color: bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  active.isEmpty
                      ? Icons.info_outline
                      : (active.length >= 2
                          ? Icons.shield
                          : Icons.shield_outlined),
                  size: 20,
                  color: active.isEmpty
                      ? Colors.grey[600]
                      : const Color(0xFF2DDAA9),
                ),
                const SizedBox(width: 8),
                const Text(
                  '현재 활성 인증 조합',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: active.isEmpty
                        ? Colors.grey.withOpacity(0.2)
                        : const Color(0xFF2DDAA9).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${active.length}개 활성',
                    style: TextStyle(
                      fontSize: 11,
                      color: active.isEmpty
                          ? Colors.grey[700]
                          : const Color(0xFF1B7E62),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (active.isNotEmpty) _buildAndChainChips(active),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  /// primitive 체인 시각화 (chip ─AND─ chip ─AND─ chip ...)
  Widget _buildAndChainChips(Set<String> active) {
    // kPrimitives 순서를 유지하기 위해 정렬
    final items = kPrimitives.where(active.contains).toList();
    final widgets = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final p = items[i];
      final color = _primitiveColor(p);
      widgets.add(
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_primitiveIcon(p), size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                partDisplayNameOf(p),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      );
      if (i < items.length - 1) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'AND',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[600],
                letterSpacing: 1,
              ),
            ),
          ),
        );
      }
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 0,
      runSpacing: 6,
      children: widgets,
    );
  }

  // -----------------------------------------------------------------
  // 5개 primitive 카드 (활성 토글 ≥ 2일 때 카드 사이 AND 라벨)
  // -----------------------------------------------------------------

  /// 활성 토글이 2개 이상인 경우, 활성 카드 사이마다 AND 라벨을 끼워 렌더
  Widget _buildPrimitiveListWithAndDividers() {
    final active = _activePrimitives();
    final showDividers = active.length >= 2;

    // 활성/비활성 무관, 카드는 항상 kPrimitives 순서로 5개 노출
    final widgets = <Widget>[];
    bool sawActive = false; // 직전에 활성 카드를 출력했는지 (AND 라벨 끼울지 판단)

    for (final p in kPrimitives) {
      final isActive = active.contains(p);
      if (showDividers && sawActive && isActive) {
        widgets.add(_buildAndDivider());
      }
      widgets.add(_buildPrimitiveCard(p));
      if (isActive) sawActive = true;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  /// 카드 사이 AND 구분선
  Widget _buildAndDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
                height: 1, color: const Color(0xFF2DDAA9).withOpacity(0.4)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF2DDAA9).withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: const Color(0xFF2DDAA9).withOpacity(0.5)),
              ),
              child: const Text(
                'AND',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1B7E62),
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
                height: 1, color: const Color(0xFF2DDAA9).withOpacity(0.4)),
          ),
        ],
      ),
    );
  }

  /// 5개 primitive 중 한 카드
  Widget _buildPrimitiveCard(String primitive) {
    final color = _primitiveColor(primitive);
    final icon = _primitiveIcon(primitive);
    final label = partDisplayNameOf(primitive);
    final isExpanded = _expandedPrimitive == primitive;
    final method = _methodByType(primitive);
    final isActive = method?.enabled ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: isExpanded ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isActive
              ? color.withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(
                () => _expandedPrimitive = isExpanded ? null : primitive),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color:
                          (isActive ? color : Colors.grey).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon,
                        color: isActive ? color : Colors.grey, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(
                          isActive ? '활성' : '비활성',
                          style: TextStyle(
                            fontSize: 12,
                            color: isActive ? color : Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Switch(
                    value: isActive,
                    onChanged: method == null
                        ? null
                        : (v) => _togglePrimitive(primitive, v),
                    activeColor: color,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) _buildPrimitiveEditor(primitive, method),
        ],
      ),
    );
  }

  Widget _buildPrimitiveEditor(String primitive, VerificationMethod? method) {
    final color = _primitiveColor(primitive);
    if (method == null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '백엔드에 $primitive method row가 없습니다.',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (primitive == 'QR') {
      return _QrPrimitiveEditor(
        key: ValueKey('QR-${_selectedUser?.id ?? 0}'),
        color: color,
        method: method,
        onSave: (enabled, config) => _savePrimitive(
          primitive: 'QR',
          enabled: enabled,
          config: config,
        ),
      );
    }
    return _PrimitiveConfigEditor(
      key: ValueKey('$primitive-${_selectedUser?.id ?? 0}'),
      primitive: primitive,
      color: color,
      method: method,
      onSave: (enabled, config) => _savePrimitive(
        primitive: primitive,
        enabled: enabled,
        config: config,
      ),
    );
  }
}

// =====================================================================
// primitive(GPS/WIFI/NFC/BEACON) 편집 위젯
// - 동적 row 카드 (각 primitive의 targets 배열)
// - WIFI는 row 한 개당 bssid/ip 라디오 + identifier_value 단일 필드
// - GPS는 "지도에서 선택" 버튼 노출
// =====================================================================
class _PrimitiveConfigEditor extends StatefulWidget {
  final String primitive; // 'GPS' | 'WIFI' | 'NFC' | 'BEACON'
  final Color color;
  final VerificationMethod method;
  final Future<void> Function(bool enabled, Map<String, dynamic> config)
      onSave;

  const _PrimitiveConfigEditor({
    super.key,
    required this.primitive,
    required this.color,
    required this.method,
    required this.onSave,
  });

  @override
  State<_PrimitiveConfigEditor> createState() => _PrimitiveConfigEditorState();
}

class _PrimitiveConfigEditorState extends State<_PrimitiveConfigEditor> {
  /// row 컨트롤러 리스트 (각 row는 fieldKey → controller)
  final List<Map<String, TextEditingController>> _rows = [];

  /// WIFI 전용: row index → identifier_type ('bssid' | 'ip')
  final List<String> _wifiIdTypes = [];

  late final List<ConfigField> _fields;

  bool _localEnabled = false;

  @override
  void initState() {
    super.initState();
    _fields = rowFieldsForPart(widget.primitive);
    _localEnabled = widget.method.enabled;

    final raw =
        extractTargets(widget.method.config, 'targets', _fields);
    final initialRows = raw.isEmpty ? [<String, dynamic>{}] : raw;
    for (final t in initialRows) {
      _addInitialRow(t);
    }
  }

  void _addInitialRow(Map<String, dynamic> data) {
    final m = <String, TextEditingController>{};
    for (final f in _fields) {
      final v = data[f.key];
      m[f.key] = TextEditingController(text: v?.toString() ?? '');
    }
    _rows.add(m);
    if (widget.primitive == 'WIFI') {
      _wifiIdTypes.add(wifiIdentifierTypeOf(data));
    }
  }

  @override
  void dispose() {
    for (final row in _rows) {
      for (final c in row.values) {
        c.dispose();
      }
    }
    super.dispose();
  }

  void _addRow() {
    setState(() => _addInitialRow(const <String, dynamic>{}));
  }

  /// row 제거 (최소 1개 유지: 마지막은 비우기만)
  void _removeRow(int index) {
    setState(() {
      if (_rows.length <= 1) {
        for (final c in _rows[0].values) {
          c.clear();
        }
        if (widget.primitive == 'WIFI') {
          _wifiIdTypes[0] = 'bssid';
        }
        return;
      }
      for (final c in _rows[index].values) {
        c.dispose();
      }
      _rows.removeAt(index);
      if (widget.primitive == 'WIFI') {
        _wifiIdTypes.removeAt(index);
      }
    });
  }

  Map<String, dynamic> _rowToMap(int index) {
    final row = _rows[index];
    final m = <String, dynamic>{};
    for (final f in _fields) {
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
    // WIFI: identifier_type 추가
    if (widget.primitive == 'WIFI') {
      m['identifier_type'] = _wifiIdTypes[index];
    }
    return m;
  }

  Future<void> _onSave() async {
    final targets = <Map<String, dynamic>>[];
    for (int i = 0; i < _rows.length; i++) {
      final m = _rowToMap(i);
      if (m.isEmpty) continue;
      // WIFI의 경우 ssid 또는 identifier_value 중 최소 하나는 있어야 의미가 있음
      targets.add(m);
    }
    final config = <String, dynamic>{'targets': targets};
    await widget.onSave(_localEnabled, config);
  }

  /// GPS 지도 픽업 다이얼로그 호출 → 결과를 row 컨트롤러에 반영
  Future<void> _openGpsPicker(int i) async {
    final latText = _rows[i]['lat']?.text.trim() ?? '';
    final lngText = _rows[i]['lng']?.text.trim() ?? '';
    final radiusText = _rows[i]['radius_m']?.text.trim() ?? '';
    final result = await showDialog<GpsPickResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => GpsPickerDialog(
        initialLat: double.tryParse(latText),
        initialLng: double.tryParse(lngText),
        initialRadiusMeters: int.tryParse(radiusText),
      ),
    );
    if (result == null || !mounted) return;
    setState(() {
      _rows[i]['lat']?.text = result.latitude.toStringAsFixed(6);
      _rows[i]['lng']?.text = result.longitude.toStringAsFixed(6);
      _rows[i]['radius_m']?.text = result.radiusMeters.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),

          // 활성 토글
          Row(
            children: [
              const Text('활성 상태:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Switch(
                value: _localEnabled,
                activeColor: widget.color,
                onChanged: (v) => setState(() => _localEnabled = v),
              ),
              const SizedBox(width: 4),
              Text(_localEnabled ? 'ON' : 'OFF',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          _localEnabled ? widget.color : Colors.grey)),
              const SizedBox(width: 16),
              if (widget.primitive == 'BEACON')
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'rssi_threshold는 서버가 자동 계산 (RSSI = TxPower − 20·log10(d))',
                    style: TextStyle(fontSize: 11, color: Colors.blueGrey),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // row 카드들
          for (int i = 0; i < _rows.length; i++) _buildRowCard(i),

          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: Text('${partDisplayNameOf(widget.primitive)} 추가'),
              onPressed: _addRow,
              style: TextButton.styleFrom(foregroundColor: widget.color),
            ),
          ),
          const SizedBox(height: 8),

          // 버튼 행
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('저장'),
                onPressed: _onSave,
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

  Widget _buildRowCard(int i) {
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
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('#${i + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.color,
                        fontWeight: FontWeight.w700,
                      )),
                ),
                const Spacer(),
                if (widget.primitive == 'GPS')
                  TextButton.icon(
                    icon: const Icon(Icons.map_outlined, size: 18),
                    label: const Text('지도에서 선택'),
                    onPressed: () => _openGpsPicker(i),
                    style: TextButton.styleFrom(
                      foregroundColor: widget.color,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  tooltip: _rows.length == 1 ? '값 비우기' : '이 row 삭제',
                  color: Colors.red,
                  visualDensity: VisualDensity.compact,
                  onPressed: () => _removeRow(i),
                ),
              ],
            ),
            if (widget.primitive == 'WIFI')
              _buildWifiRowFields(i)
            else
              _buildGenericRowFields(i),
          ],
        ),
      ),
    );
  }

  /// 일반 row 필드 (GPS / NFC / BEACON)
  Widget _buildGenericRowFields(int i) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _fields.map((field) {
        return SizedBox(
          width: 220,
          child: TextField(
            controller: _rows[i][field.key],
            keyboardType: field.type == ConfigFieldType.int_ ||
                    field.type == ConfigFieldType.double_
                ? const TextInputType.numberWithOptions(
                    decimal: true, signed: true)
                : TextInputType.text,
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
    );
  }

  /// WiFi row 필드 (SSID + bssid/ip 라디오 + identifier_value 단일 필드)
  Widget _buildWifiRowFields(int i) {
    final type = _wifiIdTypes[i];
    final identifierLabel = type == 'ip' ? 'IP 주소' : 'BSSID (MAC)';
    final identifierHint = type == 'ip'
        ? '예: 192.168.10.5 또는 게이트웨이 IP'
        : '예: aa:bb:cc:dd:ee:ff (콜론/하이픈 무관)';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SSID
        SizedBox(
          width: 320,
          child: TextField(
            controller: _rows[i]['ssid'],
            decoration: const InputDecoration(
              labelText: 'WiFi SSID',
              helperText: '네트워크 이름 (항상 비교)',
              border: OutlineInputBorder(),
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
        const SizedBox(height: 12),
        // 식별자 타입 라디오
        Row(
          children: [
            const Text('식별자: ',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('BSSID'),
              selected: type == 'bssid',
              selectedColor: widget.color.withOpacity(0.2),
              onSelected: (_) =>
                  setState(() => _wifiIdTypes[i] = 'bssid'),
            ),
            const SizedBox(width: 6),
            ChoiceChip(
              label: const Text('IP'),
              selected: type == 'ip',
              selectedColor: widget.color.withOpacity(0.2),
              onSelected: (_) => setState(() => _wifiIdTypes[i] = 'ip'),
            ),
            const SizedBox(width: 12),
            Text(
              type == 'ip'
                  ? 'IP 주소로 매칭 (게이트웨이/단말 IP)'
                  : 'MAC 주소로 매칭 (정확도 높음)',
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // identifier_value 단일 필드
        SizedBox(
          width: 360,
          child: TextField(
            controller: _rows[i]['identifier_value'],
            decoration: InputDecoration(
              labelText: identifierLabel,
              helperText: identifierHint,
              border: const OutlineInputBorder(),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// QR primitive 편집 위젯
// - codes[] 멀티 입력 + ON/OFF 토글
// - 프리셋 카탈로그(method_type='QR')에서 페이로드 끼워넣기 지원
// =====================================================================
class _QrPrimitiveEditor extends StatefulWidget {
  final Color color;
  final VerificationMethod method;
  final Future<void> Function(bool enabled, Map<String, dynamic> config)
      onSave;

  const _QrPrimitiveEditor({
    super.key,
    required this.color,
    required this.method,
    required this.onSave,
  });

  @override
  State<_QrPrimitiveEditor> createState() => _QrPrimitiveEditorState();
}

class _QrPrimitiveEditorState extends State<_QrPrimitiveEditor> {
  final List<TextEditingController> _codeCtrls = [];
  bool _localEnabled = false;

  @override
  void initState() {
    super.initState();
    _localEnabled = widget.method.enabled;
    final codes = extractQrCodes(widget.method.config);
    final initial = codes.isEmpty ? [''] : codes;
    for (final c in initial) {
      _codeCtrls.add(TextEditingController(text: c));
    }
  }

  @override
  void dispose() {
    for (final c in _codeCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  void _addCode() {
    setState(() => _codeCtrls.add(TextEditingController()));
  }

  void _removeCode(int index) {
    setState(() {
      if (_codeCtrls.length <= 1) {
        _codeCtrls[0].clear();
        return;
      }
      _codeCtrls[index].dispose();
      _codeCtrls.removeAt(index);
    });
  }

  Future<void> _onSave() async {
    final codes = _codeCtrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await widget.onSave(_localEnabled, {'codes': codes});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          Row(
            children: [
              const Text('활성 상태:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              Switch(
                value: _localEnabled,
                activeColor: widget.color,
                onChanged: (v) => setState(() => _localEnabled = v),
              ),
              const SizedBox(width: 4),
              Text(_localEnabled ? 'ON' : 'OFF',
                  style: TextStyle(
                      fontSize: 12,
                      color:
                          _localEnabled ? widget.color : Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          const Text('QR 페이로드 (codes[])',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (int i = 0; i < _codeCtrls.length; i++)
            Card(
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
                      child: Text('#${i + 1}',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.color,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _codeCtrls[i],
                        decoration: const InputDecoration(
                          labelText: 'QR 페이로드',
                          helperText: '예: WC-HQ-QR-001',
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
                      tooltip:
                          _codeCtrls.length == 1 ? '값 비우기' : 'QR 삭제',
                      color: Colors.red,
                      visualDensity: VisualDensity.compact,
                      onPressed: () => _removeCode(i),
                    ),
                  ],
                ),
              ),
            ),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              icon: const Icon(Icons.add, size: 18),
              label: const Text('QR 코드 추가'),
              onPressed: _addCode,
              style: TextButton.styleFrom(foregroundColor: widget.color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.save, size: 18),
                label: const Text('저장'),
                onPressed: _onSave,
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
