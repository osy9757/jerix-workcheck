import 'package:injectable/injectable.dart';
import 'package:nfc_manager/nfc_manager.dart';

import '../../../../presentation/navigation/app_router.dart';
import '../../../attendance/presentation/widgets/nfc_tag_dialog.dart';
import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// NFC 태그 기반 출퇴근 인증 서비스
///
/// NFC 태그의 UID를 읽어 서버에 등록된 태그와 일치 여부를 확인한다.
/// 태그 스캔은 다이얼로그(NfcTagDialog)를 통해 사용자에게 안내하며,
/// 로컬에서 먼저 expectedTagIds(다중)와 비교 후 서버로 전송한다.
@Named('nfc')
@LazySingleton(as: VerificationStrategy)
class NfcVerificationService implements VerificationStrategy {
  /// 서버에 등록된 기대 태그 ID 목록 (Bloc에서 인증 전에 설정, OR 매칭)
  /// 빈 리스트이면 사전 비교를 생략하고 서버 매칭에 위임한다.
  List<String> expectedTagIds = const [];

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
  /// NFC 비활성화 → 안내 다이얼로그 → 태그 스캔 다이얼로그 → 로컬 태그 비교 순서로 진행.
  /// expectedTagIds가 비어있지 않으면 로컬에서 먼저 OR 매칭으로 불일치를 걸러내어
  /// 불필요한 서버 요청을 방지한다 (대소문자 무시).
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

    // 로컬 태그 ID 비교 (기대 목록이 있을 때만, 대소문자 무시 OR 매칭)
    if (expectedTagIds.isNotEmpty) {
      final tagIdLower = tagId.toLowerCase();
      final matched =
          expectedTagIds.any((t) => t.toLowerCase() == tagIdLower);
      if (!matched) {
        return VerificationResult(
          method: method,
          isVerified: false,
          data: {},
          errorMessage: '등록된 NFC 태그와 일치하지 않습니다.',
        );
      }
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
