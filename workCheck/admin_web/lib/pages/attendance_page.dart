import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/models.dart';

/// 출퇴근 기록 조회 페이지
class AttendancePage extends StatefulWidget {
  final ApiService apiService;
  const AttendancePage({super.key, required this.apiService});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<AttendanceRecord> _records = []; // 출퇴근 기록 목록
  bool _loading = false; // 로딩 상태
  String? _error; // 에러 메시지

  // 조회 날짜 범위 (기본: 최근 7일)
  late DateTime _fromDate;
  late DateTime _toDate;

  @override
  void initState() {
    super.initState();
    _toDate = DateTime.now();
    _fromDate = _toDate.subtract(const Duration(days: 7));
    _loadRecords();
  }

  /// 날짜 범위에 해당하는 출퇴근 기록 로드
  Future<void> _loadRecords() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final dateFormat = DateFormat('yyyy-MM-dd');
    try {
      final records = await widget.apiService.getAttendanceHistory(
        dateFormat.format(_fromDate),
        dateFormat.format(_toDate),
      );
      if (mounted) setState(() { _records = records; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = '기록을 불러올 수 없습니다'; _loading = false; });
    }
  }

  /// 날짜 선택
  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2DDAA9),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _fromDate = picked.start;
        _toDate = picked.end;
      });
      _loadRecords();
    }
  }

  /// 시간 포맷 (타임스탬프 → HH:mm)
  String _formatTime(String? timestamp) {
    if (timestamp == null) return '-';
    try {
      final dt = DateTime.parse(timestamp);
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '출퇴근 기록',
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 날짜 범위 선택
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  '${dateFormat.format(_fromDate)} ~ ${dateFormat.format(_toDate)}',
                ),
                onPressed: _selectDateRange,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: '새로고침',
                onPressed: _loadRecords,
              ),
              const Spacer(),
              Text(
                '총 ${_records.length}건',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 테이블
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
                        DataColumn(label: Text('날짜')),
                        DataColumn(label: Text('직원명')),
                        DataColumn(label: Text('출근 시간')),
                        DataColumn(label: Text('퇴근 시간')),
                        DataColumn(label: Text('출근 인증')),
                        DataColumn(label: Text('퇴근 인증')),
                        DataColumn(label: Text('상태')),
                      ],
                      rows: _records.map((record) {
                        final status = _getStatus(record);
                        return DataRow(cells: [
                          DataCell(Text(record.date)),
                          DataCell(Text(record.employeeName ?? '-')),
                          DataCell(Text(_formatTime(record.clockIn?.timestamp))),
                          DataCell(Text(_formatTime(record.clockOut?.timestamp))),
                          DataCell(Text(record.clockIn?.verificationMethod ?? '-')),
                          DataCell(Text(record.clockOut?.verificationMethod ?? '-')),
                          DataCell(_buildStatusChip(status)),
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

  /// 출퇴근 상태 판정
  String _getStatus(AttendanceRecord record) {
    if (record.clockIn != null && record.clockOut != null) return '정상';
    if (record.clockIn != null && record.clockOut == null) return '퇴근 미등록';
    return '미출근';
  }

  /// 출퇴근 상태 칩 위젯 (정상/퇴근 미등록/미출근)
  Widget _buildStatusChip(String status) {
    Color color;
    switch (status) {
      case '정상':
        color = const Color(0xFF2DDAA9);
        break;
      case '퇴근 미등록':
        color = Colors.orange;
        break;
      default:
        color = Colors.red;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
