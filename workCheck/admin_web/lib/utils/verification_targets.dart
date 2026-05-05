/// 멀티 타겟(복수 인증 대상) 신/구 schema 호환 유틸
///
/// - 인증 메서드별 부품(부분 인증 수단) 그룹 정의
/// - row 단위 입력 필드 정의
/// - JSONB config에서 신 schema(`*_targets`/`qr_codes`)/구 schema(단일 dict) 호환 추출
///
/// verification_page.dart / verification_presets_page.dart 양쪽에서 공유.
library;

/// 한 row의 입력 필드 타입
enum ConfigFieldType { int_, double_, string }

/// 한 row의 입력 필드 정의
class ConfigField {
  final String key;
  final String label;
  final String hint;
  final ConfigFieldType type;
  const ConfigField(this.key, this.label, this.hint, this.type);
}

/// 인증 메서드의 부품(부분 인증 수단) 그룹 정의
/// - configKey: 신 schema에서 해당 부품 타겟 배열을 담는 JSONB 키
/// - partType: 'GPS'/'WIFI'/'NFC'/'BEACON' 같은 원자 단위 타입
/// - label: UI에 표시할 한글 라벨
class PartGroup {
  final String partType;
  final String configKey;
  final String label;
  const PartGroup(this.partType, this.configKey, this.label);
}

/// 메서드 → 부품 그룹 리스트 (신 schema 키 매핑)
/// 단독 메서드는 `targets` 배열 1개 그룹.
/// 복합 메서드(NFC_GPS/BEACON_GPS)는 부품별 분리 키.
/// GPS_QR/WIFI_QR은 메인 부품의 `targets` + 별도 `qr_codes`.
/// QR 단독 메서드는 부품 row 없이 `qr_codes`만 사용 → 빈 리스트 반환.
List<PartGroup> partGroupsFor(String methodType) {
  switch (methodType) {
    case 'GPS':
    case 'GPS_QR':
      return const [PartGroup('GPS', 'targets', 'GPS 좌표 대상')];
    case 'WIFI':
    case 'WIFI_QR':
      return const [PartGroup('WIFI', 'targets', 'WiFi 대상')];
    case 'NFC':
      return const [PartGroup('NFC', 'targets', 'NFC 태그 대상')];
    case 'NFC_GPS':
      return const [
        PartGroup('NFC', 'nfc_targets', 'NFC 태그 대상'),
        PartGroup('GPS', 'gps_targets', 'GPS 좌표 대상'),
      ];
    case 'BEACON':
      return const [PartGroup('BEACON', 'targets', 'Beacon 대상')];
    case 'BEACON_GPS':
      return const [
        PartGroup('BEACON', 'beacon_targets', 'Beacon 대상'),
        PartGroup('GPS', 'gps_targets', 'GPS 좌표 대상'),
      ];
    case 'QR':
      // QR 단독: 부품 row 없음 (qr_codes 섹션만 사용)
      return const [];
    default:
      return const [];
  }
}

/// QR 코드 섹션이 있는 메서드인지
/// - GPS_QR / WIFI_QR : 메인 부품 + QR 코드
/// - QR : QR 코드 섹션만 단독 사용
bool hasQrCodesSection(String methodType) =>
    methodType == 'GPS_QR' ||
    methodType == 'WIFI_QR' ||
    methodType == 'QR';

/// 부품 타입(원자) 한글 표시명
String partDisplayNameOf(String partType) {
  switch (partType) {
    case 'GPS':
      return 'GPS';
    case 'WIFI':
      return 'WiFi';
    case 'NFC':
      return 'NFC';
    case 'BEACON':
      return 'Beacon';
    default:
      return partType;
  }
}

/// 한 row(=하나의 타겟)의 입력 필드 정의 — 부품 타입 단위
/// 'NFC_GPS' 같은 복합 메서드는 호출하지 말 것 (대신 partGroupsFor 사용)
List<ConfigField> rowFieldsForPart(String partType) {
  switch (partType) {
    case 'GPS':
    case 'GPS_QR':
      return const [
        ConfigField('latitude', '위도', '예: 37.5665', ConfigFieldType.double_),
        ConfigField('longitude', '경도', '예: 126.9780', ConfigFieldType.double_),
        ConfigField('radius_meters', '반경 (m)', '미터 단위', ConfigFieldType.int_),
      ];
    case 'WIFI':
    case 'WIFI_QR':
      return const [
        ConfigField('ssid', 'WiFi SSID', '네트워크 이름', ConfigFieldType.string),
        ConfigField('bssid', 'WiFi BSSID', 'MAC 주소', ConfigFieldType.string),
      ];
    case 'NFC':
      return const [
        ConfigField('tag_id', 'NFC 태그 ID', '태그 고유 ID', ConfigFieldType.string),
      ];
    case 'BEACON':
      return const [
        ConfigField('uuid', 'Beacon UUID', 'UUID', ConfigFieldType.string),
        ConfigField('major', 'Major', '정수값', ConfigFieldType.int_),
        ConfigField('minor', 'Minor', '정수값', ConfigFieldType.int_),
        ConfigField('rssi_threshold', 'RSSI 임계값', '음수 (예: -70)',
            ConfigFieldType.double_),
      ];
    default:
      return const [];
  }
}

/// 신/구 schema 호환: configKey의 배열이 있으면 그대로, 없으면 단일 dict 폴백.
/// - configKey == 'targets'인 단독 메서드의 단일 dict 폴백은 메서드 config 전체를 1개 target으로 간주.
/// - 복합 메서드 부품 키(`nfc_targets` 등)가 비어있으면 단일 dict에서 해당 부품 필드만 추출.
List<Map<String, dynamic>> extractTargets(
  Map<String, dynamic> config,
  String configKey,
  List<ConfigField> fields,
) {
  final raw = config[configKey];
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
  // 단일 dict 폴백: 해당 부품 필드만 모음
  final flat = <String, dynamic>{};
  for (final f in fields) {
    if (config.containsKey(f.key)) flat[f.key] = config[f.key];
  }
  return flat.isEmpty ? <Map<String, dynamic>>[] : [flat];
}

/// QR 코드 배열 추출 (신 `qr_codes` 우선, 구 `qr_code` 단일값 호환)
List<String> extractQrCodes(Map<String, dynamic> config) {
  final raw = config['qr_codes'];
  if (raw is List) {
    return raw.map((e) => e?.toString() ?? '').toList();
  }
  final single = config['qr_code'];
  if (single is String && single.isNotEmpty) return [single];
  return const [];
}
