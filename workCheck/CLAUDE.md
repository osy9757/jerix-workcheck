# 출퇴근 앱 - 개발 컨벤션

## 프로젝트 정보
- Flutter Bloc Clean Architecture
- 상태관리: flutter_bloc
- 메인 컬러: #2DDAA9
- 폰트: Pretendard (로컬 TTF)

## UI 컨벤션
- 최대한 컴포넌트화하여 진행
- 화면 구현 시 기존 위젯 재사용 가능 여부 먼저 체크
- 공통 위젯: `lib/presentation/common_widgets/`
- Feature 전용 위젯: `lib/features/{name}/presentation/widgets/`
- 고정 px 금지, flutter_screenutil 사용하여 비율 기반으로 구현
  - 폰트: `.sp`, 너비: `.w`, 높이: `.h`, 반지름: `.r`

## Feature 구조
각 feature는 Clean Architecture 레이어를 따름:
```
features/{name}/
├── data/       (datasources, models, repositories)
├── domain/     (entities, repositories, usecases)
└── presentation/ (bloc, screens, widgets)
```

## 커밋
- Co-Authored-By 라인 절대 추가하지 않음
- 커밋 메시지에 Claude/AI 관련 표시 없이 작성

---

## 코딩 규칙
- **MVP 우선**: 최소 기능 구현, 과도한 추상화/설계 금지
- **한국어 주석**: 모든 코드에 간단한 한국어 주석 작성
- **테스트 가능성**: 설정값을 변경하며 기능 테스트 가능하게 구현

---

# 기능 개발 팀 워크플로우

## 목표 (MVP)
1. 앱 Beacon 기능 완성
2. MVP 백엔드 + DB (전체 인증 기능 테스트용)
3. 관리자 웹페이지 (Flutter Web) - 설정 변경하며 테스트
4. Docker Compose로 서버 환경 구성

## 인증 방법 (8가지)
| # | 방법 | 설정값 |
|---|------|--------|
| 1 | GPS | 좌표, 반경(m) |
| 2 | GPS + QR | 좌표, 반경, QR코드 |
| 3 | WiFi | SSID, BSSID |
| 4 | WiFi + QR | SSID, BSSID, QR코드 |
| 5 | NFC | 태그 ID |
| 6 | NFC + GPS | 태그 ID, 좌표, 반경 |
| 7 | Beacon | UUID, Major, Minor, RSSI |
| 8 | Beacon + GPS | UUID, Major, Minor, RSSI, 좌표, 반경 |

## 팀 구성

| 역할 | Agent Type | 담당 |
|------|-----------|------|
| **team-lead** | 메인 컨텍스트 | 조율, 태스크 할당 |
| **researcher** | scout | 앱 전체 인증 기능 현황 분석 |
| **architect** | architect | 시스템 아키텍처 + API 스펙 |
| **db-designer** | architect | 전체 DB 스키마 설계 |
| **flutter-dev** | kraken | Beacon 완성 + 앱 API 연동 |
| **backend-dev** | kraken | Kotlin Spring Boot API 서버 |
| **web-dev** | kraken | 관리자 웹페이지 (Flutter Web) |
| **tester** | arbiter | MVP 통합 테스트 |

## 워크플로우

```
Phase 1: 분석 & 설계 (병렬)
  ├─ researcher → 8가지 인증 방법별 앱 완성도 파악
  ├─ architect → 전체 시스템 설계
  │   ├─ Docker Compose 구성 (api / db / web)
  │   ├─ API 엔드포인트 정의
  │   └─ 인증 방법별 설정 구조
  └─ db-designer → 전체 DB 스키마 설계
      ├─ users (사용자/직원)
      ├─ attendance_records (출퇴근 기록)
      ├─ verification_methods (8가지 인증 방법)
      ├─ verification_configs (방법별 설정값)
      ├─ company_settings (회사별 활성 인증 방법)
      └─ admin_users (관리자)

Phase 2: 인프라 구축 (Phase 1 완료 후)
  ├─ backend-dev → Docker Compose + API 서버 뼈대
  └─ db-designer → DDL + 시드 데이터

Phase 3: 기능 구현 (병렬, Phase 2 완료 후)
  ├─ flutter-dev → Beacon 기능 완성 + API 연동
  ├─ backend-dev → CRUD API (출퇴근, 인증설정, 사용자)
  └─ web-dev → 관리자 웹페이지
      ├─ 인증 방법 ON/OFF 토글
      ├─ 방법별 설정값 편집 (GPS 반경, WiFi SSID, Beacon UUID 등)
      ├─ 출퇴근 기록 조회
      └─ 사용자 관리

Phase 4: 통합 테스트
  └─ tester → 설정 변경 → 앱 인증 → 결과 확인 E2E
```

## 백엔드 컨벤션 (Kotlin Spring Boot)

레이어드 아키텍처: Controller → Service → Repository

```
com.workcheck.backend/
├── controller/    # API 엔드포인트
├── service/       # 비즈니스 로직
├── repository/    # DB 접근 (JPA)
├── entity/        # DB 엔티티
├── dto/           # 요청/응답 DTO
└── config/        # Spring 설정
```

## Docker Compose 구성

```yaml
services:
  api:        # Kotlin Spring Boot (8080)
  db:         # PostgreSQL (5432)
  web:        # Flutter Web + Nginx (3000)
```

## 에이전트별 프롬프트

### researcher (scout)
```
workCheck 프로젝트의 인증 기능 현황을 분석하라.
- lib/features/verification/ 아래 8가지 인증 방법 구현 상태
- 각 방법별 완성도 (완료/부분/미구현)
- 특히 Beacon 기능의 현재 상태와 미완성 부분
- 앱의 API 연동 현황 (하드코딩 vs 실제 API 호출)
```

### architect
```
MVP 수준의 시스템 아키텍처를 설계하라.
- Docker Compose 구성 (api/db/web 컨테이너)
- REST API 엔드포인트 목록 (출퇴근, 인증설정, 사용자)
- 인증 방법 8가지의 설정 구조
- 앱 ↔ 백엔드 ↔ 웹 통신 흐름
- MVP에 집중: 과도한 설계 금지
```

### db-designer (architect)
```
전체 DB 스키마를 설계하라.
- 8가지 인증 방법의 설정값을 모두 커버
- 방법별 설정을 변경하며 테스트 가능한 구조
- users, attendance_records, verification 관련 테이블
- PostgreSQL 기준, MVP에 필요한 테이블만
- DDL + 테스트용 시드 데이터 포함
```

### flutter-dev (kraken)
```
Beacon 기능을 완성하고 API 연동을 구현하라.
- 기존 코드 패턴(Clean Architecture + BLoC) 준수
- flutter_screenutil 사용 (고정 px 금지)
- 한국어 주석 작성
- MVP: 핵심 기능만, 과도한 에러 핸들링 불필요
```

### backend-dev (kraken)
```
Kotlin Spring Boot MVP API 서버를 구현하라.
- 레이어드 아키텍처: Controller → Service → Repository
- Docker Compose 설정 (api + db + web)
- 한국어 주석 작성
- MVP: CRUD 위주, 인증/보안은 최소화
```

### web-dev (kraken)
```
Flutter Web으로 관리자 페이지를 구현하라.
- 인증 방법 8가지의 ON/OFF 토글
- 각 방법별 설정값 편집 폼
- 출퇴근 기록 조회 테이블
- MVP: 기능 동작 우선, 디자인은 최소
- 한국어 주석 작성
```

### tester (arbiter)
```
MVP 통합 테스트를 수행하라.
- 웹에서 설정 변경 → 앱에서 해당 인증 방법 테스트
- 8가지 인증 방법 각각의 기본 동작 확인
- API 응답 정상 여부
- DB 데이터 정합성
```
