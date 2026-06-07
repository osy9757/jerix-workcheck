import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// 기기 승인 관리 페이지 (기기 바인딩 — 계획 A ④Admin)
/// - 기기 요청 목록 조회 + 상태 필터
/// - PENDING 행에 승인/거부 버튼, 액션 후 새로고침
/// - employees_page 패턴 미러 (DataTable + 로딩/에러)
class DeviceRequestsPage extends StatefulWidget {
  final ApiService apiService;
  const DeviceRequestsPage({super.key, required this.apiService});

  @override
  State<DeviceRequestsPage> createState() => _DeviceRequestsPageState();
}

class _DeviceRequestsPageState extends State<DeviceRequestsPage> {
  List<DeviceRequest> _devices = []; // 기기 요청 목록
  bool _loading = true; // 로딩 상태
  String? _error; // 에러 메시지
  String _statusFilter = ''; // 상태 필터 ('' = 전체)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// 기기 요청 목록 로드 (현재 필터 적용)
  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devices = await widget.apiService.getDeviceRequests(
        status: _statusFilter.isEmpty ? null : _statusFilter,
      );
      if (mounted) {
        setState(() {
          _devices = devices;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '기기 요청 목록을 불러올 수 없습니다';
          _loading = false;
        });
      }
    }
  }

  /// 기기 승인 처리 (성공 시 새로고침)
  Future<void> _approve(int id) async {
    try {
      await widget.apiService.approveDevice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기를 승인했습니다')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('승인에 실패했습니다')),
        );
      }
    }
  }

  /// 기기 거부 처리 (성공 시 새로고침)
  Future<void> _reject(int id) async {
    try {
      await widget.apiService.rejectDevice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기를 거부했습니다')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('거부에 실패했습니다')),
        );
      }
    }
  }

  /// 기기 바인딩 삭제 처리 (확인 다이얼로그 후 실행, 성공 시 새로고침)
  /// - 모든 상태(APPROVED/PENDING/REJECTED) 행에서 호출 가능
  Future<void> _delete(int id) async {
    // 삭제 확인 다이얼로그
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('기기 바인딩 삭제'),
        content: const Text('이 기기 바인딩을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await widget.apiService.deleteDevice(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('기기 바인딩을 삭제했습니다')),
        );
      }
      _loadData();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('삭제에 실패했습니다')),
        );
      }
    }
  }

  /// 상태 칩 (색상으로 PENDING/APPROVED/REJECTED 구분)
  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'APPROVED':
        color = const Color(0xFF2DDAA9);
        label = '승인';
        break;
      case 'REJECTED':
        color = Colors.red;
        label = '거부';
        break;
      case 'PENDING':
      default:
        color = Colors.orange;
        label = '대기';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
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
                '기기 승인',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              // 상태 필터 드롭다운
              DropdownButton<String>(
                value: _statusFilter,
                items: const [
                  DropdownMenuItem(value: '', child: Text('전체')),
                  DropdownMenuItem(value: 'PENDING', child: Text('대기')),
                  DropdownMenuItem(value: 'APPROVED', child: Text('승인')),
                  DropdownMenuItem(value: 'REJECTED', child: Text('거부')),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _statusFilter = value);
                  _loadData();
                },
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: _loadData,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '직원의 새 기기 로그인 요청을 승인/거부합니다. 승인 시 기존 기기는 자동 교체됩니다.',
            style: TextStyle(color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_error != null)
            Center(
                child:
                    Text(_error!, style: const TextStyle(color: Colors.red)))
          else if (_devices.isEmpty)
            const Center(child: Text('기기 요청이 없습니다'))
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
                        DataColumn(label: Text('사번')),
                        DataColumn(label: Text('이름')),
                        DataColumn(label: Text('기기 ID')),
                        DataColumn(label: Text('상태')),
                        DataColumn(label: Text('요청일')),
                        DataColumn(label: Text('액션')),
                      ],
                      rows: _devices.map((dev) {
                        final requested = dev.requestedAt.isEmpty
                            ? '-'
                            : dev.requestedAt.substring(
                                0,
                                dev.requestedAt.length >= 10
                                    ? 10
                                    : dev.requestedAt.length);
                        final isPending = dev.status == 'PENDING';
                        return DataRow(cells: [
                          DataCell(Text(dev.employeeId)),
                          DataCell(Text(dev.name)),
                          // 기기 ID는 길어서 말줄임 + 툴팁
                          DataCell(
                            Tooltip(
                              message: dev.deviceId,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 180),
                                child: Text(
                                  dev.deviceId,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                          DataCell(_statusChip(dev.status)),
                          DataCell(Text(requested)),
                          DataCell(
                            // PENDING 행: 승인/거부 + 삭제, 그 외: 삭제만
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // 승인/거부는 PENDING 행에서만 노출
                                if (isPending) ...[
                                  ElevatedButton(
                                    onPressed: () => _approve(dev.id),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2DDAA9),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      minimumSize: const Size(0, 36),
                                    ),
                                    child: const Text('승인'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () => _reject(dev.id),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      side:
                                          const BorderSide(color: Colors.red),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      minimumSize: const Size(0, 36),
                                    ),
                                    child: const Text('거부'),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                // 삭제는 모든 상태 행에서 노출 (빨강)
                                ElevatedButton(
                                  onPressed: () => _delete(dev.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    minimumSize: const Size(0, 36),
                                  ),
                                  child: const Text('삭제'),
                                ),
                              ],
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
