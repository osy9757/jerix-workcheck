# 출퇴근 앱 - Flutter Bloc Clean Architecture

## 실행 방법

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

## 아키텍처 설계

## 핵심 도메인 모델

```
┌──────────────────────────────────────────────────────┐
│                    Attendance                         │
│  - id, userId, type(CLOCK_IN/CLOCK_OUT)              │
│  - timestamp, verificationMethod, verificationData   │
│  - status(PENDING/APPROVED/REJECTED)                 │
└──────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────┐
│              VerificationMethod (Strategy)            │
│  - GPS: lat/lng + 허용 반경 체크                       │
│  - QR:  QR 데이터 디코딩 + 서버 검증                    │
│  - NFC: 태그 ID 읽기 + 서버 검증                       │
│  - Bluetooth: 비콘 UUID 감지 + 매칭                    │
│  - WiFi: SSID/BSSID 매칭                             │
└──────────────────────────────────────────────────────┘
```

## Feature 구조

```
lib/
├── core/                           # 공통
├── data/                           # 데이터 레이어
├── domain/                         # 도메인 레이어
│
├── features/
│   ├── auth/                       # 로그인/인증
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── attendance/                 # 출퇴근 등록 (메인)
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── screens/
│   │       └── widgets/
│   │
│   ├── verification/               # 인증 방식 (Strategy)
│   │   ├── data/
│   │   │   └── services/           # 각 방식별 구현체
│   │   │       ├── gps_service.dart
│   │   │       ├── qr_service.dart
│   │   │       ├── nfc_service.dart
│   │   │       ├── bluetooth_service.dart
│   │   │       └── wifi_service.dart
│   │   ├── domain/
│   │   │   ├── verification_strategy.dart  # 인터페이스
│   │   │   └── verification_result.dart
│   │   └── presentation/
│   │       └── widgets/            # QR스캐너, NFC리더 등 UI
│   │
│   └── history/                    # 출퇴근 기록 조회
│       ├── data/
│       ├── domain/
│       └── presentation/
│
└── presentation/                   # 공통 UI (네비게이션, 위젯)
```

## 데이터 플로우

```
[버튼 클릭]
    │
    ▼
[AttendanceBloc] ── ClockInRequested Event
    │
    ▼
[VerificationStrategy.verify()]  ← GPS/QR/NFC/BT/WiFi 중 선택
    │
    ├─ Success(VerificationResult)
    │       │
    │       ▼
    │   [RegisterAttendanceUseCase]
    │       │
    │       ▼
    │   [AttendanceRepository → API 호출]
    │       │
    │       ▼
    │   [AttendanceState.success]
    │
    └─ Failure
            │
            ▼
        [AttendanceState.verificationFailed]
```

## API 엔드포인트 (Spring Boot 참고용)

```
POST   /api/v1/attendance/clock-in     # 출근
POST   /api/v1/attendance/clock-out    # 퇴근
GET    /api/v1/attendance/today        # 오늘 출퇴근 상태
GET    /api/v1/attendance/history      # 기록 조회
GET    /api/v1/workplace/config        # 근무지 설정 (GPS좌표, WiFi SSID 등)
```
