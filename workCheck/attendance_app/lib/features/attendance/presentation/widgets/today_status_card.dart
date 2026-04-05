import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/today_status_entity.dart';

/// 오늘의 출근/퇴근 시간을 카드 형태로 표시하는 위젯
class TodayStatusCard extends StatelessWidget {
  /// 오늘의 출퇴근 상태 (null이면 미조회 상태)
  final TodayStatusEntity? status;

  const TodayStatusCard({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // 출근 시간 영역
            Expanded(
              child: _StatusItem(
                icon: Icons.login,
                label: '출근',
                time: status?.clockIn?.timestamp,
                method: status?.clockIn?.verificationMethod.label,
                color: Colors.green,
              ),
            ),
            // 구분선
            Container(
              width: 1,
              height: 60,
              color: Colors.grey.shade200,
            ),
            // 퇴근 시간 영역
            Expanded(
              child: _StatusItem(
                icon: Icons.logout,
                label: '퇴근',
                time: status?.clockOut?.timestamp,
                method: status?.clockOut?.verificationMethod.label,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 출근 또는 퇴근 단일 항목 위젯
class _StatusItem extends StatelessWidget {
  final IconData icon;
  final String label;

  /// 기록된 시간 (null이면 미기록)
  final DateTime? time;

  /// 인증 방법 레이블 (예: GPS, QR 등)
  final String? method;

  final Color color;

  const _StatusItem({
    required this.icon,
    required this.label,
    this.time,
    this.method,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    // 시간이 기록되었는지 여부
    final isRecorded = time != null;

    return Column(
      children: [
        // 기록 여부에 따라 아이콘 색상 변경
        Icon(icon, color: isRecorded ? color : Colors.grey.shade300, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        // 기록된 경우 HH:mm 포맷으로 시간 표시, 없으면 '--:--'
        Text(
          isRecorded ? DateFormat('HH:mm').format(time!) : '--:--',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isRecorded ? null : Colors.grey.shade300,
          ),
        ),
        // 인증 방법이 있으면 하단에 소자 표시
        if (method != null) ...[
          const SizedBox(height: 2),
          Text(
            method!,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
          ),
        ],
      ],
    );
  }
}
