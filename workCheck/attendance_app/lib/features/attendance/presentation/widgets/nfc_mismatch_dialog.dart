import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// NFC 태그 불일치 다이얼로그
///
/// 태그된 NFC가 설정에 등록된 NFC와 다를 때 표시.
/// 등록된 NFC 태그를 사용하도록 안내함.
class NfcMismatchDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: '설정과 다른 NFC가 태그되었습니다\n등록된 NFC 태그를 이용해주세요',
    );
  }
}
