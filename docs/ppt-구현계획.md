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

### 계획 A — A5 기기등록·IMEI 로그인 flow (메인, 8단계)

데이터 → 백엔드 → 앱 → Admin 의존 체인 순서.

| # | 작업 | 우선 | 레이어 | 규모 |
|---|---|---|---|---|
| G1 | `user_devices` 테이블 + Entity/Repository (status: PENDING/APPROVED/REJECTED) | P0 | DB | S |
| G2 | 로그인 API에 deviceId 검증 + 자동등록 분기 + **403 errorCode 핸들러** | P0 | Backend | M |
| G3 | 앱 deviceId 수집(`device_info_plus`) + 로그인 연동 + 접속허용 요청 | P0 | App | M |
| G4 | 접속 허용 요청 API (앱→백엔드, PENDING row 생성) | P0 | Backend | S |
| G5 | Admin 기기 승인 관리 화면 + API (목록/승인/거부) | P0 | Admin+BE | M |
| G6 | 권한 동의 게이트 보강 (검증·주석화 위주) | P1 | App | S |
| G7 | 온보딩 이벤트 모달 4종 (기존 DeviceAccessDialog 재사용) | P2 | App | S |
| G8 | 접속 대기 화면 (slide 11) + 라우트 | P1 | App | S |

**권장 순서:** G1 → (G2+G4 백엔드 묶음) → (G3+G8+G7 앱 묶음) ‖ (G5 Admin 병렬) ‖ (G6 독립).
G2 완료 시점에 앱의 기존 403 dead code가 비로소 동작함.

**착수 전 결정 필요:**
- **자동승인 정책** — 첫 기기는 자동 승인(APPROVED)? 항상 관리자 승인 대기(PENDING)? (PPT slide 7의 a/b 분기)

#### G1 — 기기등록 DB
- `schema.sql`에 `user_devices` 테이블: id, user_id FK, device_id, device_label?, status(PENDING/APPROVED/REJECTED), requested_at, decided_at, created/updated_at. UNIQUE(user_id, device_id).
- 인덱스: (user_id, status), (status). status는 VARCHAR+CHECK (ENUM 회피 방침 일관).
- `seed.sql`: user1=APPROVED, user3=PENDING, user5=0행 — 3가지 상태 재현.
- `entity/UserDevice.kt`, `repository/UserDeviceRepository.kt` 신규.

#### G2 — 로그인 기기검증 + 403 핸들러
- `AppLoginRequest.kt`에 `deviceId: String? = null`(점진 롤아웃).
- `AuthService.login()`: 비번/active 검증 직후 deviceId 분기 — 미등록+기기0개→자동등록, APPROVED→통과, PENDING/REJECTED→`DeviceNotAllowedException`.
- `GlobalExceptionHandler`에 403 핸들러 추가(errorCode `DEVICE_NOT_ALLOWED`, deviceStatus 포함) → 앱 403 분기 활성화.

#### G3 — 앱 deviceId 수집 + 연동
- `device_info_plus` 추가, `DeviceIdProvider` 유틸(Android id / iOS identifierForVendor, SharedPreferences 캐시).
- `login_screen` 전송 데이터에 device_id 추가. 403 시 DeviceAccessDialog → 실제 요청 API 호출 → 대기화면 이동.

#### G4 — 접속 허용 요청 API
- `DeviceRequestRequest` DTO, `POST /auth/device/request` → 인사정보 검증 후 PENDING row 생성/멱등 갱신.

#### G5 — Admin 기기 승인 화면 + API
- Backend: `GET/POST /admin/devices[...]` 목록/승인/거부.
- Admin: `device_requests_page.dart`(employees_page 패턴 복제), api_service 메서드 3개, models DeviceRequest, dashboard NavigationRail 메뉴 추가.

#### G6 — 권한 게이트 보강
- 핵심 3권한(위치/카메라/블루투스)은 이미 실질 차단(`permission_dialog.dart:21` barrierDismissible:false) → 검증·주석화 위주.
- WiFi skipCheck는 구단말 데드락 회피 의도 → 유지(주석 명확화). NFC는 런타임 권한 아님 → 게이트 제외(주석).

#### G7 — 온보딩 이벤트 모달 4종
- 신규 위젯 없이 `DeviceAccessDialog`(title/content/buttonText 주입) 재사용 + 문구 분기(정보불일치/기기등록안내/승인·불가/요청취소).

#### G8 — 접속 대기 화면
- `device_waiting_screen.dart` 신규 + `/device-waiting` 라우트. 요청 성공 시 진입, 재시도/요청취소 버튼. (폴링·푸시는 범위 밖, 수동 재시도 — MVP)

---

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
| 2 | A5 기기 자동승인 정책 | **미정** — 착수 전 결정 필요 (첫 기기 자동승인 vs 항상 PENDING) |
| 3 | A3 앱 지도 위치선택 | **미정** — 범위 확인 필요 (좌표등록은 Admin 담당) |

## 4. 진행 상태

- [x] A2-QR export PNG 다운로드 — *본 작업*
- [x] A2-NFC 세기 안내문구 — *본 작업*
- [ ] A3-앱 지도 위치선택 (결정 대기)
- [ ] A5 기기등록·IMEI flow G1~G8 (자동승인 정책 결정 후 착수)
