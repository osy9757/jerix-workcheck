import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// NFC 인증 실패 다이얼로그
///
/// 출퇴근 등록 가능한 NFC가 아닐 때 표시.
class NfcCheckFailDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: '출퇴근 등록 가능한 NFC가 아닙니다\n근태 체크 가능한 NFC로 이동하세요',
    );
  }
}
