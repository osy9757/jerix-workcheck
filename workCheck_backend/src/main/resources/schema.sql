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
    password_hash VARCHAR(255)  NOT NULL,           -- PIN 해시 (BCrypt)
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
