/// 멀티 타겟 신 schema 호환 유틸 (api_contract v2 — 5-enum, AND 결합)
///
/// - 메서드별 부품(부분 인증 수단) 그룹 정의 (5-enum 만)
/// - row 단위 입력 필드 정의
/// - JSONB config에서 `targets[]` / QR `codes[]` 추출
/// - WiFi identifier_type 라디오 헬퍼 (BSSID/IP)
///
/// 필드 키는 백엔드 v2 명세를 그대로 사용:
///   GPS    : lat / lng / radius_m
///   WIFI   : ssid + identifier_type(bssid|ip) + identifier_value
///   NFC    : tag_id
///   BEACON : uuid / major / minor / distance_m / tx_power   (서버가 rssi_threshold 자동 계산)
///   QR     : codes[]  (root 'codes' 배열)
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

/// 인증 메서드의 부품 그룹 정의 (5-enum 시대에는 항상 1개)
class PartGroup {
  final String partType;
  final String configKey;
  final String label;
  const PartGroup(this.partType, this.configKey, this.label);
}

/// 5-Primitive 토글 식별자 (UI 순서)
const List<String> kPrimitives = ['GPS', 'WIFI', 'NFC', 'BEACON', 'QR'];

/// 메서드 → 부품 그룹 (v2: 5-enum 만 지원, 항상 1 그룹 또는 빈 리스트)
/// - QR은 부품 row 없음 (codes 섹션 단독 사용)
List<PartGroup> partGroupsFor(String methodType) {
  switch (methodType.toUpperCase()) {
    case 'GPS':
      return const [PartGroup('GPS', 'targets', 'GPS 좌표 대상')];
    case 'WIFI':
      return const [PartGroup('WIFI', 'targets', 'WiFi 대상')];
    case 'NFC':
      return const [PartGroup('NFC', 'targets', 'NFC 태그 대상')];
    case 'BEACON':
      return const [PartGroup('BEACON', 'targets', 'Beacon 대상')];
    case 'QR':
      return const [];
    default:
      return const [];
  }
}

/// QR 코드 섹션이 있는 메서드인지 (v2: QR 만)
bool hasQrCodesSection(String methodType) =>
    methodType.toUpperCase() == 'QR';

/// 부품 타입 한글 표시명
String partDisplayNameOf(String partType) {
  switch (partType.toUpperCase()) {
    case 'GPS':
      return 'GPS';
    case 'WIFI':
      return 'WiFi';
    case 'NFC':
      return 'NFC';
    case 'BEACON':
      return 'Beacon';
    case 'QR':
      return 'QR';
    default:
      return partType;
  }
}

/// 한 row(=하나의 타겟)의 입력 필드 정의 (v2 명세)
/// - WIFI는 평면 필드(ssid + identifier_value)만 노출. identifier_type 라디오는 UI 측에서 별도 처리.
/// - BEACON은 distance_m + tx_power. rssi_threshold는 서버 자동 계산이라 입력 X.
List<ConfigField> rowFieldsForPart(String partType) {
  switch (partType.toUpperCase()) {
    case 'GPS':
      return const [
        ConfigField('lat', '위도', '예: 37.5665', ConfigFieldType.double_),
        ConfigField('lng', '경도', '예: 126.9780', ConfigFieldType.double_),
        ConfigField('radius_m', '반경 (m)', '미터 단위', ConfigFieldType.int_),
      ];
    case 'WIFI':
      // identifier_type(bssid|ip) + identifier_value 는 라디오 UI(verification_page) 또는
      // 평면(prests)에서 별도 표시. 여기서는 SSID + identifier_value 만 generic 필드로.
      return const [
        ConfigField('ssid', 'WiFi SSID', '네트워크 이름', ConfigFieldType.string),
        ConfigField('identifier_value', '식별자 값', 'BSSID(MAC) 또는 IP',
            ConfigFieldType.string),
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
        ConfigField('distance_m', '거리 (m)', '예: 2.0', ConfigFieldType.double_),
        ConfigField(
            'tx_power', 'TxPower (dBm)', '예: -59', ConfigFieldType.double_),
      ];
    default:
      return const [];
  }
}

/// configKey의 배열에서 타겟 row들을 추출 (단일 dict 폴백 포함)
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
  // 단일 dict 폴백 (구버전 호환): 해당 부품 필드만 모음
  final flat = <String, dynamic>{};
  for (final f in fields) {
    if (config.containsKey(f.key)) flat[f.key] = config[f.key];
  }
  return flat.isEmpty ? <Map<String, dynamic>>[] : [flat];
}

/// QR 코드 배열 추출 (v2: `codes` 우선, 구 `qr_codes`/`qr_code` 호환)
List<String> extractQrCodes(Map<String, dynamic> config) {
  final raw = config['codes'];
  if (raw is List) {
    return raw.map((e) => e?.toString() ?? '').toList();
  }
  // 구버전 호환
  final legacyArr = config['qr_codes'];
  if (legacyArr is List) {
    return legacyArr.map((e) => e?.toString() ?? '').toList();
  }
  final single = config['qr_code'];
  if (single is String && single.isNotEmpty) return [single];
  return const [];
}

// =====================================================================
// WiFi identifier (bssid/ip 라디오) 헬퍼
// =====================================================================

/// WiFi row 한 개의 identifier_type 추출 ('bssid' 기본).
/// - v2 명세: identifier_type ∈ {'bssid', 'ip'} (소문자)
/// - 구버전 호환: 명시되지 않았으면 'bssid' 기본
String wifiIdentifierTypeOf(Map<String, dynamic> row) {
  final t = (row['identifier_type'] ?? '').toString().toLowerCase();
  if (t == 'ip') return 'ip';
  if (t == 'bssid') return 'bssid';
  // 구버전 호환: bssid 필드만 있으면 'bssid', ip 필드만 있으면 'ip'
  final hasIp = (row['ip'] ?? '').toString().trim().isNotEmpty;
  final hasBssid = (row['bssid'] ?? '').toString().trim().isNotEmpty;
  if (hasIp && !hasBssid) return 'ip';
  return 'bssid';
}
