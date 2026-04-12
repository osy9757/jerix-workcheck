import 'package:flutter/material.dart';
import '../../../../presentation/common_widgets/verification_alert_dialog.dart';

/// 비콘 감지 실패 다이얼로그
///
/// 블루투스 비콘이 감지되지 않을 때 표시.
/// 블루투스 연결 상태를 확인하도록 안내함.
class BeaconUnavailableDialog {
  static Future<void> show(BuildContext context) {
    return VerificationAlertDialog.show(
      context,
      title: '출퇴근 등록 불가',
      message: '비콘이 감지되지 않았습니다\n블루투스 연결 상태를 확인해주세요',
    );
  }
}
