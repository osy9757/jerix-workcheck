/// 출퇴근 인증 방법 (5개 단일 method)
///
/// PPT 기반 인증 리팩토링(v2)으로 합성 enum(`gpsQr`/`wifiQr`/`nfcGps`/`beaconGps`)은
/// 폐기되었다. 다중 인증은 서버측 user_verification_methods 다수 활성 + AND 결합으로
/// 표현하며, 앱은 각 단일 method 데이터를 method 키 맵으로 묶어 한 번에 전송한다.
enum VerificationMethod {
  gps('GPS 위치', 'gps'),
  qr('QR코드 스캔', 'qr'),
  nfc('NFC 태그', 'nfc'),
  // 백엔드 MethodType.BEACON 을 'beacon' 키로 송수신
  bluetooth('블루투스 비콘', 'beacon'),
  wifi('WiFi', 'wifi');

  final String label;

  /// 백엔드 API에서 사용하는 이름 (snake_case)
  final String apiName;

  const VerificationMethod(this.label, this.apiName);

  /// 백엔드 API 이름 → enum 변환 (대소문자 무관)
  static VerificationMethod? fromApiName(String name) {
    return switch (name.toLowerCase()) {
      'gps' => VerificationMethod.gps,
      'qr' => VerificationMethod.qr,
      'nfc' => VerificationMethod.nfc,
      'bluetooth' || 'beacon' => VerificationMethod.bluetooth,
      'wifi' => VerificationMethod.wifi,
      _ => null,
    };
  }
}
