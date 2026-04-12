import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// 비콘 불일치 다이얼로그
///
/// 감지된 비콘이 설정에 등록된 비콘과 다를 때 표시.
/// 등록된 비콘 범위 내로 이동하도록 안내함.
class BeaconMismatchDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: '설정과 다른 비콘이 연결되었습니다\n등록된 비콘 범위 내로 이동하세요',
    );
  }
}
