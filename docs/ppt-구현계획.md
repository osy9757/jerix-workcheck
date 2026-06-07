# PPT 기획서 vs 현재 구현 — 비교 및 구현 계획

> 출처: `Downloads/촐퇴근 - 근태관리.pptx` (slide 1~11)
> 작성일: 2026-06-06 · 기준 커밋: `99f80b3` (PPT 기반 인증 리팩토링)
> 검증 방식: 5개 영역을 DB→Backend→App→Admin 전 계층 파일 직접 읽기로 교차 확인

## 결론 (한 줄)

PPT slide 1~5(인증 설정 / 지도 / AND 결합)는 최근 리팩토링에서 **대부분 반영**됨.
**근무지(다중장소) 모델은 의도적으로 폐기 → 본 계획에서 제외(확정).**
가장 큰 미적용 덩어리는 **slide 6~11 "휴대폰 기기(IMEI) 등록·승인 로그인 flow"** — DB·백엔드·앱·Admin 전 계층이 거의 비어 있음.

---

## 1. 적용/미적용 분류

### ✅ A4 인증수단 AND 결합 (slide 4) — 완전 적용
| 요구 | 상태 | 근거 |
|---|---|---|
| 여러 수단 AND 결합(모두 통과해야 성공) | ✅ | `VerificationService.kt:49-66` verifyAll fail-fast 루프 |
| 부분 통과 거부 / 즉시 에러 | ✅ | errorCode 직렬화 + 앱 BLoC 순차수행 early-return |
| init→submit 2단계 다중수단 처리 | ✅ | AttendanceController 4 엔드포인트 |

### 🟢 A2 인증수단별 설정 (slide 2,5) — 대부분 적용
| 요구 | 상태 | 비고 |
|---|---|---|
| GPS 좌표+반경 / WiFi BSSID·IP 택1 / 비콘 distance+txPower→RSSI 환산 | ✅ | `UserService.kt:136` RSSI 자동환산, WiFi `identifier_type` 라디오 |
| QR 이미지 **보기** | ✅ | `verification_page.dart` QrImageView (PPT "생성 안됨" 지적은 이미 해결) |
| QR 이미지 **export/다운로드** | 🟡→구현 | 미리보기만 가능 → **본 작업에서 PNG 다운로드 추가** |
| NFC 세기/거리 설정 | ⚪→안내 | NFC는 물리적 근접통신 → 세기 개념 불가, tag UID 매칭으로 대체. **안내문구 추가** |

### 🟢 A3 지도 UI (slide 3,5) — 대부분 적용
| 요구 | 상태 | 비고 |
|---|---|---|
| 앱: 현재위치 중앙+마커+반경원 | ✅ | `attendance_screen.dart` |
| Admin: 지도 위치선택 + 반경 슬라이더 | ✅/⚪ | `gps_picker_dialog.dart` — PPT의 "드래그→중심버튼"이 아닌 탭 방식(기능 동등) |
| 앱: 지도 움직여 [B]버튼으로 중심 선택 | ❌ | 앱은 표시 전용. **범위 확인 후 결정** |

### ⛔ A1 근무지 다중장소 모델 (slide 1) — **폐기 확정 (계획 제외)**
- 리팩토링 시 "근무지 폐기 → user당 5개 토글 단일세트"로 단순화함.
- `schema.sql:80` UNIQUE(user_id, method_type) — user당 method별 단 1행, workplace 테이블/개념 전 계층 제거됨.
- **의사결정 완료:** PPT의 다중장소 요구는 채택하지 않음. 현행 단일세트 모델 유지.
- 참고: "어느 장소에서든 출퇴근"은 같은 method 내 `targets[]` OR 배열로 부분 대체됨.

### 🔴 A5 휴대폰 기기등록 & IMEI 로그인 (slide 6~11) — 거의 미적용
| 요구 | 상태 | 근거 |
|---|---|---|
| 로그인 UI(회사코드+사번+비번) / 비번 설정 / 인사정보 1차검증 | ✅ | `login_screen.dart`, `register_screen.dart`, `AuthService.kt:22-58` |
| 권한 게이트(위치/카메라/블루투스) 미동의시 차단 | 🟡 부분 | 핵심 3권한 차단되나 WiFi skip, NFC 미정의 |
| 기기 불일치시 "관리자 요청" 버튼 | 🟡 dead code | `login_screen.dart:195` 403 분기 존재하나 백엔드에 403 핸들러 없어 발동 안 됨 |
| 기기등록 DB / IMEI 검증 상태머신 / 자동등록 | ❌ | `user_devices` 테이블·로직 전무 |
| 접속 대기화면 (slide 11) | ❌ | 라우트·화면 없음 |
| 관리자 기기 승인 화면 | ❌ | admin_web에 페이지·API 없음 |

> 기술 제약: iOS는 OS 정책상 실제 IMEI 접근 불가 → **deviceId(Android `androidId` / iOS `identifierForVendor`)로 대체** 권장.

---

## 2. 구현 계획

### 계획 A — 기기 바인딩 (전 계층: DB / Server / App / Admin)

> **확정 사양:** 유저당 APPROVED 기기 **정확히 1대**(재등록 시 교체) · 첫 기기 **자동 승인**, 이후 새 기기 **관리자 승인** · deviceId = **`flutter_udid`**(iOS Keychain UUID `synchronizable=false` 재설치 유지 / Android ANDROID_ID) · **얼굴인증 없음**.
> 멀티에이전트로 4계층을 코드 그라운딩 설계 후 통합 검증 → 계층 간 계약 불일치 8건 교정 완료.

#### 로그인 상태머신 (서버 `AuthService.login`, 자격검증 통과 후 deviceId 동봉)
1. 유저의 APPROVED 기기 **없음**(첫 기기) → 이 deviceId를 APPROVED 자동등록 → 로그인 성공
2. APPROVED 있고 deviceId **일치** → 로그인 성공
3. APPROVED 있고 deviceId **불일치** → `403 DEVICE_NOT_ALLOWED`(deviceStatus=`NONE_MATCH`) → 앱이 "관리자 요청" 노출
4. 요청 시 → 새 deviceId `PENDING` 등록 → 대기화면
5. 관리자 **승인** → PENDING→APPROVED + 기존 APPROVED 폐기(REJECTED 강등, 교체)
6. 관리자 **거부** → REJECTED, 접속 불가 안내
- deviceId 가 null(구버전 앱) → 기기검증 스킵(점진 롤아웃)

#### 🔒 확정된 계층 간 계약 (통합검증 교정 결과)
| 항목 | 확정 |
|---|---|
| 403 본문 키 | **camelCase 리터럴** `{error, errorCode:"DEVICE_NOT_ALLOWED", deviceStatus}` (Map 반환이라 Jackson snake 미적용 — 기존 `errorCode` 컨벤션과 일치) |
| deviceStatus 값 | `NONE_MATCH` \| `PENDING` \| `REJECTED` |
| Admin 목록 응답 | **직접 배열** `List<AdminDeviceResponse>` (presets 컨벤션) — Admin은 `response.data as List`로 파싱 |
| DTO 필드명 | data class라 Jackson **snake_case** 적용 → `employee_name`, `requested_at`, `approved_at` 등. Admin `fromJson`은 `employee_name`(❌`name`) 사용 |
| schema.sql | **단일안** — `requested_at`/`approved_at` 포함, `platform`/`model` 포함(관리자 표시용) |
| device/request 바디 | `password` **포함**(4필드, 인사정보 재검증으로 무단 PENDING 방지) — 앱도 비번 전송 |
| Repository | APPROVED 단건 = `findFirstByUserIdAndStatus`→`UserDevice?`, 목록 = `findByUserIdAndStatus`→`List` |
| approve/reject 반환 | **단일 `AdminDeviceResponse` 객체**(클라가 즉시 행 갱신) |
| DeviceStatus enum | 파일 1개만(`entity/DeviceStatus.kt`) |

#### ① DB 계층
- **`schema.sql`** — `user_devices` 신규 (ENUM 회피 `VARCHAR+CHECK`, uvm 패턴):
  ```sql
  CREATE TABLE user_devices (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,           -- flutter_udid 불투명 식별자
    status VARCHAR(16) NOT NULL DEFAULT 'PENDING'
           CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    platform VARCHAR(16) CHECK (platform IS NULL OR platform IN ('IOS','ANDROID')),
    model VARCHAR(100),
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approved_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, device_id)
  );
  -- 핵심 불변식: 유저당 APPROVED 1대 (부분 유니크 인덱스로 DB 강제)
  CREATE UNIQUE INDEX uq_user_devices_one_approved ON user_devices (user_id) WHERE status='APPROVED';
  CREATE INDEX idx_user_devices_status_requested ON user_devices (status, requested_at ASC);
  CREATE INDEX idx_user_devices_user_status ON user_devices (user_id, status);
  ```
- **`entity/DeviceStatus.kt`** (신규) — `enum class DeviceStatus { PENDING, APPROVED, REJECTED }`
- **`entity/UserDevice.kt`** (신규) — `@Enumerated(STRING) @Column(length=16)` (NAMED_ENUM 금지, validate 일치), `@ManyToOne(LAZY) User`, `@PreUpdate updatedAt`.
- **`repository/UserDeviceRepository.kt`** (신규) — `findByUserIdAndDeviceId`, `findFirstByUserIdAndStatus`, `findByUserIdAndStatus`, `existsByUserIdAndStatus`, `findAllByStatusOrderByRequestedAtAsc`.
- **`seed.sql`** — APPROVED(user1)/PENDING(user1 추가기기·user3)/REJECTED(user5)/0행(user2) 3상태 재현 + setval. ⚠️ seed device_id는 opaque라 실기기와 매칭 안 됨 → 차단/대기열/거부 재현 전용.

#### ② Server 계층 (Kotlin Spring Boot)
- **`dto/request/AppLoginRequest.kt`** (수정) — `deviceId: String? = null` 추가(nullable, NotBlank 미부여).
- **`service/AuthService.kt`** (수정) — `UserDeviceRepository` 주입, `login()` JWT 발급 직전 상태머신 1·2·3 삽입, `requestDeviceAccess()` 추가.
- **`service/DeviceNotAllowedException.kt`** (신규) — `class DeviceNotAllowedException(val deviceStatus:String, message:String): RuntimeException(message)`.
- **`config/GlobalExceptionHandler.kt`** (수정) — `@ExceptionHandler(DeviceNotAllowedException)` → 403, body `{error, errorCode:"DEVICE_NOT_ALLOWED", deviceStatus}`.
- **`dto/request/DeviceAccessRequest.kt`** (신규) — companyCode, employeeId, password, deviceId (모두 NotBlank).
- **`dto/response/DeviceAccessResponse.kt`** (신규) — `status, message`.
- **`dto/response/AdminDeviceResponse.kt`** (신규) — id, userId, employeeId, employeeName, department?, deviceId, status, requestedAt, approvedAt, createdAt, updatedAt (JPQL new-constructor 투영).
- **`controller/AuthController.kt`** (수정) — `POST /api/v1/auth/device/request`.
- **`service/DeviceAdminService.kt`** (신규, `@Transactional`) — `listDevices(status?)`, `approve(id)`(**기존 APPROVED REJECTED 강등→flush→신규 APPROVED 전환** 순서로 부분유니크 인덱스 충돌 회피), `reject(id)`.
- **`controller/AdminController.kt`** (수정) — `GET /admin/devices?status=`, `POST /admin/devices/{id}/approve`, `POST /admin/devices/{id}/reject`.

#### ③ App 계층 (Flutter)
- **`pubspec.yaml`** (수정) — `flutter_udid: ^4.0.0` 추가 → `flutter pub get`.
- **`lib/core/utils/device_id_provider.dart`** (신규, `@lazySingleton`) — `getDeviceId()`: SharedPreferences 캐시 → 없으면 `FlutterUdid.consistentUdid` → 캐시 저장. `build_runner`로 injection.config.dart 재생성.
- **`lib/core/constants/api_constants.dart`** (수정) — `deviceRequest = '$apiPrefix/auth/device/request'`.
- **`lib/features/auth/.../login_screen.dart`** (수정) — `_handleLogin` 전송맵에 `device_id` 추가; **기존 403 분기+DeviceAccessDialog(195-209)** 의 버튼을 `POST /auth/device/request` 호출 + 대기화면 이동으로 연결(현재 dead code 활성화); 'IMEI' 문구 → '기기 ID'.
- **`lib/features/auth/.../device_waiting_screen.dart`** (신규) — 대기 안내 + [요청취소]→로그인복귀 / [재시도]→재로그인. screenutil, #2DDAA9.
- **`lib/presentation/navigation/app_router.dart`** (수정) — `deviceWaiting='/device-waiting'` 라우트.

#### ④ Admin-Web 계층 (Flutter Web)
- **`lib/models/models.dart`** (수정) — `DeviceRequest` 모델(`fromJson`: `employee_name`, `requested_at`, `approved_at`).
- **`lib/services/api_service.dart`** (수정) — `getDeviceRequests({status})`(응답 `as List`), `approveDevice(id)`, `rejectDevice(id)`.
- **`lib/pages/device_requests_page.dart`** (신규) — employees_page 패턴 미러. 컬럼: 사번/이름/기기ID/요청일/상태 + 승인·거부 버튼, 상태 필터, 액션 후 새로고침.
- **`lib/pages/dashboard_page.dart`** (수정) — NavigationRail '기기 승인'(Icons.phone_android) + `_buildPage()` case 추가.

#### API 엔드포인트 요약
| Method | Path | 요청 | 응답 |
|---|---|---|---|
| POST | `/api/v1/auth/login` | + `device_id?` | 200 성공 / **403** `DEVICE_NOT_ALLOWED` |
| POST | `/api/v1/auth/device/request` | company_code, employee_id, password, device_id | 200 `{status:"PENDING", message}` (멱등) |
| GET | `/api/v1/admin/devices?status=` | status? (PENDING/APPROVED/REJECTED) | 200 `AdminDeviceResponse[]` |
| POST | `/api/v1/admin/devices/{id}/approve` | — | 200 `AdminDeviceResponse` (+기존 교체) |
| POST | `/api/v1/admin/devices/{id}/reject` | — | 200 `AdminDeviceResponse` |

#### 빌드 순서
1. **DB** — schema/엔티티/리포/seed → `docker compose down -v && up`(볼륨 리셋 필수, 안 하면 validate 실패)
2. **Server** — 로그인 상태머신 + 403 핸들러 + device/request + admin devices API (이 시점에 앱 403 dead code 활성화)
3. **App ∥ Admin** (병렬) — 앱 deviceId 수집/주입/대기화면 ‖ Admin 승인 화면
4. **통합 E2E** — seed 상태로 전체 기동 시나리오 검증

#### E2E 검증 시나리오
- 자동승인(기기0 유저 첫 로그인→APPROVED 1건) · 일치 재로그인 성공 · 불일치 403 차단 · 요청→PENDING→관리자 승인→교체→새 기기 로그인 성공·기존 기기 403 · 거부→REJECTED 차단 · 부분유니크 인덱스 음성테스트(APPROVED 2건 거부) · 구버전(device_id 없이) 호환

#### ✅ 정책 확정 (2026-06-07)
1. **자동승인 엣지 → 옵션A 확정**: 새 기기(row 없음)만 자동 APPROVED. 이미 `REJECTED`/`PENDING` 이력이 있는 device_id는 자동승급 제외 → 계속 403(deviceStatus=REJECTED/PENDING). "거부"의 의미 보존.
2. **기존 APPROVED 폐기 → REJECTED 강등 확정** (이력 보존, 부분유니크 인덱스 안전).
3. **거부 기기 재요청 → 허용 확정** (REJECTED→PENDING 되돌림, 관리자 재판단).
4. **Admin 기기 API 인증 → MVP 비인증 확정** (현 admin 전체 비인증과 일관). ⚠️ 기기 승인은 대리방지 핵심 게이트라 무방비 노출 → v2에서 인터셉터 확장 권고(admin_web은 이미 토큰 첨부 가능).

### 계획 B — A2/A3 잔여 갭 (근무지 제외)

| 작업 | 우선 | 규모 | 상태 |
|---|---|---|---|
| **A2-QR export** PNG 다운로드 | P1 | S | **본 작업 진행 중** |
| **A2-NFC 세기** 안내문구 | P2 | S | **본 작업 진행 중** |
| A3-앱 지도 위치선택 (B버튼) | P1 | M | 범위 확인 후 (좌표등록은 Admin 담당인데 앱도 필요한가?) |
| A3-Admin 탭→드래그 | P2 | S/0 | 현행 탭 방식 기능 동등 → 수용 권장 |

#### A2-QR export (구현)
- `qr_flutter`의 `QrPainter.toImageData(512)` → PNG ByteData → `dart:html`로 다운로드(파일명: 유저/프리셋명 기반).
- `verification_page.dart` QR 모달 + `verification_presets_page.dart` QR 섹션에 다운로드 버튼. 신규 패키지 불필요(qr_flutter·dart:html 보유).

#### A2-NFC 안내 (구현)
- NFC 카드에 비콘 안내 라벨 스타일 복제: "NFC는 태그 탭 인증으로 세기/거리 설정이 없습니다. 신호세기 기반 인증은 비콘을 사용하세요." (두 파일 모두)

---

## 3. 의사결정 기록

| # | 항목 | 결정 |
|---|---|---|
| 1 | A1 근무지 다중장소 모델 | **폐기 확정** — 현행 user당 단일세트 유지, 계획 제외 |
| 2 | A5 기기 개수 | **유저당 1대 확정** (2026-06-07) — 재등록 시 교체 |
| 3 | A5 기기 승인 정책 | **확정** (2026-06-07) — 첫 기기 자동 승인, 이후 새 기기는 관리자 승인 |
| 4 | A5 deviceId 수집 | **확정** — `flutter_udid`(iOS Keychain UUID 재설치 유지 / Android ANDROID_ID), 얼굴인증 없음 |
| 5 | A5 자동승인 엣지 | **확정** — 옵션A(REJECTED/PENDING 이력 기기는 자동승급 제외, 새 기기만 자동승인) |
| 6 | A5 기존기기 폐기 | **확정** — REJECTED 강등(교체) |
| 7 | A5 Admin API 인증 | **MVP 비인증 확정** (현행 일관, v2 인증 확장) |
| 8 | A3 앱 지도 위치선택 | **미정** — 범위 확인 필요 (좌표등록은 Admin 담당) |

## 4. 진행 상태

- [x] A2-QR export PNG 다운로드 — *본 작업*
- [x] A2-NFC 세기 안내문구 — *본 작업*
- [ ] A3-앱 지도 위치선택 (결정 대기)
- [ ] A5 기기 바인딩 (전 계층) — **계획·정책 전부 확정, 착수 대기**. 순서: DB → Server → (App ∥ Admin) → E2E
