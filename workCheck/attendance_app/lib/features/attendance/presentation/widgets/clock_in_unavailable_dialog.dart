import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// 출퇴근 등록 불가 다이얼로그
///
/// GPS 위치가 허용 범위 밖일 때 표시.
/// 사용자가 근태 체크 가능한 위치로 이동하도록 안내함.
class ClockInUnavailableDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: '출퇴근 등록 가능한 위치가 아닙니다\n근태 체크 가능한 GPS 위치로 이동하세요',
    );
  }
}
