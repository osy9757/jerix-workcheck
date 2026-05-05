import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// 근무지 관리 페이지 - CRUD + 위치 정보
class WorkplacesPage extends StatefulWidget {
  final ApiService apiService;
  const WorkplacesPage({super.key, required this.apiService});

  @override
  State<WorkplacesPage> createState() => _WorkplacesPageState();
}

class _WorkplacesPageState extends State<WorkplacesPage> {
  List<Workplace> _workplaces = []; // 근무지 목록
  bool _loading = true; // 로딩 상태
  String? _error; // 에러 메시지

  @override
  void initState() {
    super.initState();
    _loadWorkplaces();
  }

  /// 근무지 목록 API 호출 및 상태 업데이트
  Future<void> _loadWorkplaces() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final workplaces = await widget.apiService.getWorkplaces();
      if (mounted) setState(() { _workplaces = workplaces; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '근무지 목록을 불러올 수 없습니다'; _loading = false; });
    }
  }

  /// 근무지 추가/수정 다이얼로그
  void _showEditDialog({Workplace? workplace}) {
    final nameCtrl = TextEditingController(text: workplace?.name ?? '');
    final addressCtrl = TextEditingController(text: workplace?.address ?? '');
    final latCtrl = TextEditingController(
      text: workplace?.latitude?.toString() ?? '',
    );
    final lngCtrl = TextEditingController(
      text: workplace?.longitude?.toString() ?? '',
    );
    final isEdit = workplace != null;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? '근무지 수정' : '근무지 추가'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: '근무지 이름',
                    border: OutlineInputBorder(),
                    hintText: '예: 본사, 강남지사',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(
                    labelText: '주소 (선택)',
                    border: OutlineInputBorder(),
                    hintText: '예: 서울시 강남구...',
                  ),
                ),
                const SizedBox(height: 16),
                // 위치 정보 섹션
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('위치 정보 (선택)',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '위도',
                          border: OutlineInputBorder(),
                          helperText: '예: 37.5665',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lngCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: '경도',
                          border: OutlineInputBorder(),
                          helperText: '예: 126.9780',
                        ),
                      ),
                    ),
                  ],
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
              if (nameCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('근무지 이름을 입력하세요')),
                );
                return;
              }
              // 위도/경도 파싱
              final lat = double.tryParse(latCtrl.text.trim());
              final lng = double.tryParse(lngCtrl.text.trim());
              try {
                final address = addressCtrl.text.trim().isEmpty
                    ? null
                    : addressCtrl.text.trim();
                if (isEdit) {
                  await widget.apiService.updateWorkplace(
                    workplace.id, nameCtrl.text.trim(), address,
                    latitude: lat, longitude: lng,
                  );
                } else {
                  await widget.apiService.createWorkplace(
                    nameCtrl.text.trim(), address,
                    latitude: lat, longitude: lng,
                  );
                }
                if (ctx.mounted) Navigator.pop(ctx);
                _loadWorkplaces();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isEdit ? '근무지가 수정되었습니다' : '근무지가 추가되었습니다')),
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
            child: Text(isEdit ? '수정' : '추가'),
          ),
        ],
      ),
    );
  }

  /// 근무지 삭제 확인
  void _confirmDelete(Workplace workplace) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('근무지 삭제'),
        content: Text('"${workplace.name}" 근무지를 삭제하시겠습니까?\n배정된 직원의 근무지가 해제됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await widget.apiService.deleteWorkplace(workplace.id);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadWorkplaces();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('근무지가 삭제되었습니다')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('삭제에 실패했습니다')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }

  /// 위치 정보 표시 텍스트
  String _locationText(Workplace wp) {
    if (wp.latitude != null && wp.longitude != null) {
      return '${wp.latitude!.toStringAsFixed(4)}, ${wp.longitude!.toStringAsFixed(4)}';
    }
    return '-';
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
                '근무지 관리',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_business),
                label: const Text('근무지 추가'),
                onPressed: () => _showEditDialog(),
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
                        DataColumn(label: Text('이름')),
                        DataColumn(label: Text('주소')),
                        DataColumn(label: Text('위치')),
                        DataColumn(label: Text('관리')),
                      ],
                      rows: _workplaces.map((wp) {
                        return DataRow(cells: [
                          DataCell(Text('${wp.id}')),
                          DataCell(Text(wp.name)),
                          DataCell(Text(wp.address ?? '-')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (wp.latitude != null)
                                  const Icon(Icons.location_on,
                                    size: 16, color: Color(0xFF2DDAA9)),
                                const SizedBox(width: 4),
                                Text(_locationText(wp),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: wp.latitude != null ? null : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          DataCell(Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 20),
                                tooltip: '수정',
                                onPressed: () => _showEditDialog(workplace: wp),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                tooltip: '삭제',
                                onPressed: () => _confirmDelete(wp),
                              ),
                            ],
                          )),
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
