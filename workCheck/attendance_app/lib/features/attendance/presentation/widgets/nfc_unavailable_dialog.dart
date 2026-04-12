import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// NFC 태그 미감지 다이얼로그
///
/// NFC 태그가 감지되지 않을 때 표시.
/// 사용자가 NFC 태그를 다시 시도하도록 안내함.
class NfcUnavailableDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: 'NFC가 태그되지 않았습니다\nNFC 태그를 다시 시도해주세요',
    );
  }
}
