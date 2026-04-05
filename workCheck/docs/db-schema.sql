-- ============================================
-- 출퇴근 앱 DB 스키마 - MVP (PostgreSQL + Spring Boot JPA)
-- 테이블 5개, 나머지는 확장 시 추가
-- ============================================

-- 1. 회사
CREATE TABLE company (
    id              BIGSERIAL PRIMARY KEY,
    code            VARCHAR(20)  NOT NULL UNIQUE,    -- 회사 코드 (로그인 시 입력)
    name            VARCHAR(100) NOT NULL,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- 2. 근무지
CREATE TABLE workplace (
    id              BIGSERIAL PRIMARY KEY,
    company_id      BIGINT       NOT NULL REFERENCES company(id),
    name            VARCHAR(100) NOT NULL,            -- 본사, 강남지점 등
    address         VARCHAR(255),

    -- 근무 스케줄 (인라인)
    start_time      TIME         NOT NULL DEFAULT '09:00', -- 출근 시각
    end_time        TIME         NOT NULL DEFAULT '18:00', -- 퇴근 시각
    late_threshold_min INTEGER   DEFAULT 0,                -- 지각 유예 (분)

    -- 인증 설정 + 참조 데이터 (JSONB 통합)
    verification_config JSONB    NOT NULL DEFAULT '{}',
    --
    -- 예시:
    -- {
    --   "allowed_presets": ["GPS", "GPS_QR", "NFC", "WIFI"],
    --   "gps": {
    --     "latitude": 37.5, "longitude": 127.0, "radius_m": 100
    --   },
    --   "nfc": {
    --     "allowed_tags": [
    --       {"tag_id": "04:A2:B3:C4", "label": "1층 출입문"},
    --       {"tag_id": "04:D5:E6:F7", "label": "3층 사무실"}
    --     ]
    --   },
    --   "wifi": {
    --     "allowed_networks": [
    --       {"ssid": "Office-WiFi", "bssid": "AA:BB:CC:DD:EE:FF"}
    --     ]
    --   },
    --   "beacon": {
    --     "allowed_devices": [
    --       {"device_id": "uuid-1234", "min_rssi": -80, "label": "3층 비콘"}
    --     ]
    --   },
    --   "qr": {
    --     "allowed_codes": ["WORKPLACE-001-GATE"]
    --   }
    -- }
    --

    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- 3. 직원
CREATE TABLE employee (
    id              BIGSERIAL PRIMARY KEY,
    company_id      BIGINT       NOT NULL REFERENCES company(id),
    workplace_id    BIGINT       NOT NULL REFERENCES workplace(id),
    employee_number VARCHAR(20)  NOT NULL,            -- 사번
    name            VARCHAR(50)  NOT NULL,
    password        VARCHAR(255) NOT NULL,            -- BCrypt 해시
    role            VARCHAR(20)  NOT NULL DEFAULT 'EMPLOYEE',  -- EMPLOYEE | ADMIN
    status          VARCHAR(20)  NOT NULL DEFAULT 'ACTIVE',    -- ACTIVE | INACTIVE
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),

    UNIQUE (company_id, employee_number)
);

-- 4. 출퇴근 기록
CREATE TABLE attendance (
    id                  BIGSERIAL PRIMARY KEY,
    employee_id         BIGINT       NOT NULL REFERENCES employee(id),
    workplace_id        BIGINT       NOT NULL REFERENCES workplace(id),
    type                VARCHAR(20)  NOT NULL,        -- CLOCK_IN | CLOCK_OUT
    timestamp           TIMESTAMP    NOT NULL,
    verification_preset VARCHAR(30)  NOT NULL,        -- GPS | GPS_QR | WIFI | WIFI_QR | NFC | NFC_GPS | BEACON | BEACON_GPS
    verification_data   JSONB,                        -- 인증 시 수집된 원본 데이터
    -- 단일: {"gps": {"latitude": 35.1, "longitude": 126.9, "accuracy": 5.2}}
    -- 복합: {"nfc": {"tag_id": "04:A2:B3:C4"}, "gps": {"latitude": 35.1, ...}}
    created_at          TIMESTAMP    NOT NULL DEFAULT NOW()
);

-- 5. 일별 근태 요약
--
-- [자동 판정 로직]
-- CLOCK_IN:  timestamp > start_time + late_threshold_min → LATE
-- CLOCK_OUT: timestamp < end_time → EARLY_LEAVE
-- LATE + EARLY_LEAVE → LATE_AND_EARLY
-- 배치: 해당일 기록 없음 → ABSENT
--
CREATE TABLE daily_attendance (
    id              BIGSERIAL PRIMARY KEY,
    employee_id     BIGINT       NOT NULL REFERENCES employee(id),
    date            DATE         NOT NULL,
    clock_in_id     BIGINT       REFERENCES attendance(id),
    clock_out_id    BIGINT       REFERENCES attendance(id),
    status          VARCHAR(20)  NOT NULL DEFAULT 'NORMAL',
    work_minutes    INTEGER,                          -- 실 근무 시간 (분)
    notes           TEXT,                             -- 관리자 메모
    modified_by     BIGINT       REFERENCES employee(id),
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP    NOT NULL DEFAULT NOW(),

    UNIQUE (employee_id, date),

    CONSTRAINT chk_status CHECK (
        status IN ('NORMAL', 'LATE', 'EARLY_LEAVE', 'LATE_AND_EARLY', 'ABSENT', 'HOLIDAY', 'LEAVE')
    )
);

-- ============================================
-- 인덱스
-- ============================================

CREATE INDEX idx_workplace_company              ON workplace(company_id);
CREATE INDEX idx_employee_company               ON employee(company_id);
CREATE INDEX idx_employee_workplace             ON employee(workplace_id);
CREATE INDEX idx_attendance_employee            ON attendance(employee_id);
CREATE INDEX idx_attendance_employee_timestamp  ON attendance(employee_id, timestamp);
CREATE INDEX idx_attendance_workplace           ON attendance(workplace_id);
CREATE INDEX idx_daily_attendance_date          ON daily_attendance(employee_id, date);
CREATE INDEX idx_daily_attendance_status        ON daily_attendance(status, date);

-- ============================================
-- 확장 로드맵 (MVP 이후)
-- ============================================
--
-- Phase 2: 인증/보안
--   - refresh_token (JWT 갱신)
--   - employee_device (기기 승인)
--
-- Phase 3: 3단계 관리
--   - work_schedule (별도 테이블, 회사→근무지→직원 오버라이드)
--   - verification_preset (복합 인증 시드 테이블)
--   - company_verification_config / workplace_verification_config / employee_verification_override
--
-- Phase 4: 중앙 참조 데이터
--   - verification_ref + verification_ref_assignment (회사 중앙 등록 → 근무지/직원 연결)
--   - employee_workplace N:M (다중 근무지)
--
