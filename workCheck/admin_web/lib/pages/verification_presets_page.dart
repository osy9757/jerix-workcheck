import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../utils/verification_targets.dart';

/// 인증 프리셋 페이지
/// - NFC/WiFi/GPS/Beacon 등 자주 쓰이는 인증값을 이름 붙여 저장하는 카탈로그
/// - method_type 필터 + 추가/수정/삭제
class VerificationPresetsPage extends StatefulWidget {
  final ApiService apiService;
  const VerificationPresetsPage({super.key, required this.apiService});

  @override
  State<VerificationPresetsPage> createState() =>
      _VerificationPresetsPageState();
}

class _VerificationPresetsPageState extends State<VerificationPresetsPage> {
  // 필터 칩에 사용하는 인증 수단 목록 (전체 = null)
  static const List<String> _allMethodTypes = [
    'GPS',
    'GPS_QR',
    'WIFI',
    'WIFI_QR',
    'NFC',
    'NFC_GPS',
    'BEACON',
    'BEACON_GPS',
  ];

  List<VerificationPreset> _presets = []; // 현재 표시 중인 프리셋 목록
  String? _filterMethodType; // null = 전체
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 프리셋 목록 조회 (필터 적용)
  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await widget.apiService.getPresets(
        methodType: _filterMethodType,
      );
      if (mounted) {
        setState(() {
          _presets = list;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '프리셋을 불러올 수 없습니다';
          _loading = false;
        });
      }
    }
  }

  /// 추가 다이얼로그
  void _showAddDialog() {
    _showEditDialog(null);
  }

  /// 추가/수정 공용 다이얼로그
  /// preset == null → 신규 생성 모드, 있으면 수정 모드
  void _showEditDialog(VerificationPreset? preset) {
    showDialog(
      context: context,
      builder: (ctx) => _PresetEditDialog(
        apiService: widget.apiService,
        preset: preset,
        onSaved: () {
          Navigator.pop(ctx);
          _load();
        },
      ),
    );
  }

  /// 삭제 확인 다이얼로그
  Future<void> _confirmDelete(VerificationPreset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('프리셋 삭제'),
        content: Text('"${preset.name}" 프리셋을 삭제할까요?\n복구할 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.apiService.deletePreset(preset.id);
      _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다')),
        );
      }
    }
  }

  /// method_type을 한글 이름으로 변환
  String _displayName(String methodType) {
    switch (methodType) {
      case 'GPS':
        return 'GPS';
      case 'GPS_QR':
        return 'GPS + QR';
      case 'WIFI':
        return 'WiFi';
      case 'WIFI_QR':
        return 'WiFi + QR';
      case 'NFC':
        return 'NFC';
      case 'NFC_GPS':
        return 'NFC + GPS';
      case 'BEACON':
        return 'Beacon';
      case 'BEACON_GPS':
        return 'Beacon + GPS';
      default:
        return methodType;
    }
  }

  /// configData를 한 줄 요약 문자열로 만들기 (DataTable 표시용)
  /// 신 schema(`*_targets`/`qr_codes`) 기준으로 부품별 개수를 표시.
  /// 단일 dict 폴백도 호환 ("위치 1개" 등으로 표시).
  String _summarizeConfig(VerificationPreset p) {
    if (p.configData.isEmpty) return '-';
    final groups = partGroupsFor(p.methodType);
    final summaries = <String>[];

    // 부품 그룹별 타겟 개수
    for (final g in groups) {
      final fields = rowFieldsForPart(g.partType);
      final targets = extractTargets(p.configData, g.configKey, fields);
      if (targets.isEmpty) continue;
      summaries.add('${partDisplayNameOf(g.partType)} ${targets.length}개');
    }

    // QR 코드 개수 (GPS_QR/WIFI_QR만)
    if (hasQrCodesSection(p.methodType)) {
      final qrs = extractQrCodes(p.configData);
      if (qrs.isNotEmpty) {
        summaries.add('QR ${qrs.length}개');
      }
    }

    if (summaries.isEmpty) {
      // 알 수 없는 형태: 키만 노출
      return p.configData.keys.join(', ');
    }
    return summaries.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '인증 프리셋',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: _load,
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('프리셋 추가'),
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
            '자주 쓰이는 NFC/WiFi/GPS/Beacon 값을 이름 붙여 저장하고 인증 설정 화면에서 재사용합니다.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // 필터 칩
          _buildFilterChips(),
          const SizedBox(height: 16),

          // 본문
          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (_error != null)
            Expanded(
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else if (_presets.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border,
                        size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text(
                      '프리셋이 없습니다',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(child: _buildTable()),
        ],
      ),
    );
  }

  /// 필터 칩 영역 (전체 + method_type별)
  Widget _buildFilterChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('전체'),
          selected: _filterMethodType == null,
          selectedColor: const Color(0xFF2DDAA9).withOpacity(0.2),
          checkmarkColor: const Color(0xFF2DDAA9),
          onSelected: (_) {
            setState(() => _filterMethodType = null);
            _load();
          },
        ),
        ..._allMethodTypes.map((mt) {
          final selected = _filterMethodType == mt;
          return FilterChip(
            label: Text(_displayName(mt)),
            selected: selected,
            selectedColor: const Color(0xFF2DDAA9).withOpacity(0.2),
            checkmarkColor: const Color(0xFF2DDAA9),
            onSelected: (_) {
              setState(() => _filterMethodType = selected ? null : mt);
              _load();
            },
          );
        }),
      ],
    );
  }

  /// 프리셋 DataTable
  Widget _buildTable() {
    return Card(
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
              DataColumn(label: Text('이름')),
              DataColumn(label: Text('인증 수단')),
              DataColumn(label: Text('설정값')),
              DataColumn(label: Text('메모')),
              DataColumn(label: Text('작업')),
            ],
            rows: _presets.map((p) {
              return DataRow(cells: [
                DataCell(Text('${p.id}')),
                DataCell(Text(p.name)),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DDAA9).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _displayName(p.methodType),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1B7E62),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: Text(
                      _summarizeConfig(p),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 200),
                    child: Text(
                      p.memo ?? '-',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, size: 18),
                        tooltip: '수정',
                        color: const Color(0xFF2DDAA9),
                        onPressed: () => _showEditDialog(p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        tooltip: '삭제',
                        color: Colors.red,
                        onPressed: () => _confirmDelete(p),
                      ),
                    ],
                  ),
                ),
              ]);
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// 프리셋 추가/수정 다이얼로그 (동적 row UI - 신 schema)
/// - 인증 수단 드롭다운 변경 시 부품 그룹 단위로 row UI 재생성
/// - 부품 그룹별 row 카드 N개 + "+ 추가" 버튼
/// - GPS_QR/WIFI_QR은 별도 QR 코드 섹션
/// - 최소 1 row 유지
class _PresetEditDialog extends StatefulWidget {
  final ApiService apiService;
  final VerificationPreset? preset; // null이면 신규
  final VoidCallback onSaved;

  const _PresetEditDialog({
    required this.apiService,
    required this.preset,
    required this.onSaved,
  });

  @override
  State<_PresetEditDialog> createState() => _PresetEditDialogState();
}

class _PresetEditDialogState extends State<_PresetEditDialog> {
  // 지원 인증 수단 (드롭다운 옵션)
  static const List<String> _supportedTypes = [
    'NFC',
    'NFC_GPS',
    'WIFI',
    'WIFI_QR',
    'GPS',
    'GPS_QR',
    'BEACON',
    'BEACON_GPS',
  ];

  late final TextEditingController _nameCtrl;
  late final TextEditingController _memoCtrl;
  late String _methodType; // 현재 선택된 인증 수단

  /// configKey → 부품 row 컨트롤러 리스트 (각 row는 field key → TextEditingController)
  final Map<String, List<Map<String, TextEditingController>>> _rowsByKey = {};

  /// QR 코드 컨트롤러 리스트 (qr_codes 섹션)
  final List<TextEditingController> _qrCodeCtrls = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _memoCtrl = TextEditingController(text: p?.memo ?? '');
    _methodType = p?.methodType ?? 'NFC';

    _initRowsForCurrentMethodType(p?.configData ?? const <String, dynamic>{});
  }

  /// 현재 _methodType에 맞춰 row 컨트롤러를 (재)초기화
  /// 신/구 schema 호환: configKey 배열 우선, 없으면 단일 dict 폴백
  void _initRowsForCurrentMethodType(Map<String, dynamic> source) {
    final groups = partGroupsFor(_methodType);
    for (final group in groups) {
      final fields = rowFieldsForPart(group.partType);
      var targets = extractTargets(source, group.configKey, fields);
      if (targets.isEmpty) targets = [<String, dynamic>{}]; // 최소 1 row 유지
      _rowsByKey[group.configKey] =
          targets.map((t) => _makeRowControllers(fields, t)).toList();
    }
    if (hasQrCodesSection(_methodType)) {
      var codes = extractQrCodes(source);
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

  /// 모든 row/QR 컨트롤러 dispose 후 _rowsByKey/_qrCodeCtrls 클리어
  void _disposeAllRowControllers() {
    for (final list in _rowsByKey.values) {
      for (final row in list) {
        for (final c in row.values) {
          c.dispose();
        }
      }
    }
    _rowsByKey.clear();
    for (final c in _qrCodeCtrls) {
      c.dispose();
    }
    _qrCodeCtrls.clear();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memoCtrl.dispose();
    _disposeAllRowControllers();
    super.dispose();
  }

  /// 인증 수단 변경 처리: 기존 컨트롤러 폐기 후 새 type에 맞춰 빈 row 1개로 초기화
  void _onMethodTypeChanged(String? v) {
    if (v == null || v == _methodType) return;
    setState(() {
      _disposeAllRowControllers();
      _methodType = v;
      // 메서드 변경 시 기존 입력 값은 폐기 (서로 다른 부품 구조)
      _initRowsForCurrentMethodType(const <String, dynamic>{});
    });
  }

  /// 부품 그룹에 빈 row 추가
  void _addRow(PartGroup group) {
    setState(() {
      final fields = rowFieldsForPart(group.partType);
      _rowsByKey[group.configKey]!
          .add(_makeRowControllers(fields, const <String, dynamic>{}));
    });
  }

  /// 부품 그룹의 row 삭제 (최소 1개 유지)
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

  /// 신 schema로 직렬화 (빈 row는 제외)
  Map<String, dynamic> _buildConfigData() {
    final config = <String, dynamic>{};
    final groups = partGroupsFor(_methodType);
    for (final group in groups) {
      final fields = rowFieldsForPart(group.partType);
      final list = _rowsByKey[group.configKey] ?? const [];
      final arr = <Map<String, dynamic>>[];
      for (final row in list) {
        final m = _rowToMap(row, fields);
        if (m.isNotEmpty) arr.add(m);
      }
      config[group.configKey] = arr;
    }
    if (hasQrCodesSection(_methodType)) {
      final codes = _qrCodeCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      config['qr_codes'] = codes;
    }
    return config;
  }

  /// 저장 핸들러 (생성 또는 수정)
  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이름을 입력하세요')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final memo =
          _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim();
      final config = _buildConfigData();

      if (widget.preset == null) {
        // 신규 생성
        await widget.apiService.createPreset(
          name: name,
          methodType: _methodType,
          configData: config,
          memo: memo,
        );
      } else {
        // 수정 (PUT 전체 덮어쓰기)
        await widget.apiService.updatePreset(
          widget.preset!.id,
          name: name,
          methodType: _methodType,
          configData: config,
          memo: memo,
        );
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                widget.preset == null ? '프리셋이 생성되었습니다' : '프리셋이 수정되었습니다'),
            duration: const Duration(seconds: 1),
          ),
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

  /// 한글 라벨 (인증 수단 표시명)
  String _displayName(String methodType) {
    switch (methodType) {
      case 'GPS':
        return 'GPS';
      case 'GPS_QR':
        return 'GPS + QR';
      case 'WIFI':
        return 'WiFi';
      case 'WIFI_QR':
        return 'WiFi + QR';
      case 'NFC':
        return 'NFC';
      case 'NFC_GPS':
        return 'NFC + GPS';
      case 'BEACON':
        return 'Beacon';
      case 'BEACON_GPS':
        return 'Beacon + GPS';
      default:
        return methodType;
    }
  }

  static const Color _primary = Color(0xFF2DDAA9);

  /// 부품 그룹 섹션 빌드 (헤더 + row 카드들 + 추가 버튼)
  Widget _buildPartSection(PartGroup group) {
    final fields = rowFieldsForPart(group.partType);
    final rows = _rowsByKey[group.configKey] ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Row(
            children: [
              Text(
                group.label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rows.length}개',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '#${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: _primary,
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
                  ...fields.map((f) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextField(
                        controller: rows[i][f.key],
                        keyboardType: f.type == ConfigFieldType.int_ ||
                                f.type == ConfigFieldType.double_
                            ? const TextInputType.numberWithOptions(
                                decimal: true, signed: true)
                            : TextInputType.text,
                        decoration: InputDecoration(
                          labelText: f.label,
                          helperText: f.hint,
                          border: const OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: Text('${group.label} 추가'),
            onPressed: () => _addRow(group),
            style: TextButton.styleFrom(foregroundColor: _primary),
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
              const Text(
                'QR 코드',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _primary,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_qrCodeCtrls.length}개',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _primary,
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
                      color: _primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '#${i + 1}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _primary,
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
                      ),
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
            style: TextButton.styleFrom(foregroundColor: _primary),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.preset != null;
    final groups = partGroupsFor(_methodType);
    final hasQr = hasQrCodesSection(_methodType);

    return AlertDialog(
      title: Text(isEditMode ? '프리셋 수정' : '프리셋 추가'),
      content: SizedBox(
        width: 540,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: '이름 *',
                  hintText: '예: 사무실 정문 NFC',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),

              // 인증 수단 드롭다운
              DropdownButtonFormField<String>(
                value: _methodType,
                decoration: const InputDecoration(
                  labelText: '인증 수단 *',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                items: _supportedTypes.map((mt) {
                  return DropdownMenuItem(
                    value: mt,
                    child: Text(_displayName(mt)),
                  );
                }).toList(),
                onChanged: _onMethodTypeChanged,
              ),
              const SizedBox(height: 16),

              // 부품 그룹별 동적 row 섹션
              if (groups.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    '이 인증 수단은 추가 설정값이 필요하지 않습니다.',
                    style: TextStyle(fontSize: 12),
                  ),
                )
              else
                ...groups.map(_buildPartSection),

              // QR 코드 섹션 (GPS_QR/WIFI_QR)
              if (hasQr) _buildQrCodesSection(),

              const SizedBox(height: 12),

              // 메모
              TextField(
                controller: _memoCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '메모',
                  hintText: '용도, 설치 위치 등',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        ElevatedButton(
          onPressed: _saving ? null : _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primary,
            foregroundColor: Colors.white,
          ),
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(isEditMode ? '수정' : '추가'),
        ),
      ],
    );
  }
}
