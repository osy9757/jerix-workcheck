import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../presentation/navigation/app_router.dart';
import '../../../attendance/presentation/widgets/nfc_tag_dialog.dart';
import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// NFC 태그 기반 출퇴근 인증 서비스
///
/// NFC 태그의 UID를 읽어 서버로 전송한다. 등록된 태그와의 일치 여부 판정은
/// 서버(`VerificationService`)에서 수행한다. 클라이언트는 디바이스 가용성과
/// 스캔 결과 수집만 담당한다.
@Named('nfc')
@LazySingleton(as: VerificationStrategy)
class NfcVerificationService implements VerificationStrategy {
  @override
  VerificationMethod get method => VerificationMethod.nfc;

  /// 기기의 NFC 하드웨어가 활성화되어 있는지 확인
  @override
  Future<bool> isAvailable() async {
    final availability = await NfcManager.instance.checkAvailability();
    return availability == NfcAvailability.enabled;
  }

  /// NFC는 OS 수준에서 관리되므로 별도 런타임 권한이 불필요
  @override
  Future<bool> requestPermissions() async => true; // NFC는 별도 권한 불필요

  /// NFC 인증 실행
  ///
  /// NFC 비활성화 → 안내 다이얼로그 → 태그 스캔 다이얼로그 → 결과 반환 순서로 진행.
  /// 등록된 태그와의 일치 여부는 서버에서 판정하므로 클라이언트는 스캔된
  /// tag_id를 그대로 verification_data에 담아 반환한다.
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

    // 스캔 성공 → 서버 검증으로 위임
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
