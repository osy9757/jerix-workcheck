# WorkCheck MVP 시스템 아키텍처

작성일: 2026-03-01

## 1. 시스템 개요

출퇴근 등록 서비스의 MVP 백엔드 시스템.
Flutter 앱이 8가지 인증 방식으로 출퇴근을 등록하고, 관리자 웹에서 설정을 관리한다.

```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│  Flutter App │────▶│  Spring Boot    │────▶│  PostgreSQL  │
│  (모바일)    │     │  REST API       │     │  (5432)      │
└─────────────┘     │  (8080)         │     └──────────────┘
                    │                 │
┌─────────────┐     │                 │
│  Flutter Web │────▶│                 │
│  + Nginx     │     └─────────────────┘
│  (3000)      │
└─────────────┘
```

---

## 2. Docker Compose 구성

```yaml
version: '3.8'

services:
  db:
    image: postgres:16-alpine
    container_name: workcheck-db
    environment:
      POSTGRES_DB: workcheck
      POSTGRES_USER: workcheck
      POSTGRES_PASSWORD: workcheck_dev
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U workcheck"]
      interval: 5s
      timeout: 3s
      retries: 5

  api:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: workcheck-api
    ports:
      - "8080:8080"
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/workcheck
      SPRING_DATASOURCE_USERNAME: workcheck
      SPRING_DATASOURCE_PASSWORD: workcheck_dev
      SPRING_JPA_HIBERNATE_DDL_AUTO: validate
    depends_on:
      db:
        condition: service_healthy

  web:
    build:
      context: ../workCheck/admin_web
      dockerfile: Dockerfile
    container_name: workcheck-web
    ports:
      - "3000:80"
    depends_on:
      - api

volumes:
  postgres_data:
```

---

## 3. REST API 엔드포인트

기본 URL: `/api/v1`

> **참고**: 앱의 기존 Retrofit 인터페이스(`AttendanceRemoteDataSource`)와 호환되도록 설계.
> JSON 필드명은 snake_case (앱의 `@JsonKey` 어노테이션 기준).

### 3.1 출퇴근 (Attendance)

#### POST `/api/v1/attendance/clock-in` — 출근 등록

```json
// Request
{
  "type": "CLOCK_IN",
  "verification_method": "gps",
  "verification_data": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "accuracy": 10.5,
    "timestamp": "2026-03-01T09:00:00"
  }
}

// Response 200
{
  "id": 1,
  "type": "CLOCK_IN",
  "timestamp": "2026-03-01T09:00:05",
  "verification_method": "gps",
  "verification_data": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "accuracy": 10.5
  }
}
```

#### POST `/api/v1/attendance/clock-out` — 퇴근 등록

```json
// Request (clock-in과 동일 구조)
{
  "type": "CLOCK_OUT",
  "verification_method": "bluetooth",
  "verification_data": {
    "detected_devices": [
      {"device_id": "AA:BB:CC:DD:EE:FF", "rssi": -65}
    ],
    "device_count": 1
  }
}

// Response 200 (clock-in과 동일 구조)
{
  "id": 2,
  "type": "CLOCK_OUT",
  "timestamp": "2026-03-01T18:00:03",
  "verification_method": "bluetooth",
  "verification_data": { ... }
}
```

#### GET `/api/v1/attendance/today` — 오늘 출퇴근 상태

```json
// Response 200
{
  "clock_in": {
    "id": 1,
    "type": "CLOCK_IN",
    "timestamp": "2026-03-01T09:00:05",
    "verification_method": "gps",
    "verification_data": { ... }
  },
  "clock_out": null
}
```

#### GET `/api/v1/attendance/history?from=2026-02-01&to=2026-02-28` — 출퇴근 기록 조회

```json
// Response 200
{
  "records": [
    {
      "date": "2026-02-28",
      "clock_in": {
        "id": 50,
        "type": "CLOCK_IN",
        "timestamp": "2026-02-28T08:55:00",
        "verification_method": "wifi",
        "verification_data": { ... }
      },
      "clock_out": {
        "id": 51,
        "type": "CLOCK_OUT",
        "timestamp": "2026-02-28T18:10:00",
        "verification_method": "wifi",
        "verification_data": { ... }
      }
    }
  ],
  "total": 20
}
```

### 3.2 인증 설정 (Verification Config)

#### GET `/api/v1/verification/methods` — 활성화된 인증 방법 목록

```json
// Response 200
{
  "methods": [
    {
      "id": 1,
      "method_type": "GPS",
      "enabled": true,
      "config": {
        "latitude": 37.5665,
        "longitude": 126.9780,
        "radius_meters": 100
      }
    },
    {
      "id": 7,
      "method_type": "BEACON",
      "enabled": true,
      "config": {
        "uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
        "major": 1,
        "minor": 100,
        "rssi_threshold": -70
      }
    }
  ]
}
```

#### PUT `/api/v1/verification/methods/{id}` — 인증 방법 ON/OFF + 설정 수정

```json
// Request
{
  "enabled": true,
  "config": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "radius_meters": 150
  }
}

// Response 200
{
  "id": 1,
  "method_type": "GPS",
  "enabled": true,
  "config": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "radius_meters": 150
  }
}
```

#### GET `/api/v1/verification/methods/{id}` — 특정 인증 방법 상세 조회

```json
// Response 200
{
  "id": 1,
  "method_type": "GPS",
  "enabled": true,
  "config": {
    "latitude": 37.5665,
    "longitude": 126.9780,
    "radius_meters": 100
  }
}
```

### 3.3 사용자 (Users)

#### GET `/api/v1/users` — 직원 목록

```json
// Response 200
{
  "users": [
    {
      "id": 1,
      "company_code": "CU01",
      "employee_id": "4",
      "name": "홍길동",
      "created_at": "2026-01-15T10:00:00"
    }
  ],
  "total": 1
}
```

#### POST `/api/v1/users` — 직원 등록

```json
// Request
{
  "company_code": "CU01",
  "employee_id": "5",
  "name": "김철수",
  "password": "1234"
}

// Response 201
{
  "id": 2,
  "company_code": "CU01",
  "employee_id": "5",
  "name": "김철수",
  "created_at": "2026-03-01T12:00:00"
}
```

### 3.4 관리자 (Admin)

#### POST `/api/v1/admin/login` — 관리자 로그인

```json
// Request
{
  "username": "admin",
  "password": "admin1234"
}

// Response 200
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "admin": {
    "id": 1,
    "username": "admin"
  }
}
```

### 3.5 근무지 설정 (Workplace Config) — 앱용

#### GET `/api/v1/workplace/config` — 앱에서 활성화된 인증 방법 + 설정값 일괄 조회

```json
// Response 200
{
  "enabled_methods": ["gps", "bluetooth", "wifi"],
  "configs": {
    "gps": {
      "latitude": 37.5665,
      "longitude": 126.9780,
      "radius_meters": 100
    },
    "bluetooth": {
      "uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0",
      "major": 1,
      "minor": 100,
      "rssi_threshold": -70
    },
    "wifi": {
      "ssid": "OFFICE-5G",
      "bssid": "AA:BB:CC:DD:EE:FF"
    }
  }
}
```

---

## 4. 인증 방법 8가지 설정 구조

백엔드에서는 `verification_methods` 테이블에 8가지 방법을 각각 하나의 row로 관리한다.
`config` 컬럼은 JSONB 타입으로, 방법마다 다른 설정값을 저장한다.

| # | method_type | config JSON 구조 |
|---|-------------|------------------|
| 1 | `GPS` | `{"latitude": 37.56, "longitude": 126.97, "radius_meters": 100}` |
| 2 | `GPS_QR` | `{"latitude": 37.56, "longitude": 126.97, "radius_meters": 100, "qr_code": "WORK-QR-001"}` |
| 3 | `WIFI` | `{"ssid": "OFFICE-5G", "bssid": "AA:BB:CC:DD:EE:FF"}` |
| 4 | `WIFI_QR` | `{"ssid": "OFFICE-5G", "bssid": "AA:BB:CC:DD:EE:FF", "qr_code": "WORK-QR-002"}` |
| 5 | `NFC` | `{"tag_id": "04:A2:B3:C4:D5:E6"}` |
| 6 | `NFC_GPS` | `{"tag_id": "04:A2:B3:C4:D5:E6", "latitude": 37.56, "longitude": 126.97, "radius_meters": 100}` |
| 7 | `BEACON` | `{"uuid": "E2C56DB5-...", "major": 1, "minor": 100, "rssi_threshold": -70}` |
| 8 | `BEACON_GPS` | `{"uuid": "E2C56DB5-...", "major": 1, "minor": 100, "rssi_threshold": -70, "latitude": 37.56, "longitude": 126.97, "radius_meters": 100}` |

### 앱 ↔ 백엔드 매핑

앱의 `VerificationMethod` enum (gps, qr, nfc, bluetooth, wifi)은 **단일 인증 수단**을 나타낸다.
백엔드의 `method_type`은 **복합 인증 방법**을 나타낸다 (예: GPS + QR).

출퇴근 등록 시 앱은 `verification_data`에 수행한 인증 데이터를 모두 보낸다.
백엔드는 현재 활성화된 `method_type`의 `config`와 대조하여 검증한다.

```
앱: verification_method: "gps" + verification_data: {latitude, longitude, ...}
     ↓
백엔드: 활성화된 method_type이 "GPS"인지 "GPS_QR"인지 확인
     → GPS: GPS 데이터만 검증
     → GPS_QR: GPS 데이터 + QR 코드 추가 검증
```

---

## 5. 통신 흐름

### 5.1 앱 → 백엔드 (출퇴근 등록)

```
Flutter App
  │
  ├─ 1. GET /api/v1/workplace/config     (앱 시작 시 설정 로드)
  │      ← 활성 인증 방법 + 설정값
  │
  ├─ 2. GET /api/v1/attendance/today      (오늘 상태 확인)
  │      ← clock_in / clock_out 상태
  │
  ├─ 3. [사용자 인증 수행]                 (GPS/QR/NFC/Beacon/WiFi)
  │      ← VerificationResult (로컬)
  │
  └─ 4. POST /api/v1/attendance/clock-in  (서버에 등록)
         → {type, verification_method, verification_data}
         ← {id, type, timestamp, ...}
```

### 5.2 관리자 웹 → 백엔드

```
Flutter Web (Admin)
  │
  ├─ 1. POST /api/v1/admin/login           (로그인)
  │      ← {token, admin}
  │
  ├─ 2. GET /api/v1/verification/methods    (인증 방법 목록)
  │      ← 8가지 방법 + enabled 상태 + config
  │
  ├─ 3. PUT /api/v1/verification/methods/1  (설정 변경)
  │      → {enabled: true, config: {...}}
  │
  ├─ 4. GET /api/v1/attendance/history      (출퇴근 기록 조회)
  │      ← records[]
  │
  └─ 5. GET /api/v1/users                   (직원 관리)
         ← users[]
```

---

## 6. 백엔드 레이어드 아키텍처

```
com.workcheck.backend/
├── WorkCheckApplication.kt              # Spring Boot 메인
│
├── config/
│   ├── WebConfig.kt                     # CORS 설정
│   ├── SecurityConfig.kt                # JWT 필터 (MVP: 최소)
│   └── JacksonConfig.kt                 # snake_case JSON 직렬화
│
├── controller/
│   ├── AttendanceController.kt          # 출퇴근 API
│   ├── VerificationController.kt        # 인증 설정 API
│   ├── UserController.kt                # 사용자 API
│   └── AdminController.kt              # 관리자 API
│
├── service/
│   ├── AttendanceService.kt             # 출퇴근 비즈니스 로직
│   ├── VerificationService.kt           # 인증 검증 로직
│   ├── UserService.kt                   # 사용자 관리
│   └── AdminService.kt                 # 관리자 인증
│
├── repository/
│   ├── AttendanceRepository.kt          # JPA Repository
│   ├── VerificationMethodRepository.kt
│   ├── UserRepository.kt
│   └── AdminRepository.kt
│
├── entity/
│   ├── AttendanceRecord.kt              # 출퇴근 기록
│   ├── VerificationMethod.kt            # 인증 방법 설정
│   ├── User.kt                          # 직원
│   └── Admin.kt                         # 관리자
│
├── dto/
│   ├── request/
│   │   ├── ClockInRequest.kt
│   │   ├── ClockOutRequest.kt
│   │   ├── UpdateVerificationRequest.kt
│   │   ├── CreateUserRequest.kt
│   │   └── AdminLoginRequest.kt
│   └── response/
│       ├── AttendanceResponse.kt
│       ├── TodayStatusResponse.kt
│       ├── HistoryResponse.kt
│       ├── VerificationMethodResponse.kt
│       ├── WorkplaceConfigResponse.kt
│       ├── UserResponse.kt
│       └── AdminLoginResponse.kt
│
└── util/
    └── JwtUtil.kt                       # JWT 토큰 생성/검증
```

### 레이어 규칙

```
Controller  ← DTO 변환, 입력 검증
    ↓
Service     ← 비즈니스 로직 (인증 검증, 상태 체크)
    ↓
Repository  ← DB 접근 (Spring Data JPA)
    ↓
Entity      ← 테이블 매핑
```

- Controller는 Service만 의존
- Service는 Repository만 의존
- Entity는 다른 레이어를 의존하지 않음
- DTO는 Controller 레이어에서 Entity로 변환

---

## 7. 핵심 비즈니스 로직

### 7.1 출퇴근 등록 흐름 (AttendanceService)

```
1. 오늘 이미 출근/퇴근했는지 확인
2. 현재 활성화된 인증 방법 조회
3. 요청의 verification_method가 활성화된 방법과 일치하는지 확인
4. verification_data를 config와 대조하여 검증
   - GPS: 좌표 간 거리 계산 → radius_meters 이내인지
   - WiFi: SSID/BSSID 일치 여부
   - NFC: tag_id 일치 여부
   - Beacon: UUID/Major/Minor 일치 + RSSI 임계값
   - QR: qr_code 값 일치 여부
   - 복합 방법: 해당 단일 방법들을 모두 검증
5. 검증 통과 시 AttendanceRecord 저장
6. 응답 반환
```

### 7.2 인증 검증 로직 (VerificationService)

```kotlin
// GPS 거리 검증 (Haversine)
fun verifyGps(data: Map, config: Map): Boolean {
    val distance = haversineDistance(
        data.latitude, data.longitude,
        config.latitude, config.longitude
    )
    return distance <= config.radiusMeters
}

// Beacon 검증
fun verifyBeacon(data: Map, config: Map): Boolean {
    val devices = data.detectedDevices
    return devices.any { device ->
        device.uuid == config.uuid &&
        device.major == config.major &&
        device.minor == config.minor &&
        device.rssi >= config.rssiThreshold
    }
}
```

---

## 8. 기술 스택 요약

| 컴포넌트 | 기술 |
|----------|------|
| Backend | Kotlin + Spring Boot 3.x |
| DB | PostgreSQL 16 |
| ORM | Spring Data JPA |
| JSON | Jackson (snake_case) |
| Auth (MVP) | JWT (간단한 토큰 기반) |
| Build | Gradle (Kotlin DSL) |
| Container | Docker + Docker Compose |
| Admin Web | Flutter Web + Nginx |
| App | Flutter + BLoC + Retrofit + Dio |

---

## 9. API 엔드포인트 요약

| Method | URL | 설명 | 사용자 |
|--------|-----|------|--------|
| POST | `/api/v1/attendance/clock-in` | 출근 등록 | 앱 |
| POST | `/api/v1/attendance/clock-out` | 퇴근 등록 | 앱 |
| GET | `/api/v1/attendance/today` | 오늘 상태 | 앱 |
| GET | `/api/v1/attendance/history` | 기록 조회 | 앱/웹 |
| GET | `/api/v1/workplace/config` | 근무지 설정 | 앱 |
| GET | `/api/v1/verification/methods` | 인증 방법 목록 | 웹 |
| GET | `/api/v1/verification/methods/{id}` | 인증 방법 상세 | 웹 |
| PUT | `/api/v1/verification/methods/{id}` | 인증 방법 수정 | 웹 |
| GET | `/api/v1/users` | 직원 목록 | 웹 |
| POST | `/api/v1/users` | 직원 등록 | 웹 |
| POST | `/api/v1/admin/login` | 관리자 로그인 | 웹 |

---

## 10. MVP 범위 외 (향후)

- OAuth / 소셜 로그인
- 실시간 알림 (WebSocket)
- 파일 업로드 (프로필 사진 등)
- 다중 회사(테넌트) 지원
- 세부 권한 관리 (RBAC)
- 로그/감사 추적
- 앱 기기 등록/관리 API
