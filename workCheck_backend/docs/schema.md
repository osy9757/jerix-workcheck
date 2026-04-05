# DB Schema - workCheck MVP

## ERD 개요

```
companies (1) ──< (N) users
companies (1) ──< (N) admin_users
companies (1) ──< (N) verification_methods (1) ──< (N) verification_configs
users     (1) ──< (N) attendance_records
verification_methods (1) ──< (N) attendance_records
```

## Flutter 앱 호환성

앱의 기존 모델과 DB 매핑:

| Flutter (앱) | DB (PostgreSQL) | 비고 |
|---|---|---|
| `VerificationMethod` enum (gps, qr, nfc, bluetooth, wifi) | `method_type` ENUM (8가지) | DB는 복합 방법 포함 |
| `AttendanceType` enum (clockIn, clockOut) | `attendance_type` ENUM (CLOCK_IN, CLOCK_OUT) | 앱은 camelCase, API는 UPPER_SNAKE |
| `AttendanceModel.verification_data` (Map) | `attendance_records.verification_data` (JSONB) | 동일 구조 |
| `RegisterAttendanceRequest` | POST body → `attendance_records` row | type + verification_method + verification_data |
| `TodayStatusModel` (clock_in, clock_out) | 당일 attendance_records 조회 | API에서 조합 |

## 테이블 설명

### 1. companies (회사)

MVP에서는 단일 회사. 회사 코드(`code`)로 앱 로그인 시 회사 식별.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| name | VARCHAR(100) | 회사명 |
| code | VARCHAR(20) UNIQUE | 회사 코드 (앱 로그인 시 사용, 예: "CU01") |
| created_at | TIMESTAMPTZ | 생성일 |

### 2. users (직원)

앱 사용자. company_code + employee_id + password(PIN)로 로그인.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| company_id | BIGINT FK → companies | 소속 회사 |
| employee_id | VARCHAR(50) | 사원번호 (회사 내 고유) |
| name | VARCHAR(100) | 이름 |
| email | VARCHAR(255) | 이메일 (선택) |
| department | VARCHAR(100) | 부서 (선택) |
| password_hash | VARCHAR(255) | PIN 해시 |
| is_active | BOOLEAN | 활성 여부 |
| created_at | TIMESTAMPTZ | |

- UNIQUE(company_id, employee_id): 같은 회사 내 사원번호 고유

### 3. admin_users (관리자)

웹 관리 페이지 로그인용. 직원과 별도 테이블.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| company_id | BIGINT FK → companies | 소속 회사 |
| username | VARCHAR(50) UNIQUE | 로그인 ID |
| password_hash | VARCHAR(255) | 비밀번호 해시 |
| name | VARCHAR(100) | 관리자 이름 |
| created_at | TIMESTAMPTZ | |

### 4. verification_methods (인증 방법 목록)

회사별로 활성화된 인증 방법. 8가지 중 ON/OFF 토글.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| company_id | BIGINT FK → companies | |
| method_type | method_type_enum | 인증 방법 종류 |
| is_enabled | BOOLEAN DEFAULT true | 활성 여부 |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

- UNIQUE(company_id, method_type): 회사당 방법별 1개

### 5. verification_configs (인증 방법별 설정값)

각 인증 방법의 구체적 설정값. JSONB로 유연하게 저장.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| verification_method_id | BIGINT FK → verification_methods | |
| config_data | JSONB NOT NULL | 방법별 설정값 (아래 참고) |
| created_at | TIMESTAMPTZ | |
| updated_at | TIMESTAMPTZ | |

- UNIQUE(verification_method_id): 방법당 1개 설정

**config_data 구조 (방법별):**

```json
// GPS
{"latitude": 37.5665, "longitude": 126.9780, "radius_meters": 100}

// GPS_QR
{"latitude": 37.5665, "longitude": 126.9780, "radius_meters": 100, "qr_code": "WC-GPS-001"}

// WIFI
{"ssid": "Office-WiFi", "bssid": "AA:BB:CC:DD:EE:FF"}

// WIFI_QR
{"ssid": "Office-WiFi", "bssid": "AA:BB:CC:DD:EE:FF", "qr_code": "WC-WIFI-001"}

// NFC
{"tag_id": "NFC-TAG-001"}

// NFC_GPS
{"tag_id": "NFC-TAG-001", "latitude": 37.5665, "longitude": 126.9780, "radius_meters": 100}

// BEACON
{"uuid": "12345678-1234-1234-1234-123456789ABC", "major": 1, "minor": 100, "rssi_threshold": -70}

// BEACON_GPS
{"uuid": "12345678-1234-1234-1234-123456789ABC", "major": 1, "minor": 100, "rssi_threshold": -70, "latitude": 37.5665, "longitude": 126.9780, "radius_meters": 100}
```

### 6. attendance_records (출퇴근 기록)

앱에서 출퇴근 시 생성되는 기록. Flutter `AttendanceModel`과 1:1 매핑.

| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | BIGSERIAL PK | |
| user_id | BIGINT FK → users | 직원 |
| type | attendance_type_enum | CLOCK_IN / CLOCK_OUT |
| status | attendance_status_enum | PENDING / APPROVED / REJECTED (기본: PENDING) |
| verification_method_id | BIGINT FK → verification_methods | 사용된 인증 방법 |
| verification_data | JSONB | 인증 시 수집된 데이터 |
| recorded_at | TIMESTAMPTZ | 출퇴근 시각 |
| created_at | TIMESTAMPTZ | 레코드 생성 시각 |

- INDEX: (user_id, recorded_at) - 날짜별 출퇴근 조회
- INDEX: (user_id, type, recorded_at) - 오늘의 출퇴근 상태 조회

**verification_data 예시 (앱이 전송하는 데이터):**
```json
// GPS 인증 시
{"latitude": 37.5668, "longitude": 126.9782, "accuracy": 10.5, "timestamp": "2026-03-01T08:55:00+09:00"}

// QR 인증 시
{"qr_data": "WC-GPS-QR-001", "format": "QR_CODE", "timestamp": "2026-03-01T08:55:00+09:00"}

// NFC 인증 시
{"tag_id": "NFC-TAG-001", "tag_data": "...", "timestamp": "2026-03-01T08:55:00+09:00"}

// Beacon(Bluetooth) 인증 시
{"detected_devices": [{"device_id": "12345678-...", "device_name": "Beacon-1", "rssi": -65}], "device_count": 1, "timestamp": "2026-03-01T08:55:00+09:00"}

// WiFi 인증 시
{"ssid": "WorkCheck-Office", "bssid": "AA:BB:CC:DD:EE:FF", "ip": "192.168.1.100", "timestamp": "2026-03-01T08:55:00+09:00"}
```

## ENUM 정의

### method_type_enum
```
GPS, GPS_QR, WIFI, WIFI_QR, NFC, NFC_GPS, BEACON, BEACON_GPS
```

### attendance_type_enum
```
CLOCK_IN, CLOCK_OUT
```

### attendance_status_enum
```
PENDING, APPROVED, REJECTED
```

## 설계 결정 사항

1. **JSONB 사용 (verification_configs.config_data)**
   - 8가지 방법의 설정값 구조가 모두 다름
   - 개별 컬럼으로 만들면 NULL이 과다하게 발생
   - JSONB는 PostgreSQL에서 인덱싱 가능하고 유연함

2. **verification_methods + verification_configs 분리**
   - methods: ON/OFF 토글 (관리자 웹에서 빠른 전환)
   - configs: 상세 설정값 (편집 빈도가 다름)
   - 1:1 관계이지만 관심사 분리

3. **attendance_records.verification_method_id (FK)**
   - 앱의 `verification_method` 문자열 대신 FK 사용
   - API 레이어에서 method_type 문자열 ↔ FK 변환

4. **users.password_hash**
   - 앱의 SecureNumberPad → 4자리 PIN
   - BCrypt 등으로 해시 저장 (MVP에서도 평문 저장 금지)

5. **company code 기반 로그인**
   - 앱에서 company_code + employee_id + password로 로그인
   - companies.code (UNIQUE)로 회사 식별
