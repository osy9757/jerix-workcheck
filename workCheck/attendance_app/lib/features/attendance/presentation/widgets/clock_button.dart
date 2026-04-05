import 'package:flutter/material.dart';

import '../../domain/entities/today_status_entity.dart';

/// 출근/퇴근 버튼 위젯
///
/// 현재 출퇴근 상태에 따라 버튼 텍스트와 색상이 변경됨.
/// - 완료 상태: 회색 비활성
/// - 출근 중: 주황색 (퇴근 버튼)
/// - 미출근: 테마 기본색 (출근 버튼)
class ClockButton extends StatelessWidget {
  /// 오늘의 출퇴근 상태 (null이면 미조회 상태)
  final TodayStatusEntity? todayStatus;

  /// 처리 중 여부 (로딩 스피너 표시)
  final bool isProcessing;

  /// 처리 중일 때 표시할 레이블
  final String processingLabel;

  /// 버튼 클릭 콜백
  final VoidCallback onPressed;

  const ClockButton({
    super.key,
    required this.todayStatus,
    required this.isProcessing,
    required this.processingLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // 오늘 출퇴근이 모두 완료되었는지 여부
    final isCompleted = todayStatus?.isCompleted ?? false;
    // 다음 수행할 액션 (출근 또는 퇴근)
    final nextAction = todayStatus?.nextAction;
    // 현재 출근 상태인지 여부
    final isClockedIn = todayStatus?.isClockedIn ?? false;

    return SizedBox(
      width: double.infinity,
      height: 64,
      child: ElevatedButton(
        // 완료 상태이거나 처리 중이면 버튼 비활성화
        onPressed: isCompleted || isProcessing ? null : onPressed,
        style: ElevatedButton.styleFrom(
          // 완료: 회색 / 출근 중: 주황 / 미출근: 기본 테마색
          backgroundColor: isCompleted
              ? Colors.grey
              : isClockedIn
                  ? Colors.orange
                  : Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // 처리 중에는 elevation 제거
          elevation: isProcessing ? 0 : 2,
        ),
        child: isProcessing
            // 처리 중: 스피너 + 레이블
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    processingLabel,
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              )
            // 대기 중: 상태에 따른 텍스트
            : Text(
                isCompleted
                    ? '오늘 출퇴근 완료'
                    : '${nextAction ?? "출근"} 하기',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
