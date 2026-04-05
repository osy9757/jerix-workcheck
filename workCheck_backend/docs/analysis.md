# workCheck 앱 인증 기능 현황 분석

> 분석 일시: 2026-03-01
> 분석 대상: `/workCheck/attendance_app/lib/`

---

## 1. 전체 요약

| 항목 | 현황 |
|------|------|
| 인증 서비스 수 (구현) | 5개 (gps, qr, nfc, bluetooth, wifi) |
| 복합 인증 전략 | **0개** (8가지 중 조합 방식 전부 미구현) |
| Beacon iBeacon 파싱 | **미구현** (UUID/Major/Minor 없음) |
| API 연동 | **하드코딩** (base URL = `https://api.example.com`) |
| AttendanceScreen ↔ Bloc 연결 | **미연결** (로컬 상태로만 동작) |
| 인증 방법 Enum 항목 수 | 5개 (8가지 조합 미정의) |

---

## 2. 인증 방법 8가지 구현 상태

| # | 방법 | 완성도 | 파일 경로 | 비고 |
|---|------|--------|-----------|------|
| 1 | GPS | ✅ 완료 | `verification/data/services/gps_service.dart` | 단독 서비스 완성 |
| 2 | GPS + QR | ❌ 미구현 | - | 복합 전략 없음 |
| 3 | WiFi | ✅ 완료 | `verification/data/services/wifi_service.dart` | 단독 서비스 완성 |
| 4 | WiFi + QR | ❌ 미구현 | - | 복합 전략 없음 |
| 5 | NFC | ✅ 완료 | `verification/data/services/nfc_service.dart` | 단독 서비스 완성 |
| 6 | NFC + GPS | ❌ 미구현 | - | 복합 전략 없음 |
| 7 | Beacon | ⚠️ 부분 | `verification/data/services/bluetooth_service.dart` | BLE 스캔만, iBeacon 미구현 |
| 8 | Beacon + GPS | ❌ 미구현 | - | Beacon 자체 미완성 + 복합 전략 없음 |

---

## 3. 각 인증 서비스 상세 분석

### 3.1 GPS (`gps_service.dart`) - ✅ 완료

**파일:** `lib/features/verification/data/services/gps_service.dart`

**구현 내용:**
- `geolocator` 패키지로 현재 위치 취득
- 위치 권한 요청 (`whileInUse` / `always`)
- 10초 타임아웃
- 반환 데이터: `latitude`, `longitude`, `accuracy`, `timestamp`

**미완성 부분:**
- 서버에서 받은 허용 좌표/반경과 비교하는 로직 없음 (서버 측 검증 필요)

---

### 3.2 QR (`qr_service.dart`) - ⚠️ 부분 완료

**파일:** `lib/features/verification/data/services/qr_service.dart`

**구현 내용:**
- `mobile_scanner` 패키지 사용
- `createController()` / `onDetect()` UI 통합용 API 제공
- `verify()` 는 Completer 패턴으로 스캔 결과 대기
- 반환 데이터: `qr_data`, `format`, `timestamp`

**미완성 부분:**
- `verify()` 단독 호출 시 QR 스캔 화면 띄우는 로직 없음 (UI와의 연결 필요)
- 서버에서 받은 예상 QR 코드 값과 비교 없음

---

### 3.3 WiFi (`wifi_service.dart`) - ✅ 완료 (단독)

**파일:** `lib/features/verification/data/services/wifi_service.dart`

**구현 내용:**
- `network_info_plus` 패키지 사용
- SSID, BSSID, IP 주소 취득
- 위치 권한 요청 (Android에서 WiFi SSID 접근에 필요)
- 반환 데이터: `ssid`, `bssid`, `ip`, `timestamp`

**미완성 부분:**
- 서버 설정값(SSID/BSSID)과 비교 로직 없음 (서버 측 검증 필요)

---

### 3.4 NFC (`nfc_service.dart`) - ✅ 완료 (단독)

**파일:** `lib/features/verification/data/services/nfc_service.dart`

**구현 내용:**
- `nfc_manager` 패키지 사용
- ISO 14443/15693/18092 폴링 지원
- NFC-A/B/F/V 및 ISO-DEP identifier 파싱
- 태그 ID를 16진수 문자열로 변환 (예: `a1:b2:c3:d4`)
- 30초 타임아웃
- 반환 데이터: `tag_id`, `tag_data`, `timestamp`

**미완성 부분:**
- 서버 등록 태그 ID와 비교 로직 없음 (서버 측 검증 필요)

---

### 3.5 Bluetooth/Beacon (`bluetooth_service.dart`) - ⚠️ 부분 구현 (핵심 미완성)

**파일:** `lib/features/verification/data/services/bluetooth_service.dart`

**구현 내용:**
- `flutter_blue_plus` 패키지로 5초간 BLE 스캔
- 주변 모든 BLE 기기 탐지
- 반환 데이터: `detected_devices` (device_id, device_name, rssi), `device_count`, `timestamp`

**핵심 미완성 부분 (Beacon 인증을 위해 필수):**

1. **iBeacon 프로토콜 파싱 없음**
   - `flutter_blue_plus`는 일반 BLE 스캔만 지원
   - iBeacon UUID / Major / Minor 값 파싱 불가
   - `flutter_beacon` 패키지 도입 필요

2. **UUID/Major/Minor 매칭 로직 없음**
   - 서버 설정값(UUID, Major, Minor)과 스캔 결과 비교 없음

3. **RSSI 임계값 필터링 없음**
   - RSSI 값은 수집하지만 임계값 기준 필터링 없음

4. **Completer 사용 오류 (코드 버그)**
   - `completer` 변수 선언 후 `completer.complete()` 호출 없음 (dead code)
   - 결과를 직접 `return`하고 있어 Completer가 무의미함

---

## 4. VerificationMethod Enum 현황

**파일:** `lib/features/verification/domain/verification_method.dart`

```dart
enum VerificationMethod {
  gps('GPS 위치'),
  qr('QR코드 스캔'),
  nfc('NFC 태그'),
  bluetooth('블루투스 비콘'),
  wifi('WiFi');
}
```

**문제:** 8가지 인증 방법 중 복합 방법 5가지가 정의되지 않음
- `gpsQr` (GPS + QR) - 미정의
- `wifiQr` (WiFi + QR) - 미정의
- `nfcGps` (NFC + GPS) - 미정의
- `beacon` (Beacon 단독, UUID/Major/Minor) - bluetooth와 구분 없음
- `beaconGps` (Beacon + GPS) - 미정의

---

## 5. VerificationManager 현황

**파일:** `lib/features/verification/data/verification_manager.dart`

```dart
VerificationManager({
  @Named('gps') required VerificationStrategy gps,
  @Named('qr') required VerificationStrategy qr,
  @Named('nfc') required VerificationStrategy nfc,
  @Named('bluetooth') required VerificationStrategy bluetooth,
  @Named('wifi') required VerificationStrategy wifi,
})
```

**미완성 부분:**
- 복합 인증 전략(GPS+QR, WiFi+QR, NFC+GPS, Beacon+GPS) 없음
- `verify(method)` 는 단일 전략만 실행 가능
- 복합 전략을 위한 sequential verification 로직 없음

---

## 6. AttendanceScreen 현황

**파일:** `lib/features/attendance/presentation/screens/attendance_screen.dart`

### 6.1 BLoC 미연결 (핵심 문제)

```dart
class _AttendanceScreenState extends State<AttendanceScreen> {
  bool _isClockedIn = false;         // 로컬 상태 (BLoC 미사용)
  DateTime? _clockInTime;            // 로컬 상태
  DateTime? _clockOutTime;           // 로컬 상태
```

- `AttendanceBloc`이 정의되어 있으나 `attendance_screen.dart`에서 사용하지 않음
- `BlocProvider` / `BlocBuilder` 없음

### 6.2 하드코딩된 데이터

| 항목 | 하드코딩 값 |
|------|------------|
| 사용자 이름 | `'안녕하세요 홍길동님'` |
| 출근지 이름 | `'마포대로 자람빌딩'` |
| 출근지 좌표 | `LatLng(37.5419, 126.9498)` |
| 현위치 텍스트 | `'마포대로 자람빌딩'` (고정 문자열) |

### 6.3 인증 방법 하드코딩

```dart
Future<void> _handleClockIn() async {
  final result = await BeaconScanDialog.show(context);  // Beacon만 고정
```

- 버튼 클릭 시 항상 Beacon 스캔만 실행
- 8가지 인증 방법 선택 UI 없음

---

## 7. AttendanceBloc 현황

**파일:** `lib/features/attendance/presentation/bloc/attendance_bloc.dart`

### 완성된 부분 ✅

- Clean Architecture UseCase 패턴 올바르게 적용
- `VerificationManager` 연동 구현
- `RegisterAttendanceUseCase` → `AttendanceRepositoryImpl` → `AttendanceRemoteDataSource` 체인 구현
- 이벤트/상태: `AttendanceStarted`, `AttendanceMethodSelected`, `AttendanceClockRequested`, `AttendanceAvailableMethodsRequested`
- UI 상태: `loading`, `verifying`, `registering`, `success`, `error`

### 미연결 부분 ⚠️

- `AttendanceScreen`에서 이 Bloc을 전혀 사용하지 않음
- `BlocProvider.of<AttendanceBloc>(context)` 연결 필요

---

## 8. API 연동 현황

### 8.1 AttendanceRemoteDataSource

**파일:** `lib/features/attendance/data/datasources/remote/attendance_remote_datasource.dart`

```dart
@RestApi()
abstract class AttendanceRemoteDataSource {
  @POST('/api/v1/attendance/clock-in')
  Future<AttendanceModel> clockIn(@Body() Map<String, dynamic> body);

  @POST('/api/v1/attendance/clock-out')
  Future<AttendanceModel> clockOut(@Body() Map<String, dynamic> body);

  @GET('/api/v1/attendance/today')
  Future<TodayStatusModel> getTodayStatus();
}
```

**상태:** Retrofit 코드 생성 완료, 구조 정상

### 8.2 API 상수

**파일:** `lib/core/constants/api_constants.dart`

```dart
static const String baseUrl = 'https://api.example.com';  // 플레이스홀더!
```

**문제:** 실제 API 서버 미연결, 플레이스홀더 URL 사용

### 8.3 네트워크 설정

**파일:** `lib/core/network/dio_client.dart`

| 항목 | 상태 |
|------|------|
| Base URL | `https://api.example.com` (하드코딩 플레이스홀더) |
| Timeout | 10초 (연결/수신/전송) |
| Auth Interceptor | `TODO: 토큰 주입 로직` (미구현) |
| Log Interceptor | 구현됨 (print 기반) |
| 401 처리 | `TODO: 토큰 갱신 또는 로그아웃` (미구현) |

---

## 9. 전체 구현 현황 요약

```
lib/features/verification/
├── domain/
│   ├── verification_method.dart     ⚠️  5개 enum만 정의 (8가지 미정의)
│   ├── verification_result.dart     ✅  완성
│   └── verification_strategy.dart   ✅  완성
├── data/
│   ├── services/
│   │   ├── gps_service.dart         ✅  완성
│   │   ├── qr_service.dart          ⚠️  UI 연결 미완성
│   │   ├── wifi_service.dart        ✅  완성
│   │   ├── nfc_service.dart         ✅  완성
│   │   └── bluetooth_service.dart   ❌  iBeacon 파싱 없음 (핵심 미완성)
│   └── verification_manager.dart    ⚠️  복합 전략 없음
└── presentation/
    └── widgets/                     (비어있음 - .gitkeep만 존재)

lib/features/attendance/
├── domain/                          ✅  완성 (entities, usecases, repository 인터페이스)
├── data/
│   ├── datasources/remote/          ✅  Retrofit 완성
│   ├── models/                      ✅  freezed 완성
│   └── repositories/                ✅  완성
└── presentation/
    ├── bloc/                        ✅  완성 (미연결 상태)
    ├── screens/
    │   ├── attendance_screen.dart   ❌  BLoC 미연결, 하드코딩, Beacon 전용
    │   ├── qr_scan_screen.dart      (확인 필요)
    │   └── history_screen.dart      (확인 필요)
    └── widgets/                     ✅  대부분 완성 (다이얼로그들)

lib/core/
├── network/dio_client.dart          ⚠️  URL 플레이스홀더, 인증 TODO
└── constants/api_constants.dart     ❌  https://api.example.com 하드코딩
```

---

## 10. 우선순위별 작업 목록

### 🔴 High Priority (Beacon 완성)
1. `bluetooth_service.dart` 재작성
   - `flutter_blue_plus` → `flutter_beacon` 패키지로 교체 또는 추가
   - iBeacon UUID/Major/Minor 파싱 구현
   - RSSI 임계값 필터링 구현
   - UUID/Major/Minor 매칭 로직 구현
   - Completer 버그 수정

2. `verification_method.dart` enum 확장
   - `gpsQr`, `wifiQr`, `nfcGps`, `beaconGps` 추가

### 🔴 High Priority (API 연동)
3. `api_constants.dart` 실제 URL로 교체 (백엔드 개발 후)
4. `dio_client.dart` 인증 토큰 주입 구현
5. `attendance_screen.dart` BLoC 연결
6. `attendance_screen.dart` 하드코딩 제거 (사용자명, 위치 API 연동)

### 🟡 Medium Priority (복합 전략)
7. `VerificationManager`에 복합 전략 추가
   - GPS+QR, WiFi+QR, NFC+GPS, Beacon+GPS 조합 처리

### 🟢 Low Priority
8. QR 스캔 화면과 `QrVerificationService.verify()` 연결 통일
9. 인증 방법 선택 UI 구현 (현재 Beacon 전용으로 고정됨)
