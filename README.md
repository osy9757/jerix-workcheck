# WorkCheck - 출퇴근 관리 시스템

모바일 앱(Flutter) + 백엔드 API(Kotlin Spring Boot) + 관리자 웹(Flutter Web) 모노레포.
8가지 인증 방식(GPS, WiFi, NFC, Beacon 및 복합)을 지원하는 출퇴근 관리 시스템.

---

## 목차

1. [기술 스택](#기술-스택)
2. [프로젝트 구조](#프로젝트-구조)
3. [빠른 시작 (Docker Compose)](#빠른-시작)
4. [백엔드 API](#백엔드-api)
5. [Flutter 모바일 앱](#flutter-모바일-앱)
6. [관리자 웹 (Admin Web)](#관리자-웹)
7. [인증 방식 8가지](#인증-방식-8가지)
8. [출퇴근 인증 흐름](#출퇴근-인증-흐름)
9. [데이터베이스](#데이터베이스)
10. [테스트 방법](#테스트-방법)
11. [테스트 계정](#테스트-계정)
12. [사용 라이브러리](#사용-라이브러리)
13. [MVP 제한사항](#mvp-제한사항)

---

## 기술 스택

| 영역 | 기술 | 버전 |
|------|------|------|
| 모바일 앱 | Flutter (Dart) | Stable |
| 상태관리 | flutter_bloc (BLoC 패턴) | 9.x |
| 백엔드 | Kotlin + Spring Boot | 1.9.24 / 3.2.5 |
| DB | PostgreSQL | 16 |
| ORM | Spring Data JPA / Hibernate | - |
| 인증 | JWT (jjwt 0.12.5) | - |
| 관리자 웹 | Flutter Web + Nginx | Stable |
| 컨테이너 | Docker Compose | 3.8 |

---

## 프로젝트 구조

```
jerix-workcheck/
├── docker-compose.yml                 # DB + API + Web 컨테이너 오케스트레이션
│
├── workCheck_backend/                 # Kotlin Spring Boot API 서버
│   ├── Dockerfile                     # 멀티스테이지 빌드 (gradle → JRE)
│   ├── build.gradle.kts               # Spring Boot 3.2.5, Kotlin 1.9.24, JDK 17
│   └── src/main/
│       ├── kotlin/com/workcheck/backend/
│       │   ├── config/                # 보안, CORS, JWT, 예외처리, 로깅 필터
│       │   ├── controller/            # REST API 컨트롤러 (7개)
│       │   ├── dto/
│       │   │   ├── request/           # 요청 DTO (9개)
│       │   │   └── response/          # 응답 DTO (14개)
│       │   ├── entity/                # JPA 엔티티 (9개)
│       │   ├── repository/            # Spring Data JPA 리포지토리 (8개)
│       │   ├── service/               # 비즈니스 로직 (6개)
│       │   └── util/                  # JwtUtil
│       └── resources/
│           ├── application.yml        # 서버 설정
│           ├── schema.sql             # DDL (테이블, ENUM, 인덱스)
│           ├── seed.sql               # 시드 데이터 (테스트용)
│           └── logback-spring.xml     # 로깅 설정
│
├── workCheck/                         # Flutter 모바일 앱
│   ├── attendance_app/
│   │   ├── pubspec.yaml               # 의존성 (30+ 패키지)
│   │   └── lib/
│   │       ├── main.dart              # 앱 진입점
│   │       ├── injection.dart         # get_it + injectable DI 설정
│   │       ├── core/                  # 공통 (네트워크, 상수, 테마, 에러)
│   │       └── features/
│   │           ├── attendance/        # 출퇴근 (BLoC + 화면 + 위젯)
│   │           ├── auth/              # 로그인/회원가입
│   │           ├── debug/             # 디버그 스캔 (NFC/Beacon/WiFi 원시 데이터)
│   │           ├── history/           # 출퇴근 이력
│   │           ├── settings/          # 서버 URL 설정
│   │           └── verification/      # 인증 전략 시스템 (5개 서비스)
│   │
│   └── admin_web/                     # Flutter Web 관리자 페이지
│       ├── Dockerfile                 # Flutter 웹 빌드 → nginx
│       ├── nginx.conf                 # SPA 라우팅 + API 프록시
│       └── lib/
│           ├── models/                # 데이터 모델 (7개)
│           ├── services/              # API 서비스
│           └── pages/                 # 페이지 (6개)
```

---

## 빠른 시작

### 사전 요구사항

- Docker & Docker Compose
- (앱 개발 시) Flutter SDK, Xcode(iOS) 또는 Android Studio

### 서버 실행

```bash
# 전체 빌드 + 실행 (DB 볼륨 초기화 포함)
docker-compose down -v && docker-compose up --build -d

# 로그 확인
docker-compose logs -f api    # API 서버 로그
docker-compose logs -f db     # DB 로그
docker-compose logs -f web    # Web 로그
```

### 서비스 포트

| 서비스 | 포트 | 설명 |
|--------|------|------|
| PostgreSQL | 5433 | DB (외부 접속용) |
| Spring Boot API | 8081 | 백엔드 API |
| Admin Web (Nginx) | 3002 | 관리자 페이지 |

### Flutter 앱 실행 (로컬 개발)

```bash
cd workCheck/attendance_app
flutter pub get
flutter run
```

> 앱의 서버 URL은 설정 화면에서 변경 가능 (기본: `http://175.126.191.135:8081`)

---

## 백엔드 API

### API 엔드포인트 목록

#### 인증 (Auth)

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| POST | `/api/v1/auth/login` | 앱 로그인 (회사코드 + 사번 + 비밀번호) | 없음 |
| POST | `/api/v1/admin/login` | 관리자 로그인 | 없음 |

#### 출퇴근 (Attendance)

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| POST | `/api/v1/attendance/clock-in` | 출근 (인증 데이터 포함) | JWT |
| POST | `/api/v1/attendance/clock-out` | 퇴근 (인증 데이터 포함) | JWT |
| GET | `/api/v1/attendance/today` | 오늘 출퇴근 현황 | JWT |
| GET | `/api/v1/attendance/history` | 내 출퇴근 이력 (기간 조회) | JWT |
| GET | `/api/v1/admin/attendance/history` | 전체 직원 출퇴근 이력 (관리자) | JWT |

#### 근무지 설정 (Workplace Config)

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| GET | `/api/v1/workplace/config` | 앱용 근무지 설정 조회 (인증방법 + 설정값) | JWT |

#### 사용자 관리 (Users)

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| GET | `/api/v1/users` | 전체 사용자 목록 | 없음 |
| POST | `/api/v1/users` | 사용자 생성 | 없음 |
| PUT | `/api/v1/users/{id}` | 사용자 수정 | 없음 |
| PUT | `/api/v1/users/{id}/workplace` | 근무지 배정 | 없음 |
| GET | `/api/v1/users/{id}/verification-overrides` | 인증 오버라이드 조회 | 없음 |
| PUT | `/api/v1/users/{id}/verification-overrides` | 인증 오버라이드 수정 | 없음 |

#### 근무지 관리 (Workplaces)

| Method | Path | 설명 | 인증 |
|--------|------|------|------|
| GET | `/api/v1/workplaces` | 전체 근무지 목록 | 없음 |
| POST | `/api/v1/workplaces` | 근무지 생성 | 없음 |
| PUT | `/api/v1/workplaces/{id}` | 근무지 수정 | 없음 |
| GET | `/api/v1/workplaces/{id}/verification-methods` | 인증 방법 목록 | 없음 |
| PUT | `/api/v1/workplaces/{id}/verification-methods/{methodId}` | 인증 방법 수정 (ON/OFF, 설정) | 없음 |
| GET | `/api/v1/workplaces/{id}/qr-codes` | QR 코드 목록 | 없음 |
| POST | `/api/v1/workplaces/{id}/qr-codes` | QR 코드 생성 | 없음 |
| DELETE | `/api/v1/workplaces/{id}/qr-codes/{qrId}` | QR 코드 삭제 | 없음 |

### Service 계층

| Service | 역할 |
|---------|------|
| **AuthService** | 앱 로그인: 회사코드→회사 조회→사번으로 사용자 찾기→BCrypt 검증→JWT 발급 |
| **AdminService** | 관리자 로그인: username→관리자 조회→BCrypt 검증→JWT 발급 |
| **AttendanceService** | 출퇴근: 중복 체크(당일 동일 타입), VerificationService에 검증 위임, 기록 저장 |
| **VerificationService** | 인증 검증 엔진: 8가지 방법별 검증 로직, 사용자별 오버라이드 병합 |
| **UserService** | 사용자 CRUD, 근무지 배정, 인증 오버라이드 관리 |
| **WorkplaceService** | 근무지 CRUD, 인증 방법/설정 관리, QR 코드 관리 |

### Config 클래스

| 클래스 | 역할 |
|--------|------|
| **SecurityConfig** | BCryptPasswordEncoder 빈 등록 |
| **WebConfig** | CORS 전체 허용, JWT 인터셉터 등록 (`/api/v1/attendance/**`, `/api/v1/workplace/config`) |
| **JwtAuthInterceptor** | Bearer 토큰 추출→JwtUtil.validateToken→userId를 request attribute에 저장 |
| **GlobalExceptionHandler** | IllegalArgument→400, VerificationFailed→400+errorCode, AuthenticationFailed→401 |
| **RequestLoggingFilter** | 요청/응답 바디 + 처리시간 로깅 |

### application.yml 주요 설정

```yaml
server.port: 8080
spring.datasource: PostgreSQL (환경변수 오버라이드 가능)
spring.jpa.hibernate.ddl-auto: validate
spring.jackson.property-naming-strategy: SNAKE_CASE
jwt.secret: (기본값 내장)
jwt.expiration: 86400000  # 24시간
```

---

## Flutter 모바일 앱

### 아키텍처

**Clean Architecture + BLoC 패턴**

각 Feature는 다음 레이어로 구성:
```
features/{name}/
├── data/           # 데이터소스, 모델, 리포지토리 구현
├── domain/         # 엔티티, 리포지토리 인터페이스, 유스케이스
└── presentation/   # BLoC, 화면, 위젯
```

### 화면 구성

| 라우트 | 화면 | 설명 |
|--------|------|------|
| `/login` | LoginScreen | 회사코드 + 사번 + 비밀번호 로그인 |
| `/` | AttendanceScreen | 메인: 카카오맵 + 출퇴근 버튼 + 인증 아이콘 |
| `/history` | HistoryScreen | 출퇴근 이력 조회 |
| `/register` | RegisterScreen | 회원가입 |
| `/settings` | SettingsScreen | 서버 URL 변경 |
| `/qr-scan` | QrScanScreen | QR 코드 스캔 전용 |
| `/debug-scan` | DebugScanScreen | 디버그 스캔 (NFC/Beacon/WiFi 원시 데이터 확인) |

### 디버그 스캔 화면 (DebugScanScreen)

메인 화면에서 **사용자 이름을 5초 롱프레스**하면 진입하는 숨겨진 디버그 화면.
NFC/Beacon/WiFi의 원시 데이터를 직접 확인할 수 있어, 인증 설정값(tag_id, UUID 등)을 파악하는 데 사용.

| 스캔 모드 | 기능 | 확인 가능한 데이터 |
|-----------|------|-------------------|
| **NFC** | NFC 태그 읽기 | 태그 타입, 태그 ID (UID), Raw bytes |
| **Beacon** | iBeacon 스캔 (5초) | UUID, Major, Minor, RSSI, 거리(iOS) |
| **WiFi** | 현재 WiFi 정보 조회 | SSID, BSSID, IP, 게이트웨이, 서브넷 |

- iOS Beacon: `dchs_flutter_beacon` CoreLocation ranging (알려진 UUID 3개 등록)
- Android Beacon: `flutter_blue_plus` BLE 스캔 → Apple manufacturerData(0x004C) iBeacon 파싱
- 로그아웃 버튼 포함

### BLoC 구성

#### AttendanceBloc (핵심)

**Events:**
- `Started` — 초기 로딩: 서버 설정 + 오늘 현황 + 디바이스 가용 메서드 병렬 조회
- `ClockRequested(type)` — 출근/퇴근 요청: 인증 실행 → 서버 전송
- `AvailableMethodsRequested` — 가용 메서드 새로고침

**State (Freezed):**
- `todayStatus` — 오늘 출/퇴근 기록
- `availableMethods` — 서버 활성화 ∩ 디바이스 가용 메서드
- `uiState` — initial / loading / loaded / clockingIn / success / error / clockedOut
- `errorMessage`, `errorCode`

**초기화 흐름:**
1. 서버에서 workplaceConfig 조회 (enabledMethods + configs)
2. getTodayStatus로 오늘 현황 확인
3. 디바이스 가용 메서드 확인 (각 전략의 `isAvailable()` 호출)
4. 서버 활성화 ∩ 디바이스 가용 = 최종 availableMethods
5. NFC → expectedTagId 설정, Beacon → targetUuid 설정

#### AuthBloc
- `LoginRequested` → API 로그인 → JWT 저장 → 화면 전환
- `LogoutRequested` → JWT 삭제 → 로그인 화면

#### HistoryBloc
- `LoadHistory` → 기간별 출퇴근 이력 조회

### 인증 전략 시스템 (Strategy Pattern)

```
VerificationStrategy (추상 인터페이스)
├── GpsVerificationService        # GPS 위치 + 스푸핑 감지
├── QrVerificationService         # QR 코드 스캔 (30초 타임아웃)
├── NfcVerificationService        # NFC 태그 UID 읽기
├── BluetoothVerificationService  # iBeacon 스캔 (iOS/Android 분기)
└── WifiVerificationService       # WiFi SSID/BSSID 수집

VerificationManager
├── 전략 레지스트리 (DI로 주입)
├── 단일 메서드 실행: verify(method) → VerificationResult
└── 복합 메서드 분해: beaconGps → [beacon, gps] 순차 실행 후 데이터 병합
```

### Core 모듈

| 모듈 | 설명 |
|------|------|
| **api_constants.dart** | 기본 서버 URL, 모든 API 경로 상수 |
| **dio_client.dart** | Dio 클라이언트: 동적 서버 URL, JWT 자동 주입, 401 처리, 로깅 |
| **failures.dart** | Failure 계층: ServerFailure(statusCode, errorCode), NetworkFailure 등 |
| **app_theme.dart** | 메인 컬러 #2DDAA9, Pretendard 폰트 |

---

## 관리자 웹

### 페이지 구성

| 페이지 | 기능 |
|--------|------|
| **로그인** | 관리자 계정 로그인 (username + password) |
| **대시보드** | 사이드바 네비게이션 (4개 메뉴) |
| **출퇴근 관리** | 날짜 범위 선택 → 전체 출퇴근 기록 테이블 |
| **인증 관리** | 근무지 선택 → 인증 방법 ON/OFF 토글 + 설정 편집 다이얼로그 |
| **직원 관리** | 직원 CRUD + 근무지 배정 + 인증 오버라이드 관리 |
| **근무지 관리** | 근무지 CRUD + 좌표 설정 + QR 코드 관리 |

### API 연동

- Dio HTTP 클라이언트, JWT를 localStorage에 저장
- baseUrl: 동적 설정 가능 (기본: `http://localhost:8081`)
- Nginx 프록시: `/api/` → `http://api:8080/api/` (Docker 내부 통신)

---

## 인증 방식 8가지

| # | 방법 | 앱 동작 | 서버 검증 | 설정값 |
|---|------|---------|----------|--------|
| 1 | **GPS** | Geolocator로 위치 획득, 스푸핑 감지 | Haversine 거리 ≤ 반경 | `radius_meters` |
| 2 | **GPS + QR** | QR 스캔 → GPS 획득 (순차) | QR payload 일치 + GPS 거리 | `radius_meters`, `qr_code` |
| 3 | **WiFi** | network_info_plus로 SSID/BSSID 수집 | SSID 또는 BSSID 일치 | `ssid`, `bssid` |
| 4 | **WiFi + QR** | QR 스캔 → WiFi 정보 수집 (순차) | QR + WiFi 일치 | `ssid`, `bssid`, `qr_code` |
| 5 | **NFC** | nfc_manager로 태그 UID 읽기 | tag_id 일치 | `tag_id` |
| 6 | **NFC + GPS** | NFC 읽기 → GPS 획득 (순차) | NFC + GPS 거리 | `tag_id`, `radius_meters` |
| 7 | **Beacon** | iBeacon 스캔 (iOS: CoreLocation, Android: BLE) | UUID+Major+Minor+RSSI | `uuid`, `major`, `minor`, `rssi_threshold` |
| 8 | **Beacon + GPS** | Beacon 스캔 → GPS 획득 (순차) | Beacon + GPS 거리 | 위 + `radius_meters` |

### Beacon 스캔 상세

- **iOS**: `dchs_flutter_beacon` — CoreLocation CLBeaconRegion ranging, targetUuid로 필터링
- **Android**: `flutter_blue_plus` — BLE 스캔 → Apple Company ID(0x004C) manufacturerData에서 iBeacon 파싱 (UUID 16bytes + Major 2bytes + Minor 2bytes + TxPower 1byte)
- RSSI ≥ -80 필터링, 5초 스캔 타임아웃
- 중복 제거: major + minor 기준

### GPS 스푸핑 감지

- `position.isMocked` 체크
- accuracy > 100m 경고
- 감지 시 전용 경고 다이얼로그 표시

---

## 출퇴근 인증 흐름

### 1. 앱 로그인

```
사용자 입력 (회사코드 + 사번 + 비밀번호)
  → POST /api/v1/auth/login
  → 회사코드로 회사 조회 → 사번으로 사용자 찾기 → BCrypt 검증
  → JWT 발급 (24시간) + 활성화된 인증 방법 목록 반환
  → JWT를 SharedPreferences에 저장
```

### 2. 출퇴근 화면 초기화

```
AttendanceBloc Started:
  ├─ GET /api/v1/workplace/config → 활성 인증방법 + 설정값
  ├─ GET /api/v1/attendance/today → 오늘 출퇴근 현황
  └─ 디바이스 가용 메서드 확인 (BT on? GPS on? NFC on?)
  → availableMethods = 서버 활성화 ∩ 디바이스 가용
```

### 3. 출근 버튼 → 인증 → 서버 검증

```
출근 버튼 터치
  → ClockRequested(CLOCK_IN) 이벤트
  → VerificationManager.verify(method):
      각 인증 전략 실행 (다이얼로그 표시)
      → VerificationResult { data: {인증 데이터} }
  → POST /api/v1/attendance/clock-in { method, verification_data }
  → 서버 VerificationService.verify():
      1. 사용자 → 근무지 → 인증방법 매칭
      2. 설정값 로드 (JSONB) + 오버라이드 병합
      3. 방법별 검증 (GPS 거리, WiFi SSID, NFC tag_id, Beacon UUID 등)
      4. 검증 통과 → AttendanceRecord 저장
  → 성공 응답 → 앱 UI 갱신
```

### 4. 에러 처리

```
서버 검증 실패:
  → VerificationFailedException(errorCode, message)
  → 400 + { error, errorCode }
  → 앱에서 errorCode 기반 다이얼로그 분기:
      BEACON_UUID_MISMATCH  → "비콘 UUID 불일치"
      BEACON_NOT_DETECTED   → "비콘 미감지"
      BEACON_RSSI_TOO_WEAK  → "비콘 신호 약함"
      GPS_SPOOFED           → "GPS 조작 감지"
```

---

## 데이터베이스

### 테이블 구조

| 테이블 | 주요 필드 | 설명 |
|--------|----------|------|
| **companies** | id, name, code(unique) | 회사 (코드로 로그인 시 식별) |
| **workplaces** | id, company_id(FK), name, address, latitude, longitude | 근무지 (좌표 = GPS 검증 기준점) |
| **users** | id, company_id(FK), workplace_id(FK), employee_id, name, password_hash, is_active | 직원 (employee_id는 회사 내 고유) |
| **admin_users** | id, company_id(FK), username(unique), password_hash, name | 관리자 웹 계정 |
| **verification_methods** | id, workplace_id(FK), method_type(ENUM), is_enabled | 근무지별 인증 방법 (unique: workplace+type) |
| **verification_configs** | id, verification_method_id(FK unique), config_data(JSONB) | 인증 설정 (1:1, JSONB로 유연한 설정) |
| **user_verification_overrides** | id, user_id(FK), method_type(ENUM), is_enabled, config_data(JSONB) | 사용자별 인증 오버라이드 |
| **attendance_records** | id, user_id(FK), type(ENUM), status(ENUM), verification_method_id(FK), verification_data(JSONB), recorded_at | 출퇴근 기록 |
| **qr_codes** | id, workplace_id(FK), payload(unique), label | QR 코드 관리 |

### ENUM 타입

- **method_type**: GPS, GPS_QR, WIFI, WIFI_QR, NFC, NFC_GPS, BEACON, BEACON_GPS
- **attendance_type**: CLOCK_IN, CLOCK_OUT
- **attendance_status**: PENDING, APPROVED, REJECTED

### DB 초기화

Docker Compose에서 자동 실행:
- `schema.sql` → DDL (테이블, ENUM, 인덱스 생성)
- `seed.sql` → 시드 데이터 (테스트 계정, 근무지, 인증 설정)

볼륨 초기화 시 `docker-compose down -v` 후 재시작하면 데이터가 초기화됨.

---

## 테스트 방법

### 1. 서버 실행 확인

```bash
# 컨테이너 상태 확인
docker-compose ps

# API 헬스 체크
docker-compose logs api --tail=20

# DB 데이터 확인
docker-compose exec db psql -U workcheck -d workcheck -c "SELECT * FROM companies;"
```

### 2. 앱 테스트

1. 앱 실행 후 설정에서 서버 URL 확인/변경
2. 회사코드 `jerix`, 사번, 비밀번호 `1111`로 로그인
3. 메인 화면에서 활성화된 인증 방법 아이콘 확인
4. 출근 버튼 → 인증 수행 → 결과 확인
5. 서버 로그 실시간 확인: `docker-compose logs -f api`

### 3. 관리자 웹 테스트

1. 브라우저에서 `http://<서버IP>:3002` 접속
2. admin / admin1234 로 로그인
3. 인증 관리: 근무지별 인증 방법 ON/OFF, 설정값 편집
4. 직원 관리: 직원 추가, 근무지 배정, 인증 오버라이드
5. 출퇴근 관리: 날짜 범위로 기록 조회

### 4. 인증 방법별 테스트

| 방법 | 테스트 방법 |
|------|-----------|
| GPS | 해당 근무지 좌표 근처에서 출근 (또는 관리자 웹에서 반경을 넓게 설정) |
| WiFi | 설정된 SSID의 WiFi에 연결된 상태에서 출근 |
| NFC | 설정된 tag_id의 NFC 카드를 태깅 |
| Beacon | 설정된 UUID/Major/Minor의 비콘 근처에서 출근 |
| 복합 (GPS_QR 등) | 두 인증을 순차적으로 수행 |

### 5. 디버그 스캔으로 인증 데이터 사전 확인

실제 출퇴근 인증 전에, 디버그 스캔 화면에서 NFC/Beacon/WiFi의 원시 데이터를 먼저 확인할 수 있다.

**진입 방법:** 아무 계정으로 로그인 → 메인 화면에서 **사용자 이름을 5초 롱프레스** → 디버그 스캔 화면 진입

| 스캔 | 사용 시나리오 | 확인 후 조치 |
|------|-------------|-------------|
| **NFC** | NFC 카드의 실제 tag_id를 모를 때 | 태그를 찍으면 태그 타입 + UID가 표시됨 → 이 값을 관리자 웹 또는 seed.sql에 설정 |
| **Beacon** | 비콘 디바이스의 UUID/Major/Minor를 확인할 때 | 5초 스캔 후 감지된 비콘 목록 표시 → UUID, Major, Minor, RSSI 값을 서버 설정에 반영 |
| **WiFi** | 현재 연결된 WiFi의 SSID/BSSID를 확인할 때 | SSID, BSSID가 표시됨 → 이 값을 WiFi 인증 설정에 반영 |

**활용 예시:**
1. NFC 카드 tag_id 파악: 디버그 스캔 > NFC > 카드 태깅 → `04:E9:D8:3E:C8:2A:81` 확인
2. 비콘 UUID 파악: 디버그 스캔 > Beacon > 5초 대기 → `E2C56DB5-..., Major:40011, Minor:57342` 확인
3. WiFi BSSID 파악: 디버그 스캔 > WiFi → `SSID: SK_WiFiGIGA8C8E_5G, BSSID: AA:BB:CC:DD:EE:FF` 확인
4. 확인한 값을 관리자 웹(인증 관리)에서 해당 근무지 설정에 입력 → 출퇴근 인증 테스트

> 디버그 스캔 화면에는 로그아웃 버튼도 포함되어 있어 계정 전환 테스트에도 활용 가능.

### 6. 서버 로그로 디버깅

```bash
# 실시간 API 로그 (인증 검증 상세 포함)
docker-compose logs -f api

# 로그 예시:
# [Verify] user: NFC테스트 (31), workplace: 을지로지점 (id=5)
# [NFC] 수신 tag_id: '04:E9:D8:3E:C8:2A:81', 서버 tag_id: '04:E9:D8:3E:C8:2A:81'
# [NFC] 비교 결과: MATCH
# [Verify] SUCCESS
```

---

## 테스트 계정

> 모든 직원 비밀번호: **1111** / 모든 관리자 비밀번호: **admin1234**
> 회사코드: **jerix**

### 직원 계정

| 사번 | 이름 | 근무지 | 인증방법 |
|------|------|--------|----------|
| 11 | GPS테스트 | 본사 | GPS |
| 12 | GPS_QR테스트 | 강남지점 | GPS_QR |
| 21 | WiFi테스트 | 여의도지점 | WIFI |
| 22 | WiFi_QR테스트 | 판교지점 | WIFI_QR |
| 31 | NFC테스트 | 을지로지점 | NFC |
| 32 | NFC_GPS테스트 | 종로지점 | NFC_GPS |
| 33 | NFC마포테스트 | 마포지점 | NFC |
| 34 | NFC테스트2 | 을지로지점 | NFC |
| 41 | 비콘테스트1 | 비콘1 테스트지점 | BEACON |
| 42 | 비콘테스트2 | 비콘2 테스트지점 | BEACON |
| 43 | 비콘GPS테스트 | 잠실지점 | BEACON_GPS |

### 관리자 계정

| username | name |
|----------|------|
| admin | 관리자 |
| testadmin | 테스트관리자 |

### 비콘 설정 (실제 디바이스)

| 근무지 | UUID | Major | Minor | RSSI |
|--------|------|-------|-------|------|
| 비콘1 테스트지점 | E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 | 40011 | 57342 | -80 |
| 비콘2 테스트지점 | E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 | 40011 | 52014 | -80 |
| 잠실지점 (BEACON_GPS) | E2C56DB5-DFFB-48D2-B060-D0F5A71096E0 | 40011 | 57342 | -80 |

---

## 사용 라이브러리

### 백엔드 (Kotlin/Spring Boot)

| 라이브러리 | 버전 | 용도 |
|-----------|------|------|
| Spring Boot Starter Web | 3.2.5 | REST API 프레임워크 |
| Spring Boot Starter Data JPA | 3.2.5 | ORM / DB 접근 |
| Spring Security Crypto | - | BCrypt 비밀번호 해싱 |
| hypersistence-utils-hibernate-63 | 3.7.3 | PostgreSQL JSONB 지원 |
| jjwt-api / jjwt-impl / jjwt-jackson | 0.12.5 | JWT 토큰 생성/검증 |
| Jackson (SNAKE_CASE) | - | JSON 직렬화 |
| PostgreSQL Driver | - | DB 드라이버 |

### Flutter 앱

| 카테고리 | 패키지 | 버전 | 용도 |
|----------|--------|------|------|
| 상태관리 | flutter_bloc | ^9.1.1 | BLoC 패턴 |
| DI | get_it + injectable | ^9.2.1 / ^2.5.0 | 의존성 주입 |
| 네트워크 | dio | ^5.7.0 | HTTP 클라이언트 |
| 네트워크 | retrofit | ^4.9.2 | 타입-안전 API |
| 저장소 | shared_preferences | ^2.3.4 | 로컬 키-값 저장 |
| 라우팅 | go_router | ^17.2.0 | 선언적 라우팅 |
| 데이터 | freezed_annotation | ^3.1.0 | 불변 데이터 클래스 |
| 데이터 | json_annotation | ^4.9.0 | JSON 직렬화 |
| GPS | geolocator | ^14.0.2 | GPS 위치 획득 |
| QR | mobile_scanner | ^7.2.0 | QR 코드 스캔 |
| NFC | nfc_manager | ^4.1.0 | NFC 태그 읽기 |
| BLE | flutter_blue_plus | ^2.2.1 | Android BLE 스캔 |
| BLE | dchs_flutter_beacon | ^0.6.2 | iOS iBeacon 레인징 |
| WiFi | network_info_plus | ^7.0.0 | WiFi SSID/BSSID |
| UI | flutter_screenutil | ^5.9.3 | 반응형 레이아웃 (`.sp`, `.w`, `.h`, `.r`) |
| UI | flutter_svg | ^2.0.10+1 | SVG 렌더링 |
| UI | lottie | ^3.3.2 | 애니메이션 |
| 지도 | kakao_map_sdk | ^1.2.4 | 카카오맵 |
| 지도 | geocoding | ^4.0.0 | 주소 ↔ 좌표 변환 |

### Admin Web

| 패키지 | 버전 | 용도 |
|--------|------|------|
| dio | ^5.4.0 | HTTP 클라이언트 |
| intl | ^0.19.0 | 날짜 포맷팅 |
| qr_flutter | ^4.1.0 | QR 코드 렌더링 |

---

## MVP 제한사항

| 항목 | 현재 상태 | 비고 |
|------|----------|------|
| companyId | 하드코딩 (1) | 멀티 회사 미지원 |
| 비밀번호 변경 | 미구현 | API/UI 모두 없음 |
| 직원 삭제/비활성화 | 미구현 | isActive 필드 존재, 토글 UI 없음 |
| 출퇴근 승인/반려 | 미구현 | status 항상 PENDING |
| 관리자 계정 관리 | 미구현 | seed 데이터로만 생성 |
| 비콘 스캔 목록 UI | 미구현 | 인증은 동작하나 발견 비콘 리스트 미표시 (디버그 스캔에서는 확인 가능) |
