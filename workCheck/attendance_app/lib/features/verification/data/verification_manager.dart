import 'package:injectable/injectable.dart';

import '../domain/verification_method.dart';
import '../domain/verification_result.dart';
import '../domain/verification_strategy.dart';

/// 인증 방식 레지스트리 + 실행기
///
/// v2 리팩토링으로 합성 인증(GPS_QR/WIFI_QR/NFC_GPS/BEACON_GPS) 개념은 제거되었다.
/// 다중 method 결합은 BLoC 레이어에서 init 응답의 required_methods를 순회하며
/// 각 단일 strategy를 호출해 결과를 method 키 맵으로 묶는 방식으로 처리한다.
@lazySingleton
class VerificationManager {
  final Map<VerificationMethod, VerificationStrategy> _strategies;

  VerificationManager({
    @Named('gps') required VerificationStrategy gps,
    @Named('qr') required VerificationStrategy qr,
    @Named('nfc') required VerificationStrategy nfc,
    @Named('bluetooth') required VerificationStrategy bluetooth,
    @Named('wifi') required VerificationStrategy wifi,
  }) : _strategies = {
          VerificationMethod.gps: gps,
          VerificationMethod.qr: qr,
          VerificationMethod.nfc: nfc,
          VerificationMethod.bluetooth: bluetooth,
          VerificationMethod.wifi: wifi,
        };

  /// 단일 인증 실행
  Future<VerificationResult> verify(VerificationMethod method) async {
    final strategy = _strategies[method];
    if (strategy == null) {
      return VerificationResult(
        method: method,
        isVerified: false,
        data: {},
        errorMessage: '지원하지 않는 인증 방식입니다.',
      );
    }
    return strategy.verify();
  }

  /// 현재 사용 가능한 단일 인증 방식 목록
  Future<List<VerificationMethod>> getAvailableMethods() async {
    final available = <VerificationMethod>[];
    for (final entry in _strategies.entries) {
      if (await entry.value.isAvailable()) {
        available.add(entry.key);
      }
    }
    return available;
  }

  /// 특정 방식의 Strategy 반환 (QR 스캐너 UI 등에서 직접 접근 필요 시)
  VerificationStrategy? getStrategy(VerificationMethod method) {
    return _strategies[method];
  }
}
