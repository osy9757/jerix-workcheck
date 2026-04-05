import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../presentation/navigation/app_router.dart';
import '../../../attendance/presentation/widgets/nfc_mismatch_dialog.dart';
import '../../../attendance/presentation/widgets/nfc_tag_dialog.dart';
import '../../../attendance/presentation/widgets/nfc_unavailable_dialog.dart';
import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

@Named('nfc')
@LazySingleton(as: VerificationStrategy)
class NfcVerificationService implements VerificationStrategy {
  /// 서버에 등록된 기대 태그 ID (Bloc에서 인증 전에 설정)
  String? expectedTagId;

  @override
  VerificationMethod get method => VerificationMethod.nfc;

  @override
  Future<bool> isAvailable() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  @override
  Future<bool> requestPermissions() async => true; // NFC는 별도 권한 불필요

  @override
  Future<VerificationResult> verify() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'NFC 인증 화면을 표시할 수 없습니다.',
      );
    }

    // NFC 사용 가능 여부 확인
    final availability = await NfcManager.instance.checkAvailability();
    if (availability != NfcAvailability.enabled) {
      await NfcUnavailableDialog.show(context);
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'NFC를 사용할 수 없습니다.',
      );
    }

    // NFC 태그 스캔 다이얼로그 표시
    final tagId = await NfcTagDialog.show(context);

    // 사용자 취소 또는 스캔 실패
    if (tagId == null || tagId == 'unknown') {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'NFC 태그를 인식하지 못했습니다.',
      );
    }

    // 로컬 태그 ID 비교 (설정값이 있을 경우)
    if (expectedTagId != null && tagId != expectedTagId) {
      await NfcMismatchDialog.show(context);
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '등록된 NFC 태그와 일치하지 않습니다.',
      );
    }

    // 스캔 성공
    return VerificationResult(
      method: method,
      isVerified: true,
      data: {
        'tag_id': tagId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
