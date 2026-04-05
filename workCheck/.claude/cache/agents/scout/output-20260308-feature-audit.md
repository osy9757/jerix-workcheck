# Codebase Report: 전체 기능 구현 완료 여부 검증
Generated: 2026-03-08

## 요약

출퇴근 앱(Flutter), 웹 관리자(Flutter Web), 백엔드(Kotlin Spring Boot), 인프라(Docker) 4개 프로젝트 전체를 코드 레벨에서 검증. 핵심 기능은 대부분 구현 완료. 인프라 일부 누락 항목 존재.

---

## 1. 앱 (Flutter) — attendance_app

### 1-1. 로그인 화면 (login_screen.dart)
- ✅ 구현 완료 (login_screen.dart:124)
  - `dio.post(ApiConstants.login, ...)` 로 실제 API 호출
  - 회사코드/사원번호/비밀번호 3필드
  - 401 → 비밀번호 오류, 403 → 기기 접근 불가 다이얼로그 분기 처리
  - 로그인 성공 시 token, enabled_methods, user.name 로컬 저장

### 1-2. 회원가입 화면 (register_screen.dart)
- ✅ 구현 완료 (register_screen.dart:111)
  - `dio.post(ApiConstants.users, ...)` → POST /api/v1/users 호출
  - companyCode, employeeId, name, password 4필드 전송
  - 비밀번호 불일치 로컬 검증 후 서버 호출

### 1-3. 출퇴근 화면 (attendance_screen.dart)
- ✅ 구현 완료 (attendance_screen.dart:317)
  - BLoC (AttendanceBloc) 연동, BlocConsumer로 상태 구독
  - KakaoMap 연동 — 현위치 마커, 출근지 마커, GPS 반경 원(Polygon) 표시
  - geolocator로 현재 GPS 수집 + geocoding으로 역지오코딩
  - WorkplaceConfig 로드 후 GPS 설정에서 출근지 좌표 파싱
  - ClockRequested 이벤트 → BLoC에서 인증 → 서버 등록 플로우

### 1-4. AttendanceBloc
- ✅ 구현 완료 (attendance_bloc.dart:115)
  - 출퇴근 버튼 → availableMethods 순차 인증 → RegisterAttendanceUseCase 호출
  - 서버 활성 인증 방법과 디바이스 가용 방법 교집합으로 실제 방법 결정
  - NFC expectedTagId 설정 (workplaceConfig에서 추출)

### 1-5. 히스토리 화면 (history_screen.dart)
- ✅ 구현 완료 (history_screen.dart:19)
  - HistoryBloc에 HistoryEvent.started(month:) 이벤트로 월별 API 조회
  - 달력/리스트 뷰 토글, 연/월 휠 피커
  - 날짜 셀 탭 → AttendanceDetailBottomSheet 팝업

### 1-6. QR 스캔 화면 (qr_scan_screen.dart)
- ✅ 구현 완료 (qr_scan_screen.dart:21)
  - MobileScannerController(DetectionSpeed.normal, CameraFacing.back)
  - onDetect → rawValue 수신 시 Navigator.pop(true)
  - QrScanOverlay 오버레이 위젯 포함

### 1-7. Settings 화면 (settings_screen.dart)
- ✅ 구현 완료 (settings_screen.dart:35)
  - SharedPreferences로 서버 URL 저장/로드
  - 로그아웃: authLocal.clearAll() 후 /login 이동
  - 앱 버전: 하드코딩 '1.0.0' (패키지 info 미사용 — 경미한 미완)

### 1-8. 권한 관리 (permission_local_datasource.dart + permission_bloc.dart)
- ✅ 구현 완료
  - 위치(GPS/WiFi), nearbyWifiDevices, 카메라(QR), 블루투스 4가지 권한 정의
  - iOS: nearbyWifiDevices skipCheck=true (위치 권한으로 커버)
  - iOS: CoreBluetooth 초기화 (FlutterBluePlus.adapterState.first)
  - iOS: LocalNetwork 권한 브로드캐스트 트리거
  - PermissionBloc: 체크/요청/설정앱 열기 이벤트 처리

### 1-9. 인증 서비스 (verification/)
- ✅ GPS (gps_service.dart:44) — geolocator, 좌표 수집, 10초 타임아웃
- ✅ WiFi (wifi_service.dart:44) — network_info_plus, SSID/BSSID 수집
- ✅ NFC (nfc_service.dart:31) — nfc_manager, NfcTagDialog UI, 로컬 태그 비교
- ✅ Bluetooth/Beacon (bluetooth_service.dart:40) — flutter_blue_plus, iBeacon 파싱 (UUID/Major/Minor/RSSI), 5초 스캔
- ✅ QR (qr_service.dart:72) — mobile_scanner, Completer 패턴, 30초 타임아웃
- ✅ VerificationManager (verification_manager.dart:51) — 단일+복합 인증 디스패치

---

## 2. 웹 관리자 (Flutter Web) — admin_web

### 구조
```
lib/
  main.dart
  models/models.dart
  services/api_service.dart    # 모든 API 호출 집중
  pages/
    login_page.dart
    dashboard_page.dart
    verification_page.dart
    attendance_page.dart
    employees_page.dart
    workplaces_page.dart
```

### 2-1. 로그인 화면 (login_page.dart)
- ✅ 구현 완료 (login_page.dart:32)
  - apiService.login(username, password) → POST /api/v1/admin/login
  - localStorage에 JWT 토큰 저장

### 2-2. 대시보드 (dashboard_page.dart)
- ✅ 구현 완료 (dashboard_page.dart:34)
  - 활성 인증 방법 수 카드 (API 호출)
  - 사이드바 NavigationRail로 5개 탭 전환

### 2-3. 인증 설정 관리 (verification_page.dart)
- ✅ 구현 완료 (verification_page.dart:66)
  - 근무지 드롭다운 선택 → 근무지별 인증 방법 목록 조회
  - ON/OFF Switch 토글 → PUT /api/v1/workplaces/{id}/verification-methods/{methodId}
  - 설정값 편집 다이얼로그 (radius_meters, ssid, bssid, tag_id, uuid, major, minor, rssi_threshold, qr_code)
  - GPS 방법: 좌표 필드 숨김 + 안내 메시지 표시

### 2-4. 출퇴근 기록 조회 (attendance_page.dart)
- ✅ 구현 완료 (attendance_page.dart:41)
  - GET /api/v1/attendance/history?from=&to= 호출
  - 날짜 범위 DateRangePicker
  - DataTable: 날짜/출근/퇴근/인증방법/상태

### 2-5. 직원 관리 (employees_page.dart)
- ✅ 구현 완료 (employees_page.dart:131)
  - 직원 등록: POST /api/v1/users
  - 근무지 배정: PUT /api/v1/users/{id}/workplace
  - 유저별 인증 오버라이드: PUT /users/{id}/verification-overrides
  - 오버라이드 삭제(기본값 복귀): DELETE /users/{id}/verification-overrides/{methodType}
  - _OverrideDialog: ON/OFF 토글 + 기본값 복귀 버튼

### 2-6. 근무지 관리 (workplaces_page.dart)
- ✅ 구현 완료 (workplaces_page.dart:34)
  - CRUD: GET/POST /api/v1/workplaces, PUT/DELETE /api/v1/workplaces/{id}
  - 위도/경도 입력 포함
  - QR 코드 모달: 실제 QR(서버) + 테스트용 랜덤 QR 나란히 표시
  - QR 재생성: PUT /api/v1/workplaces/{id}/qr-code

---

## 3. 백엔드 (Kotlin Spring Boot) — 전체 엔드포인트 목록

### AuthController (/api/v1/auth)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| POST | /login | ✅ AuthService.login() — BCrypt 검증, JWT 발급, enabled_methods 반환 |

### AttendanceController (/api/v1/attendance)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| POST | /clock-in | ✅ AttendanceService.clockIn() — 중복 출근 체크, 인증 검증, DB 저장 |
| POST | /clock-out | ✅ AttendanceService.clockOut() — 중복 퇴근 체크, 인증 검증, DB 저장 |
| GET | /today | ✅ AttendanceService.getTodayStatus() — KST 기준 오늘 출퇴근 조회 |
| GET | /history | ✅ AttendanceService.getHistory() — 기간별 날짜 그룹핑 |

### UserController (/api/v1/users)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| GET | / | ✅ UserService.getUsers() |
| POST | / | ✅ UserService.createUser() — BCrypt 해시, 중복 체크 |
| PUT | /{userId}/workplace | ✅ UserService.assignWorkplace() |
| GET | /{userId}/verification-methods | ✅ VerificationService.getUserVerificationMethods() — 오버라이드 머지 |
| PUT | /{userId}/verification-overrides | ✅ UserService.setUserVerificationOverride() |
| DELETE | /{userId}/verification-overrides/{methodType} | ✅ UserService.deleteUserVerificationOverride() |

### VerificationController (/api/v1/verification)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| GET | /methods | ✅ VerificationService.getMethodsByWorkplace(1L) |
| GET | /methods/{id} | ✅ VerificationService.getMethod() |
| PUT | /methods/{id} | ✅ VerificationService.updateMethod() — enabled 토글, config 수정 |

### WorkplaceController (/api/v1/workplaces)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| GET | / | ✅ WorkplaceService.getWorkplaces() |
| POST | / | ✅ WorkplaceService.createWorkplace() — 8가지 인증 방법 자동 생성 |
| PUT | /{id} | ✅ WorkplaceService.updateWorkplace() |
| DELETE | /{id} | ✅ WorkplaceService.deleteWorkplace() — FK 순서 삭제, 사용자/기록 존재 시 거부 |
| GET | /{id}/verification-methods | ✅ VerificationService.getMethodsByWorkplace() |
| PUT | /{id}/verification-methods/{methodId} | ✅ VerificationService.updateMethod() |
| GET | /{id}/config | ✅ WorkplaceService.getWorkplaceConfig() — GPS 좌표 merge |
| GET | /{id}/qr-code | ✅ WorkplaceService.getQrCode() |
| PUT | /{id}/qr-code | ✅ WorkplaceService.regenerateQrCode() |

### WorkplaceConfigController (/api/v1/workplace)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| GET | /config | ✅ WorkplaceService.getWorkplaceConfig(1L) — 앱 호환용 |

### AdminController (/api/v1/admin)
| 메서드 | 경로 | 서비스 로직 |
|--------|------|-------------|
| POST | /login | ✅ AdminService.login() — BCrypt 검증, JWT 발급 |

### VerificationService 검증 로직
- ✅ GPS: Haversine 거리 계산, 근무지 좌표 우선 사용
- ✅ WiFi: BSSID 우선, SSID fallback (대소문자 무시)
- ✅ NFC: tag_id 정확 일치
- ✅ Beacon: UUID/Major/Minor + RSSI 임계값
- ✅ QR: qr_data == qr_code 정확 일치
- ✅ 복합 인증: GPS+QR, WiFi+QR, NFC+GPS, Beacon+GPS 모두 && 로직
- ✅ 유저 오버라이드 반영: 근무지 기본 + 오버라이드 머지

---

## 4. 인프라

### docker-compose.yml (workCheck_backend/docker-compose.yml)
- ✅ db 서비스 — postgres:16-alpine, healthcheck, volume 마운트
- ✅ api 서비스 — Spring Boot, db 의존성(service_healthy 조건)
- ⚠️ web 서비스 누락 — admin_web 컨테이너 정의 없음 (별도 Dockerfile은 존재)

### nginx (admin_web/nginx.conf)
- ✅ SPA 라우팅 설정 (try_files → index.html)
- ✅ /api/ → http://api:8080/api/ 프록시
- ✅ 정적 파일 캐시 설정 (1y)

### Dockerfile
- ✅ admin_web/Dockerfile — 존재 확인
- ✅ workCheck_backend/Dockerfile — 존재 확인

### DB 초기화 SQL
- ✅ schema.sql — 8개 테이블, ENUM 타입, 인덱스 2개 정의
- ✅ seed.sql — 회사/근무지/직원4명/관리자/인증방법8개/설정값8개/테스트 출퇴근기록

---

## 요약 테이블

| 항목 | 상태 | 비고 |
|------|------|------|
| 앱 - 로그인 | ✅ 구현 완료 | API 호출, 토큰/방법 저장, 에러 분기 |
| 앱 - 회원가입 | ✅ 구현 완료 | POST /api/v1/users 호출 |
| 앱 - 출퇴근 화면 | ✅ 구현 완료 | BLoC, KakaoMap, GPS, 인증 플로우 |
| 앱 - 히스토리 | ✅ 구현 완료 | API 조회, 달력/리스트 뷰 |
| 앱 - QR 스캔 | ✅ 구현 완료 | MobileScanner 연동 |
| 앱 - Settings | ⚠️ 부분 구현 | 버전 하드코딩 '1.0.0' (package_info 미사용) |
| 앱 - 권한 관리 | ✅ 구현 완료 | 위치/WiFi/카메라/블루투스, iOS 특수처리 |
| 앱 - GPS 인증 | ✅ 구현 완료 | 좌표 수집, 10초 타임아웃 |
| 앱 - WiFi 인증 | ✅ 구현 완료 | SSID/BSSID 수집 |
| 앱 - NFC 인증 | ✅ 구현 완료 | 태그 스캔 UI, 로컬 비교 |
| 앱 - Beacon 인증 | ✅ 구현 완료 | iBeacon 파싱, UUID/Major/Minor/RSSI |
| 앱 - QR 인증 서비스 | ✅ 구현 완료 | Completer 패턴, 30초 타임아웃 |
| 웹 - 로그인 | ✅ 구현 완료 | POST /api/v1/admin/login |
| 웹 - 대시보드 | ✅ 구현 완료 | 활성 인증 방법 수 표시 |
| 웹 - 인증 설정 | ✅ 구현 완료 | 근무지별 ON/OFF 토글, 설정 편집 |
| 웹 - 출퇴근 기록 | ✅ 구현 완료 | 기간 조회, DataTable |
| 웹 - 직원 관리 | ✅ 구현 완료 | 등록/근무지 배정/인증 오버라이드 |
| 웹 - 근무지 관리 | ✅ 구현 완료 | CRUD, QR 모달, QR 재생성 |
| 백엔드 - AuthController | ✅ 구현 완료 | POST /login |
| 백엔드 - AttendanceController | ✅ 구현 완료 | 4개 엔드포인트 |
| 백엔드 - UserController | ✅ 구현 완료 | 6개 엔드포인트 |
| 백엔드 - VerificationController | ✅ 구현 완료 | 3개 엔드포인트 |
| 백엔드 - WorkplaceController | ✅ 구현 완료 | 9개 엔드포인트 |
| 백엔드 - WorkplaceConfigController | ✅ 구현 완료 | 1개 엔드포인트 |
| 백엔드 - AdminController | ✅ 구현 완료 | 1개 엔드포인트 |
| 백엔드 - 인증 검증 로직 | ✅ 구현 완료 | 8가지 방법 모두 구현 |
| 인프라 - docker-compose | ⚠️ 부분 구현 | api+db만 있음, web 컨테이너 누락 |
| 인프라 - nginx | ✅ 구현 완료 | SPA + /api/ 프록시 |
| 인프라 - Dockerfile (api) | ✅ 구현 완료 | |
| 인프라 - Dockerfile (web) | ✅ 구현 완료 | |
| 인프라 - schema.sql | ✅ 구현 완료 | 8테이블, ENUM, 인덱스 |
| 인프라 - seed.sql | ✅ 구현 완료 | 완전한 테스트 데이터 |

## 미완/개선 필요 항목 (2건)

1. **Settings 화면 앱 버전**: `settings_screen.dart:254` — '1.0.0' 하드코딩. `package_info_plus` 패키지로 실제 버전 읽어야 정확. 기능 동작에 영향 없음.

2. **docker-compose.yml web 서비스 누락**: `workCheck_backend/docker-compose.yml` — api, db 서비스만 정의되어 있고 admin_web 컨테이너가 없음. admin_web/Dockerfile과 nginx.conf는 존재하지만 compose에 연결 안 됨. web 컨테이너를 별도로 실행해야 하는 상태.

