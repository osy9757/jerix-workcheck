/// 출퇴근 인증 방법 (단일 5개 + 복합 4개)
enum VerificationMethod {
  // 단일 인증
  gps('GPS 위치', 'gps'),
  qr('QR코드 스캔', 'qr'),
  nfc('NFC 태그', 'nfc'),
  bluetooth('블루투스 비콘', 'bluetooth'),
  wifi('WiFi', 'wifi'),
  // 복합 인증
  gpsQr('GPS + QR코드', 'gps_qr'),
  wifiQr('WiFi + QR코드', 'wifi_qr'),
  nfcGps('NFC + GPS', 'nfc_gps'),
  beaconGps('비콘 + GPS', 'beacon_gps');

  final String label;

  /// 백엔드 API에서 사용하는 이름 (snake_case)
  final String apiName;

  const VerificationMethod(this.label, this.apiName);

  /// 복합 인증 여부
  bool get isComposite => [gpsQr, wifiQr, nfcGps, beaconGps].contains(this);

  /// 복합 인증의 구성 요소 반환 (단일 인증은 자기 자신을 반환)
  List<VerificationMethod> get components => switch (this) {
        gpsQr => [gps, qr],
        wifiQr => [wifi, qr],
        nfcGps => [nfc, gps],
        beaconGps => [bluetooth, gps],
        _ => [this],
      };

  /// 백엔드 API 이름 → enum 변환
  static VerificationMethod? fromApiName(String name) {
    return switch (name.toLowerCase()) {
      'gps' => VerificationMethod.gps,
      'qr' => VerificationMethod.qr,
      'nfc' => VerificationMethod.nfc,
      'bluetooth' || 'beacon' => VerificationMethod.bluetooth,
      'wifi' => VerificationMethod.wifi,
      'gps_qr' => VerificationMethod.gpsQr,
      'wifi_qr' => VerificationMethod.wifiQr,
      'nfc_gps' => VerificationMethod.nfcGps,
      'beacon_gps' => VerificationMethod.beaconGps,
      _ => null,
    };
  }
}
