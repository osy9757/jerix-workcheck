-- workCheck MVP - PostgreSQL DDL (v2)
-- 출퇴근 앱 DB 스키마
--
-- v2 변경 사항 (PPT 기반 인증 리팩토링 T1):
--   * workplace(근무지) 개념 제거 — 모든 인증 설정은 user 단위로 직접 보유
--   * method_type 을 5개(GPS/WIFI/NFC/BEACON/QR) 로 축소하고 VARCHAR(16) + CHECK 제약으로 보관
--     (PostgreSQL ENUM 사용 안 함 → ALTER 가 자유롭고 JPA/Jackson 매핑이 단순)
--   * verification_methods / verification_configs / user_verification_overrides 통합
--     → 신규 user_verification_methods 테이블 하나로 단순화
--   * users.workplace_id 컬럼 제거
--   * attendance_records 의 method 참조를 method_type VARCHAR 컬럼으로 단순화

-- ============================================
-- ENUM 타입 (출퇴근용만 잔존)
-- ============================================
CREATE TYPE attendance_type_enum AS ENUM (
    'CLOCK_IN', 'CLOCK_OUT'
);

CREATE TYPE attendance_status_enum AS ENUM (
    'PENDING', 'APPROVED', 'REJECTED'
);

-- ============================================
-- 1. 회사
-- ============================================
CREATE TABLE companies (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    code       VARCHAR(20)   NOT NULL UNIQUE,  -- 앱 로그인 시 사용 (예: "jerix")
    -- [D4] 기기 등록 방식: AUTO=첫 기기 자동등록(a안) / APPROVAL=항상 관리자 승인(b안)
    --   user_devices.status 와 동일한 VARCHAR+CHECK 패턴 (ENUM 회피, ddl-auto=validate 일치)
    device_binding_mode VARCHAR(16) NOT NULL DEFAULT 'AUTO'
                 CHECK (device_binding_mode IN ('AUTO','APPROVAL')),
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================
-- 2. 직원 (앱 사용자)
-- ============================================
-- v2: workplace_id 컬럼 제거. 근무지 개념 폐기.
CREATE TABLE users (
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT        NOT NULL REFERENCES companies(id),
    employee_id   VARCHAR(50)   NOT NULL,          -- 사원번호
    name          VARCHAR(100)  NOT NULL,
    email         VARCHAR(255),
    department    VARCHAR(100),
    -- NULL = 관리자가 인사정보만 등재(미가입), 값 존재 = 앱 회원가입 완료(비밀번호 설정됨)
    password_hash VARCHAR(255),                       -- PIN 해시 (BCrypt), 미가입 시 NULL
    is_active     BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    UNIQUE (company_id, employee_id)               -- 회사 내 사원번호 고유
);

-- ============================================
-- 3. 관리자 (웹 관리 페이지용)
-- ============================================
CREATE TABLE admin_users (
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT        NOT NULL REFERENCES companies(id),
    username      VARCHAR(50)   NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    name          VARCHAR(100)  NOT NULL,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================
-- 4. 유저별 인증 방법 (단일 통합 테이블)
-- ============================================
-- v2 핵심 테이블. 한 유저가 5개 단위 인증 수단(GPS/WIFI/NFC/BEACON/QR) 각각에 대해 토글/설정값을 보유.
-- - 조합(예: GPS+QR, NFC+GPS)은 같은 user 의 여러 row 가 동시에 is_enabled=TRUE 인 상태로 표현.
-- - verify 로직은 enabled 된 모든 row 를 AND 결합으로 검증한다 (T2 에서 구현).
-- - 시드는 직원당 5개 row 를 모두 생성하여 관리자 웹에서 토글만 변경하면 되도록 한다.
CREATE TABLE user_verification_methods (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    method_type VARCHAR(16)  NOT NULL CHECK (method_type IN ('GPS','WIFI','NFC','BEACON','QR')),
    is_enabled  BOOLEAN      NOT NULL DEFAULT FALSE,    -- 토글 (5개 프리셋 토글)
    config_data JSONB        NOT NULL DEFAULT '{}'::jsonb,  -- 방법별 타겟 (targets[] 또는 codes[])
    created_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    UNIQUE (user_id, method_type)                            -- 유저당 방법별 1개
);

CREATE INDEX idx_uvm_user_enabled
    ON user_verification_methods (user_id, is_enabled);

-- ============================================
-- 5. 출퇴근 기록
-- ============================================
-- v2: verification_method_id (FK) 제거 → method_type VARCHAR 컬럼으로 단순화.
--     기록 시점에 "어떤 방법이 사용됐는지"만 저장하면 충분 (설정 변경 추적은 MVP 범위 외).
CREATE TABLE attendance_records (
    id                 BIGSERIAL PRIMARY KEY,
    user_id            BIGINT                 NOT NULL REFERENCES users(id),
    type               attendance_type_enum   NOT NULL,                       -- CLOCK_IN / CLOCK_OUT
    status             attendance_status_enum NOT NULL DEFAULT 'PENDING',     -- 승인 상태
    method_type        VARCHAR(16)            NOT NULL CHECK (method_type IN ('GPS','WIFI','NFC','BEACON','QR')),
    verification_data  JSONB                  NOT NULL DEFAULT '{}'::jsonb,   -- 앱이 전송한 인증 데이터
    recorded_at        TIMESTAMPTZ            NOT NULL DEFAULT NOW(),         -- 출퇴근 시각
    created_at         TIMESTAMPTZ            NOT NULL DEFAULT NOW()
);

-- 인덱스: 날짜별 출퇴근 조회
CREATE INDEX idx_attendance_user_recorded
    ON attendance_records (user_id, recorded_at DESC);

-- 인덱스: 오늘의 출퇴근 상태 조회 (GET /api/v1/attendance/today)
CREATE INDEX idx_attendance_user_type_recorded
    ON attendance_records (user_id, type, recorded_at DESC);

-- ============================================
-- 6. 인증 프리셋 (글로벌 카탈로그)
-- ============================================
-- 자주 쓰이는 NFC/WiFi/GPS/Beacon/QR 설정값을 이름 붙여 저장하여 재사용.
-- 회사/유저 종속 아님 - 관리자가 카탈로그처럼 관리하여 user_verification_methods 편집 시 끼워넣음.
-- config_data 키는 user_verification_methods 와 동일 (lat/lng/radius_m, identifier_type/value, distance_m/tx_power 등).
CREATE TABLE verification_presets (
    id          BIGSERIAL PRIMARY KEY,
    name        VARCHAR(100)  NOT NULL,
    method_type VARCHAR(16)   NOT NULL CHECK (method_type IN ('GPS','WIFI','NFC','BEACON','QR')),
    config_data JSONB         NOT NULL DEFAULT '{}'::jsonb,
    memo        TEXT,
    created_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 인덱스: 인증 방법별 프리셋 필터링
CREATE INDEX idx_verification_presets_method_type
    ON verification_presets (method_type);

-- ============================================
-- 7. 기기 바인딩 (대리 출퇴근 방지)
-- ============================================
-- 유저당 APPROVED(승인) 기기 정확히 1대만 허용 → 다른 기기로 로그인 시 403 차단.
-- 첫 기기는 자동 승인, 이후 새 기기는 관리자 승인 필요.
--   * status 는 ENUM 회피: VARCHAR(16) + CHECK (uvm 패턴과 동일, JPA validate 일치)
--   * device_id 는 flutter_udid 불투명 식별자 (iOS Keychain UUID / Android ANDROID_ID)
--   * platform/model 은 관리자 화면 표시용 (선택)
CREATE TABLE user_devices (
    id           BIGSERIAL    PRIMARY KEY,
    user_id      BIGINT       NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id    VARCHAR(255) NOT NULL,                      -- flutter_udid 불투명 식별자
    status       VARCHAR(16)  NOT NULL DEFAULT 'PENDING'
                 CHECK (status IN ('PENDING','APPROVED','REJECTED')),
    platform     VARCHAR(16)  CHECK (platform IS NULL OR platform IN ('IOS','ANDROID')),
    model        VARCHAR(100),
    requested_at TIMESTAMPTZ  NOT NULL DEFAULT NOW(),         -- 등록/요청 시각
    approved_at  TIMESTAMPTZ,                                 -- 승인 시각 (APPROVED 일 때만)
    created_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ  NOT NULL DEFAULT NOW(),

    UNIQUE (user_id, device_id)                              -- 한 유저의 같은 기기 중복 row 금지
);

-- 핵심 불변식: 유저당 APPROVED 1대 (부분 유니크 인덱스로 DB 레벨 강제)
CREATE UNIQUE INDEX uq_user_devices_one_approved
    ON user_devices (user_id) WHERE status = 'APPROVED';

-- 인덱스: 관리자 승인 대기열 조회 (status 필터 + 요청순 정렬)
CREATE INDEX idx_user_devices_status_requested
    ON user_devices (status, requested_at ASC);

-- 인덱스: 유저별 기기 상태 조회 (로그인 상태머신)
CREATE INDEX idx_user_devices_user_status
    ON user_devices (user_id, status);

-- ============================================
-- 운영 DB 마이그레이션 (schema.sql 은 신규 볼륨에만 적용되므로 기존 DB 는 아래 ALTER 수동 실행)
-- ============================================
-- [D3] 신규 가입 인사정보 사전 대조: password_hash NULL 허용 (미가입 직원 표현)
--   ALTER TABLE users ALTER COLUMN password_hash DROP NOT NULL;
--
-- [D4] 기기 자동등록(AUTO)/관리자승인(APPROVAL) 모드 전환 설정: companies 에 모드 컬럼 추가
--   ALTER TABLE companies ADD COLUMN IF NOT EXISTS device_binding_mode VARCHAR(16) NOT NULL DEFAULT 'AUTO'
--       CHECK (device_binding_mode IN ('AUTO','APPROVAL'));
--   (적용 후 api 컨테이너 재시작 → ddl-auto=validate 통과 확인)
