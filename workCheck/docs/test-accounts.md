# 테스트 계정 목록

8가지 인증 방법을 모두 테스트할 수 있도록 구성된 테스트 데이터.

- **시드 파일**: `workCheck_backend/src/main/resources/seed.sql`
- **DB**: PostgreSQL (workcheck)
- **주소**: 마포구 마포대로 자람빌딩 (전체 근무지 공통)

---

## 관리자 계정 (웹 로그인)

| username | 비밀번호 | 이름 | 용도 |
|----------|---------|------|------|
| `admin` | `admin1234` | 관리자 | 메인 관리자 |
| `testadmin` | `admin1234` | 테스트관리자 | 추가 관리자 테스트용 |

---

## 직원 계정 (앱 로그인)

**공통**: 회사코드=`CU01`, 비밀번호=`1111`

### 10번대 — GPS

| employee_id | 이름 | 근무지 | 인증 방법 | 설정값 |
|------------|------|--------|----------|--------|
| `11` | GPS테스트 | 본사 | GPS | 반경 200m |
| `12` | GPS_QR테스트 | 강남지점 | GPS + QR | 반경 150m + QR: `WC-GN-QR-001` |

### 20번대 — WiFi

| employee_id | 이름 | 근무지 | 인증 방법 | 설정값 |
|------------|------|--------|----------|--------|
| `21` | WiFi테스트 | 여의도지점 | WiFi | SSID: `WorkCheck-YID`, BSSID: `AA:BB:CC:DD:EE:03` |
| `22` | WiFi_QR테스트 | 판교지점 | WiFi + QR | SSID: `WorkCheck-PG` + QR: `WC-PG-WQ-001` |

### 30번대 — NFC

| employee_id | 이름 | 근무지 | 인증 방법 | 설정값 |
|------------|------|--------|----------|--------|
| `31` | NFC테스트 | 을지로지점 | NFC | 태그 ID: `04:E9:D8:3E:C8:2A:81` |
| `32` | NFC_GPS테스트 | 종로지점 | NFC + GPS | 태그 ID: `04:E9:D8:3E:C8:2A:81` + 반경 100m |

### 40번대 — 비콘

| employee_id | 이름 | 근무지 | 인증 방법 | 설정값 |
|------------|------|--------|----------|--------|
| `41` | 비콘테스트1 | 비콘1 테스트지점 | Beacon | UUID: `C300003F4913`, Major: 40011, Minor: 57342, RSSI: -80 |
| `42` | 비콘테스트2 | 비콘2 테스트지점 | Beacon | UUID: `C300003F3443`, Major: 40011, Minor: 52014, RSSI: -80 |
| `43` | 비콘GPS테스트 | 잠실지점 | Beacon + GPS | UUID: `C300003F4913`, Major: 40011, Minor: 57342, RSSI: -80 + 반경 200m |

### 기존 계정 (본사, GPS 전용)

| employee_id | 이름 | 용도 |
|------------|------|------|
| `1` | 사원D | GPS 출퇴근 테스트 |
| `2` | 사원B | GPS 출퇴근 테스트 |
| `3` | 사원C | GPS 출퇴근 테스트 |
| `4` | 사원A | GPS 출퇴근 테스트 (기본 계정) |

---

## 테스트 시나리오

### GPS (employee_id: 11)
1. 앱 로그인: CU01 / 11 / 1111
2. 출근 → GPS 인증 → 본사 좌표(37.5665, 126.9780) 반경 200m 이내

### GPS + QR (employee_id: 12)
1. 앱 로그인: CU01 / 12 / 1111
2. 출근 → GPS 인증 + QR코드(`WC-GN-QR-001`) 스캔 → 강남지점 반경 150m 이내

### WiFi (employee_id: 21)
1. 앱 로그인: CU01 / 21 / 1111
2. 출근 → WiFi `WorkCheck-YID` (BSSID: `AA:BB:CC:DD:EE:03`) 연결 상태에서 인증

### WiFi + QR (employee_id: 22)
1. 앱 로그인: CU01 / 22 / 1111
2. 출근 → WiFi `WorkCheck-PG` 연결 + QR코드(`WC-PG-WQ-001`) 스캔

### NFC (employee_id: 31)
1. 앱 로그인: CU01 / 31 / 1111
2. 출근 → NFC 태그(`04:E9:D8:3E:C8:2A:81`) 태그

### NFC + GPS (employee_id: 32)
1. 앱 로그인: CU01 / 32 / 1111
2. 출근 → NFC 태그(`04:E9:D8:3E:C8:2A:81`) 태그 + 종로지점 반경 100m 이내

### Beacon 1 (employee_id: 41)
1. 앱 로그인: CU01 / 41 / 1111
2. 출근 → BLE 비콘(UUID: `C300003F4913`, Major: 40011, Minor: 57342) 감지, RSSI ≥ -80

### Beacon 2 (employee_id: 42)
1. 앱 로그인: CU01 / 42 / 1111
2. 출근 → BLE 비콘(UUID: `C300003F3443`, Major: 40011, Minor: 52014) 감지, RSSI ≥ -80

### Beacon + GPS (employee_id: 43)
1. 앱 로그인: CU01 / 43 / 1111
2. 출근 → BLE 비콘(UUID: `C300003F4913`) 감지 + 잠실지점 반경 200m 이내

### 관리자 인증 토글 테스트
1. 웹 로그인: admin / admin1234
2. 본사의 인증 방법 ON/OFF 토글 → 앱에서 변경사항 반영 확인
3. 설정값 수정 (예: GPS 반경 변경) → 앱에서 반영 확인

---

## 인증 방법별 설정값 상세

### GPS
```json
{"radius_meters": 200}
```
좌표는 근무지(workplaces) 테이블에서 참조

### GPS + QR
```json
{"radius_meters": 150, "qr_code": "WC-GN-QR-001"}
```

### WiFi
```json
{"ssid": "WorkCheck-YID", "bssid": "AA:BB:CC:DD:EE:03"}
```

### WiFi + QR
```json
{"ssid": "WorkCheck-PG", "bssid": "AA:BB:CC:DD:EE:04", "qr_code": "WC-PG-WQ-001"}
```

### NFC
```json
{"tag_id": "04:E9:D8:3E:C8:2A:81"}
```
MIFARE 7-byte UID (실제 카드)

### NFC + GPS
```json
{"tag_id": "04:E9:D8:3E:C8:2A:81", "radius_meters": 100}
```

### Beacon 1
```json
{"uuid": "C300003F4913", "major": 40011, "minor": 57342, "rssi_threshold": -80}
```

### Beacon 2
```json
{"uuid": "C300003F3443", "major": 40011, "minor": 52014, "rssi_threshold": -80}
```

### Beacon + GPS
```json
{"uuid": "C300003F4913", "major": 40011, "minor": 57342, "rssi_threshold": -80, "radius_meters": 200}
```
