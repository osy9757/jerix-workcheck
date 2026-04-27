import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../../../../presentation/navigation/app_router.dart';
import '../../domain/verification_method.dart';
import '../../domain/verification_result.dart';
import '../../domain/verification_strategy.dart';

/// QR코드 스캔 기반 출퇴근 인증 서비스
///
/// [verify] 호출 시 루트 네비게이터로 `/qr-scan` 화면을 푸시하여
/// QR 스캔 화면을 띄우고, 스캔된 원본 문자열을 결과로 반환한다.
/// 백엔드는 받은 `qr_data` 문자열을 서버 측 설정값과 매칭한다.
@Named('qr')
@LazySingleton(as: VerificationStrategy)
class QrVerificationService implements VerificationStrategy {
  @override
  VerificationMethod get method => VerificationMethod.qr;

  /// QR 스캔은 기기 카메라가 있으면 항상 가능
  @override
  Future<bool> isAvailable() async => true;

  /// 카메라 권한은 mobile_scanner 라이브러리가 내부적으로 처리
  @override
  Future<bool> requestPermissions() async => true;

  /// QR 인증 실행
  ///
  /// 루트 네비게이터로 QR 스캔 화면을 푸시하고, 스캔된 원본 문자열을 받아
  /// VerificationResult로 반환한다. 사용자가 취소하면 실패 결과를 반환한다.
  @override
  Future<VerificationResult> verify() async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'QR 스캔 화면을 띄울 수 없습니다.',
      );
    }

    // QR 스캔 화면을 띄우고 스캔된 원본 문자열을 받는다 (취소 시 null)
    final qrData = await context.push<String>(AppRoutes.qrScan);

    if (qrData == null || qrData.isEmpty) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: 'QR코드 스캔이 취소되었습니다.',
      );
    }

    return VerificationResult(
      method: method,
      isVerified: true,
      data: {
        'qr_data': qrData,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
