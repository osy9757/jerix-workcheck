import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// 인증 방법 관리 페이지 - 근무지별
class VerificationPage extends StatefulWidget {
  final ApiService apiService;
  const VerificationPage({super.key, required this.apiService});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  List<Workplace> _workplaces = []; // 근무지 목록
  Workplace? _selectedWorkplace; // 현재 선택된 근무지
  List<VerificationMethod> _methods = []; // 선택된 근무지의 인증 방법 목록
  bool _loadingWorkplaces = true; // 근무지 로딩 상태
  bool _loadingMethods = false; // 인증 방법 로딩 상태
  String? _error; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadWorkplaces();
  }

  /// 근무지 목록 로드
  Future<void> _loadWorkplaces() async {
    setState(() => _loadingWorkplaces = true);
    try {
      final workplaces = await widget.apiService.getWorkplaces();
      if (mounted) {
        setState(() {
          _workplaces = workplaces;
          _loadingWorkplaces = false;
          // 근무지가 있으면 첫 번째 자동 선택
          if (workplaces.isNotEmpty && _selectedWorkplace == null) {
            _selectedWorkplace = workplaces.first;
            _loadMethods();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = '근무지 목록을 불러올 수 없습니다'; _loadingWorkplaces = false; });
    }
  }

  /// 선택된 근무지의 인증 방법 로드
  Future<void> _loadMethods() async {
    if (_selectedWorkplace == null) return;
    setState(() {
      _loadingMethods = true;
      _error = null;
    });
    try {
      final methods = await widget.apiService
          .getWorkplaceVerificationMethods(_selectedWorkplace!.id);
      if (mounted) setState(() { _methods = methods; _loadingMethods = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '인증 방법을 불러올 수 없습니다'; _loadingMethods = false; });
    }
  }

  /// ON/OFF 토글 처리
  Future<void> _toggleMethod(VerificationMethod method) async {
    if (_selectedWorkplace == null) return;
    try {
      await widget.apiService.updateWorkplaceVerificationMethod(
        _selectedWorkplace!.id,
        method.id!,
        enabled: !method.enabled,
        config: method.config,
      );
      _loadMethods();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 변경에 실패했습니다')),
        );
      }
    }
  }

  /// GPS 관련 방법인지 확인
  bool _isGpsMethod(String methodType) {
    return const {'GPS', 'GPS_QR', 'NFC_GPS', 'BEACON_GPS'}.contains(methodType);
  }

  /// GPS 방법에서 숨길 좌표 필드
  static const _gpsHiddenFields = {'latitude', 'longitude'};

  /// 설정 편집 다이얼로그
  void _showEditDialog(VerificationMethod method) {
    final isGps = _isGpsMethod(method.methodType);
    final controllers = <String, TextEditingController>{};
    for (final entry in method.config.entries) {
      controllers[entry.key] = TextEditingController(
        text: entry.value.toString(),
      );
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${method.displayName} 설정'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // GPS 방법: 좌표는 근무지 설정 사용 안내
                if (isGps)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2DDAA9).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF2DDAA9).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF2DDAA9), size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'GPS 좌표는 근무지 위치를 사용합니다',
                            style: TextStyle(fontSize: 13, color: Color(0xFF2DDAA9)),
                          ),
                        ),
                      ],
                    ),
                  ),
                // 필드 목록 (GPS면 좌표 필드 제외)
                ...controllers.entries
                    .where((entry) => !isGps || !_gpsHiddenFields.contains(entry.key))
                    .map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: entry.value,
                      decoration: InputDecoration(
                        labelText: _configFieldLabel(entry.key),
                        border: const OutlineInputBorder(),
                        helperText: _configFieldHelper(entry.key),
                      ),
                    ),
                  );
                }),
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
              final newConfig = <String, dynamic>{};
              for (final entry in controllers.entries) {
                // GPS 방법에서 숨긴 좌표 필드는 원본 값 유지
                if (isGps && _gpsHiddenFields.contains(entry.key)) {
                  newConfig[entry.key] = method.config[entry.key];
                } else {
                  newConfig[entry.key] = _parseConfigValue(
                    entry.key,
                    entry.value.text,
                  );
                }
              }
              try {
                await widget.apiService.updateWorkplaceVerificationMethod(
                  _selectedWorkplace!.id,
                  method.id!,
                  enabled: method.enabled,
                  config: newConfig,
                );
                if (ctx.mounted) Navigator.pop(ctx);
                _loadMethods();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('설정이 저장되었습니다')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('저장에 실패했습니다')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2DDAA9),
              foregroundColor: Colors.white,
            ),
            child: const Text('저장'),
          ),
        ],
      ),
    );
  }

  /// config 필드의 한글 라벨
  String _configFieldLabel(String key) {
    switch (key) {
      case 'latitude': return '위도';
      case 'longitude': return '경도';
      case 'radius_meters': return '반경 (m)';
      case 'ssid': return 'WiFi SSID';
      case 'bssid': return 'WiFi BSSID';
      case 'tag_id': return 'NFC 태그 ID';
      case 'uuid': return 'Beacon UUID';
      case 'major': return 'Major';
      case 'minor': return 'Minor';
      case 'rssi_threshold': return 'RSSI 임계값';
      case 'qr_code': return 'QR 코드 값';
      default: return key;
    }
  }

  /// config 필드의 도움말
  String? _configFieldHelper(String key) {
    switch (key) {
      case 'latitude': return '예: 37.5665';
      case 'longitude': return '예: 126.9780';
      case 'radius_meters': return '미터 단위';
      case 'rssi_threshold': return '음수값 (예: -70)';
      default: return null;
    }
  }

  /// config 값 파싱
  dynamic _parseConfigValue(String key, String value) {
    const intFields = {'major', 'minor', 'radius_meters'};
    const doubleFields = {'latitude', 'longitude', 'rssi_threshold'};

    if (intFields.contains(key)) return int.tryParse(value) ?? value;
    if (doubleFields.contains(key)) return double.tryParse(value) ?? value;
    return value;
  }

  /// 아이콘 매핑
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
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '인증 방법 관리',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: () {
                  _loadWorkplaces();
                  if (_selectedWorkplace != null) _loadMethods();
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '근무지를 선택하고 인증 방법을 관리할 수 있습니다',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // 근무지 선택 드롭다운
          if (_loadingWorkplaces)
            const SizedBox(height: 48, child: Center(child: CircularProgressIndicator()))
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF2DDAA9)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedWorkplace?.id,
                  hint: const Text('근무지를 선택하세요'),
                  isExpanded: false,
                  icon: const Icon(Icons.business, color: Color(0xFF2DDAA9)),
                  items: _workplaces.map((wp) {
                    return DropdownMenuItem(
                      value: wp.id,
                      child: Text('${wp.name}${wp.address != null ? ' (${wp.address})' : ''}'),
                    );
                  }).toList(),
                  onChanged: (id) {
                    if (id == null) return;
                    setState(() {
                      _selectedWorkplace = _workplaces.firstWhere((w) => w.id == id);
                    });
                    _loadMethods();
                  },
                ),
              ),
            ),
          const SizedBox(height: 24),

          // 인증 방법 목록
          if (_selectedWorkplace == null)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.business, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('근무지를 선택하면 인증 방법을 관리할 수 있습니다',
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
            )
          else if (_loadingMethods)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          else
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 400,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: _methods.length,
                itemBuilder: (context, index) {
                  final method = _methods[index];
                  return _buildMethodCard(method);
                },
              ),
            ),
        ],
      ),
    );
  }

  /// 인증 방법 카드 위젯 (아이콘, 이름, ON/OFF 토글, 설정 미리보기)
  Widget _buildMethodCard(VerificationMethod method) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: method.enabled
              ? const Color(0xFF2DDAA9).withOpacity(0.5)
              : Colors.grey.withOpacity(0.2),
          width: method.enabled ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEditDialog(method),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getMethodIcon(method.methodType),
                    color: method.enabled
                        ? const Color(0xFF2DDAA9)
                        : Colors.grey,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      method.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Switch(
                    value: method.enabled,
                    onChanged: (_) => _toggleMethod(method),
                    activeColor: const Color(0xFF2DDAA9),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                _configPreview(method),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 설정값 미리보기 텍스트
  String _configPreview(VerificationMethod method) {
    final parts = <String>[];
    for (final entry in method.config.entries) {
      parts.add('${_configFieldLabel(entry.key)}: ${entry.value}');
    }
    return parts.join(' | ');
  }
}
