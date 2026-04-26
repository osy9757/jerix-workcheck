import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

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
  String _summarizeConfig(VerificationPreset p) {
    if (p.configData.isEmpty) return '-';
    // 좌표가 모두 있으면 "(lat, lng)" 형태로, 없으면 null
    final lat = p.configData['latitude'];
    final lng = p.configData['longitude'];
    final coord = (lat != null && lng != null) ? '($lat, $lng)' : null;

    switch (p.methodType) {
      case 'NFC':
        return 'tag_id: ${p.configData['tag_id'] ?? '-'}';
      case 'NFC_GPS':
        // tag_id + (좌표 있으면) + 반경
        final tag = p.configData['tag_id'] ?? '-';
        final r = p.configData['radius_meters'] ?? '-';
        final parts = <String>['tag_id: $tag'];
        if (coord != null) parts.add(coord);
        parts.add('반경: ${r}m');
        return parts.join(' / ');
      case 'WIFI':
      case 'WIFI_QR':
        final ssid = p.configData['ssid'] ?? '-';
        final bssid = p.configData['bssid'] ?? '-';
        return 'SSID: $ssid / BSSID: $bssid';
      case 'GPS':
      case 'GPS_QR':
        // 좌표 있으면 좌표 + 반경, 없으면 반경만
        final r = p.configData['radius_meters'] ?? '-';
        if (coord != null) {
          return '$coord / 반경: ${r}m';
        }
        return '반경: ${r}m';
      case 'BEACON':
        final uuid = p.configData['uuid']?.toString() ?? '-';
        final shortUuid = uuid.length > 8 ? '${uuid.substring(0, 8)}…' : uuid;
        return 'UUID: $shortUuid / major:${p.configData['major'] ?? '-'} / minor:${p.configData['minor'] ?? '-'}';
      case 'BEACON_GPS':
        // BEACON 요약 + (좌표 있으면) + 반경
        final uuid = p.configData['uuid']?.toString() ?? '-';
        final shortUuid = uuid.length > 8 ? '${uuid.substring(0, 8)}…' : uuid;
        final r = p.configData['radius_meters'] ?? '-';
        final parts = <String>[
          'UUID: $shortUuid',
          'major:${p.configData['major'] ?? '-'}',
          'minor:${p.configData['minor'] ?? '-'}',
        ];
        if (coord != null) parts.add(coord);
        parts.add('반경: ${r}m');
        return parts.join(' / ');
      default:
        // 알 수 없는 타입은 키만 노출
        return p.configData.keys.join(', ');
    }
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

/// 프리셋 추가/수정 다이얼로그
/// - 인증 수단 드롭다운 변경 시 입력 필드가 동적으로 바뀜
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

  // method_type별 동적 필드 컨트롤러 (전부 생성해두고 보이는 것만 사용)
  final Map<String, TextEditingController> _fieldCtrls = {};

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.preset;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _memoCtrl = TextEditingController(text: p?.memo ?? '');
    _methodType = p?.methodType ?? 'NFC';

    // 가능한 모든 필드 키에 대해 컨트롤러 생성 (값 유지)
    // GPS 계열은 좌표(latitude/longitude)도 프리셋에 직접 저장
    for (final key in const [
      'tag_id',
      'ssid',
      'bssid',
      'qr_code',
      'radius_meters',
      'latitude',
      'longitude',
      'uuid',
      'major',
      'minor',
      'rssi_threshold',
    ]) {
      final initial = p?.configData[key]?.toString() ?? '';
      _fieldCtrls[key] = TextEditingController(text: initial);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _memoCtrl.dispose();
    for (final c in _fieldCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// 현재 method_type에 노출할 필드 정의 목록
  List<_PresetField> _currentFields() {
    switch (_methodType) {
      case 'NFC':
        return const [
          _PresetField('tag_id', 'NFC 태그 ID', '예: 04:E9:D8:3E:C8:2A:81',
              _PresetFieldType.string),
        ];
      case 'NFC_GPS':
        return const [
          _PresetField('tag_id', 'NFC 태그 ID', '예: 04:E9:D8:3E:C8:2A:81',
              _PresetFieldType.string),
          _PresetField('latitude', '위도', '예: 37.5665',
              _PresetFieldType.double_),
          _PresetField('longitude', '경도', '예: 126.9780',
              _PresetFieldType.double_),
          _PresetField('radius_meters', '반경 (m)', '예: 200',
              _PresetFieldType.int_),
        ];
      case 'WIFI':
        return const [
          _PresetField(
              'ssid', 'WiFi SSID', '네트워크 이름', _PresetFieldType.string),
          _PresetField(
              'bssid', 'WiFi BSSID', 'MAC 주소 (옵션)', _PresetFieldType.string),
        ];
      case 'WIFI_QR':
        return const [
          _PresetField(
              'ssid', 'WiFi SSID', '네트워크 이름', _PresetFieldType.string),
          _PresetField(
              'bssid', 'WiFi BSSID', 'MAC 주소 (옵션)', _PresetFieldType.string),
          _PresetField(
              'qr_code', 'QR 코드', 'QR 페이로드', _PresetFieldType.string),
        ];
      case 'GPS':
        return const [
          _PresetField('latitude', '위도', '예: 37.5665',
              _PresetFieldType.double_),
          _PresetField('longitude', '경도', '예: 126.9780',
              _PresetFieldType.double_),
          _PresetField('radius_meters', '반경 (m)', '예: 200',
              _PresetFieldType.int_),
        ];
      case 'GPS_QR':
        return const [
          _PresetField('latitude', '위도', '예: 37.5665',
              _PresetFieldType.double_),
          _PresetField('longitude', '경도', '예: 126.9780',
              _PresetFieldType.double_),
          _PresetField('radius_meters', '반경 (m)', '예: 200',
              _PresetFieldType.int_),
          _PresetField(
              'qr_code', 'QR 코드', 'QR 페이로드', _PresetFieldType.string),
        ];
      case 'BEACON':
        return const [
          _PresetField('uuid', 'Beacon UUID',
              '예: E2C56DB5-DFFB-48D2-B060-D0F5A71096E0', _PresetFieldType.string),
          _PresetField(
              'major', 'Major', '정수값', _PresetFieldType.int_),
          _PresetField(
              'minor', 'Minor', '정수값', _PresetFieldType.int_),
          _PresetField('rssi_threshold', 'RSSI 임계값', '음수 (예: -80)',
              _PresetFieldType.int_),
        ];
      case 'BEACON_GPS':
        return const [
          _PresetField('uuid', 'Beacon UUID',
              '예: E2C56DB5-DFFB-48D2-B060-D0F5A71096E0', _PresetFieldType.string),
          _PresetField(
              'major', 'Major', '정수값', _PresetFieldType.int_),
          _PresetField(
              'minor', 'Minor', '정수값', _PresetFieldType.int_),
          _PresetField('rssi_threshold', 'RSSI 임계값', '음수 (예: -80)',
              _PresetFieldType.int_),
          _PresetField('latitude', '위도', '예: 37.5665',
              _PresetFieldType.double_),
          _PresetField('longitude', '경도', '예: 126.9780',
              _PresetFieldType.double_),
          _PresetField('radius_meters', '반경 (m)', '예: 200',
              _PresetFieldType.int_),
        ];
      default:
        return const [];
    }
  }

  /// 컨트롤러 텍스트를 타입에 맞춰 파싱
  Map<String, dynamic> _buildConfigData() {
    final result = <String, dynamic>{};
    for (final field in _currentFields()) {
      final raw = _fieldCtrls[field.key]?.text.trim() ?? '';
      if (raw.isEmpty) continue; // 빈 값은 저장 안 함
      switch (field.type) {
        case _PresetFieldType.int_:
          final n = int.tryParse(raw);
          if (n != null) {
            result[field.key] = n;
          } else {
            // 파싱 실패 시 그대로 (서버가 자유 JSONB로 받음)
            result[field.key] = raw;
          }
          break;
        case _PresetFieldType.double_:
          final d = double.tryParse(raw);
          if (d != null) {
            result[field.key] = d;
          } else {
            result[field.key] = raw;
          }
          break;
        case _PresetFieldType.string:
          result[field.key] = raw;
          break;
      }
    }
    return result;
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
      final memo = _memoCtrl.text.trim().isEmpty ? null : _memoCtrl.text.trim();
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
            content: Text(widget.preset == null ? '프리셋이 생성되었습니다' : '프리셋이 수정되었습니다'),
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

  /// 한글 라벨
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

  @override
  Widget build(BuildContext context) {
    final fields = _currentFields();
    final isEditMode = widget.preset != null;

    return AlertDialog(
      title: Text(isEditMode ? '프리셋 수정' : '프리셋 추가'),
      content: SizedBox(
        width: 480,
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
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _methodType = v);
                },
              ),
              const SizedBox(height: 16),

              // method_type별 동적 필드
              if (fields.isEmpty)
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '설정값',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...fields.map((f) {
                      final ctrl = _fieldCtrls[f.key]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: TextField(
                          controller: ctrl,
                          keyboardType: f.type == _PresetFieldType.int_ ||
                                  f.type == _PresetFieldType.double_
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
            backgroundColor: const Color(0xFF2DDAA9),
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

/// 다이얼로그 내부의 동적 필드 정의
enum _PresetFieldType { int_, double_, string }

class _PresetField {
  final String key; // configData 키 (snake_case)
  final String label;
  final String hint;
  final _PresetFieldType type;

  const _PresetField(this.key, this.label, this.hint, this.type);
}
