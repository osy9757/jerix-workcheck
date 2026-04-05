-- workCheck MVP - PostgreSQL DDL
-- 출퇴근 앱 DB 스키마

-- ENUM 타입 정의
CREATE TYPE method_type_enum AS ENUM (
    'GPS', 'GPS_QR', 'WIFI', 'WIFI_QR',
    'NFC', 'NFC_GPS', 'BEACON', 'BEACON_GPS'
);

CREATE TYPE attendance_type_enum AS ENUM (
    'CLOCK_IN', 'CLOCK_OUT'
);

CREATE TYPE attendance_status_enum AS ENUM (
    'PENDING', 'APPROVED', 'REJECTED'
);

-- 1. 회사 테이블
CREATE TABLE companies (
    id         BIGSERIAL PRIMARY KEY,
    name       VARCHAR(100)  NOT NULL,
    code       VARCHAR(20)   NOT NULL UNIQUE,  -- 앱 로그인 시 사용 (예: "CU01")
    created_at TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 2. 근무지 테이블
CREATE TABLE workplaces (
    id         BIGSERIAL PRIMARY KEY,
    company_id BIGINT            NOT NULL REFERENCES companies(id),
    name       VARCHAR(100)      NOT NULL,
    address    VARCHAR(255),
    latitude   DOUBLE PRECISION,          -- 근무지 위도
    longitude  DOUBLE PRECISION,          -- 근무지 경도
    created_at TIMESTAMPTZ       NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ       NOT NULL DEFAULT NOW()
);

-- 3. 직원(앱 사용자) 테이블
CREATE TABLE users (
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT        NOT NULL REFERENCES companies(id),
    workplace_id  BIGINT        REFERENCES workplaces(id),  -- 소속 근무지 (nullable)
    employee_id   VARCHAR(50)   NOT NULL,          -- 사원번호
    name          VARCHAR(100)  NOT NULL,
    email         VARCHAR(255),
    department    VARCHAR(100),
    password_hash VARCHAR(255)  NOT NULL,           -- PIN 해시 (BCrypt)
    is_active     BOOLEAN       NOT NULL DEFAULT TRUE,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW(),

    UNIQUE (company_id, employee_id)               -- 회사 내 사원번호 고유
);

-- 4. 관리자 테이블 (웹 관리 페이지용)
CREATE TABLE admin_users (
    id            BIGSERIAL PRIMARY KEY,
    company_id    BIGINT        NOT NULL REFERENCES companies(id),
    username      VARCHAR(50)   NOT NULL UNIQUE,
    password_hash VARCHAR(255)  NOT NULL,
    name          VARCHAR(100)  NOT NULL,
    created_at    TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- 5. 인증 방법 목록 (근무지별 ON/OFF)
CREATE TABLE verification_methods (
    id           BIGSERIAL PRIMARY KEY,
    workplace_id BIGINT           NOT NULL REFERENCES workplaces(id),
    method_type  method_type_enum NOT NULL,
    is_enabled   BOOLEAN          NOT NULL DEFAULT TRUE,
    created_at   TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    UNIQUE (workplace_id, method_type)              -- 근무지당 방법별 1개
);

-- 6. 인증 방법별 설정값 (JSONB)
CREATE TABLE verification_configs (
    id                      BIGSERIAL PRIMARY KEY,
    verification_method_id  BIGINT    NOT NULL UNIQUE REFERENCES verification_methods(id),
    config_data             JSONB     NOT NULL DEFAULT '{}',   -- 방법별 설정값
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- 7. 유저별 인증 오버라이드 테이블
CREATE TABLE user_verification_overrides (
    id          BIGSERIAL PRIMARY KEY,
    user_id     BIGINT           NOT NULL REFERENCES users(id),
    method_type method_type_enum NOT NULL,
    is_enabled  BOOLEAN          NOT NULL DEFAULT TRUE,
    config_data JSONB            NOT NULL DEFAULT '{}',
    created_at  TIMESTAMPTZ      NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ      NOT NULL DEFAULT NOW(),

    UNIQUE (user_id, method_type)                   -- 유저당 방법별 1개
);

-- 8. 출퇴근 기록
CREATE TABLE attendance_records (
    id                      BIGSERIAL PRIMARY KEY,
    user_id                 BIGINT               NOT NULL REFERENCES users(id),
    type                    attendance_type_enum   NOT NULL,       -- CLOCK_IN / CLOCK_OUT
    status                  attendance_status_enum NOT NULL DEFAULT 'PENDING', -- 승인 상태
    verification_method_id  BIGINT               NOT NULL REFERENCES verification_methods(id),
    verification_data       JSONB                NOT NULL DEFAULT '{}',  -- 앱이 전송한 인증 데이터
    recorded_at             TIMESTAMPTZ          NOT NULL DEFAULT NOW(), -- 출퇴근 시각
    created_at              TIMESTAMPTZ          NOT NULL DEFAULT NOW()
);

-- 인덱스: 날짜별 출퇴근 조회
CREATE INDEX idx_attendance_user_recorded
    ON attendance_records (user_id, recorded_at DESC);

-- 인덱스: 오늘의 출퇴근 상태 조회 (GET /api/v1/attendance/today)
CREATE INDEX idx_attendance_user_type_recorded
    ON attendance_records (user_id, type, recorded_at DESC);
