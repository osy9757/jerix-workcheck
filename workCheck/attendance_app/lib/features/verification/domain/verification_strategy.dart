import 'verification_result.dart';
import 'verification_method.dart';

/// 출퇴근 인증 방식 Strategy 인터페이스
///
/// 모든 인증 방식(GPS, QR, NFC, Bluetooth, WiFi)은
/// 이 인터페이스를 구현하여 동일한 방식으로 호출됨.
abstract class VerificationStrategy {
  VerificationMethod get method;

  /// 해당 인증 방식이 현재 기기에서 사용 가능한지 확인
  Future<bool> isAvailable();

  /// 인증 실행 → 결과 반환
  Future<VerificationResult> verify();

  /// 필요한 권한 요청
  Future<bool> requestPermissions();
}
