-- workCheck MVP - 시드 데이터 (v2)
-- 모든 직원 비밀번호: 1111 / 모든 관리자 비밀번호: admin1234
--
-- v2 변경 사항:
--   * workplaces 폐기 → 좌표는 user 의 GPS config_data targets[] 로 이관
--   * verification_methods/configs 폐기 → user_verification_methods 로 일원화
--   * 직원별로 5개 method 모두 row 생성 (활성 row 만 is_enabled=TRUE, 나머지는 FALSE)
--   * 신 키 스키마:
--       GPS    : {"targets":[{"lat":..,"lng":..,"radius_m":..}]}
--       WIFI   : {"targets":[{"ssid":"..","identifier_type":"bssid|ip","identifier_value":".."}]}
--       NFC    : {"targets":[{"tag_id":".."}]}
--       BEACON : {"targets":[{"uuid":"..","major":..,"minor":..,"distance_m":..,"tx_power":..,"rssi_threshold":..}]}
--       QR     : {"codes":[".."]}

-- ============================================
-- 1. 회사
-- ============================================
INSERT INTO companies (id, name, code) VALUES
    (1, '테스트 회사', 'jerix');

-- ============================================
-- 2. 직원 (앱 로그인: company_code=jerix, password=1111)
-- ============================================
-- v2: workplace_id 컬럼 제거. 인증 설정은 user_verification_methods 에서 부여.
INSERT INTO users (id, company_id, employee_id, name, email, department, password_hash) VALUES
    (1,  1, '11', 'GPS테스트',      'gps@test.com',       'GPS팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (2,  1, '12', 'GPS_QR테스트',   'gpsqr@test.com',     'GPS_QR팀',   '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (3,  1, '21', 'WiFi테스트',     'wifi@test.com',      'WiFi팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (4,  1, '22', 'WiFi_QR테스트',  'wifiqr@test.com',    'WiFi_QR팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (5,  1, '31', 'NFC테스트',      'nfc@test.com',       'NFC팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (6,  1, '32', 'NFC_GPS테스트',  'nfcgps@test.com',    'NFC_GPS팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (7,  1, '33', 'NFC마포테스트',  'nfcmapo@test.com',   'NFC마포팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (8,  1, '34', 'NFC테스트2',     'nfc2@test.com',      'NFC팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (9,  1, '41', '비콘테스트1',    'beacon1@test.com',   '비콘팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (10, 1, '42', '비콘테스트2',    'beacon2@test.com',   '비콘팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (11, 1, '43', '비콘GPS테스트',  'beacongps@test.com', '비콘GPS팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W');

-- ============================================
-- 3. 관리자 (웹 로그인: password=admin1234)
-- ============================================
INSERT INTO admin_users (id, company_id, username, password_hash, name) VALUES
    (1, 1, 'admin',     '$2b$10$hcslXCF28slWKJt/Ot2WqO8QjBAFtBrxCaIBlSSewMyergofPXnZa', '관리자'),
    (2, 1, 'testadmin', '$2b$10$hcslXCF28slWKJt/Ot2WqO8QjBAFtBrxCaIBlSSewMyergofPXnZa', '테스트관리자');

-- ============================================
-- 4. 유저별 인증 방법 (직원당 5 row, 미활성은 is_enabled=FALSE + 빈 config)
-- ============================================
-- 기존 워크플레이스 매핑 → 신 모델 활성 method:
--   user 1 (본사 GPS)      → GPS
--   user 2 (강남 GPS_QR)   → GPS + QR
--   user 3 (여의도 WIFI)   → WIFI
--   user 4 (판교 WIFI_QR)  → WIFI + QR
--   user 5 (을지로 NFC)    → NFC
--   user 6 (종로 NFC_GPS)  → NFC + GPS
--   user 7 (마포 NFC)      → NFC
--   user 8 (을지로 공유)   → NFC
--   user 9 (비콘1)         → BEACON
--   user 10 (비콘2)        → BEACON
--   user 11 (잠실 BG)      → BEACON + GPS

-- user 1: GPS (본사 좌표)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (1, 'GPS',    TRUE,  '{"targets": [{"lat": 37.5665, "lng": 126.9780, "radius_m": 200}]}'),
    (1, 'WIFI',   FALSE, '{}'),
    (1, 'NFC',    FALSE, '{}'),
    (1, 'BEACON', FALSE, '{}'),
    (1, 'QR',     FALSE, '{}');

-- user 2: GPS + QR (강남 좌표 + GN QR)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (2, 'GPS',    TRUE,  '{"targets": [{"lat": 37.4979, "lng": 127.0276, "radius_m": 150}]}'),
    (2, 'WIFI',   FALSE, '{}'),
    (2, 'NFC',    FALSE, '{}'),
    (2, 'BEACON', FALSE, '{}'),
    (2, 'QR',     TRUE,  '{"codes": ["WC-GN-QR-001"]}');

-- user 3: WIFI (여의도)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (3, 'GPS',    FALSE, '{}'),
    (3, 'WIFI',   TRUE,  '{"targets": [{"ssid": "WorkCheck-YID", "identifier_type": "bssid", "identifier_value": "AA:BB:CC:DD:EE:03"}]}'),
    (3, 'NFC',    FALSE, '{}'),
    (3, 'BEACON', FALSE, '{}'),
    (3, 'QR',     FALSE, '{}');

-- user 4: WIFI + QR (판교)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (4, 'GPS',    FALSE, '{}'),
    (4, 'WIFI',   TRUE,  '{"targets": [{"ssid": "WorkCheck-PG", "identifier_type": "bssid", "identifier_value": "AA:BB:CC:DD:EE:04"}]}'),
    (4, 'NFC',    FALSE, '{}'),
    (4, 'BEACON', FALSE, '{}'),
    (4, 'QR',     TRUE,  '{"codes": ["WC-PG-WQ-001"]}');

-- user 5: NFC (을지로 태그)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (5, 'GPS',    FALSE, '{}'),
    (5, 'WIFI',   FALSE, '{}'),
    (5, 'NFC',    TRUE,  '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}'),
    (5, 'BEACON', FALSE, '{}'),
    (5, 'QR',     FALSE, '{}');

-- user 6: NFC + GPS (종로)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (6, 'GPS',    TRUE,  '{"targets": [{"lat": 37.5704, "lng": 126.9922, "radius_m": 100}]}'),
    (6, 'WIFI',   FALSE, '{}'),
    (6, 'NFC',    TRUE,  '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}'),
    (6, 'BEACON', FALSE, '{}'),
    (6, 'QR',     FALSE, '{}');

-- user 7: NFC (마포 태그)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (7, 'GPS',    FALSE, '{}'),
    (7, 'WIFI',   FALSE, '{}'),
    (7, 'NFC',    TRUE,  '{"targets": [{"tag_id": "04:5E:55:37:C9:2A:81"}]}'),
    (7, 'BEACON', FALSE, '{}'),
    (7, 'QR',     FALSE, '{}');

-- user 8: NFC (을지로 공유 태그)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (8, 'GPS',    FALSE, '{}'),
    (8, 'WIFI',   FALSE, '{}'),
    (8, 'NFC',    TRUE,  '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}'),
    (8, 'BEACON', FALSE, '{}'),
    (8, 'QR',     FALSE, '{}');

-- user 9: BEACON (비콘1, distance_m/tx_power 신 필드 포함)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (9, 'GPS',    FALSE, '{}'),
    (9, 'WIFI',   FALSE, '{}'),
    (9, 'NFC',    FALSE, '{}'),
    (9, 'BEACON', TRUE,  '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "distance_m": 2.0, "tx_power": -59, "rssi_threshold": -77}]}'),
    (9, 'QR',     FALSE, '{}');

-- user 10: BEACON (비콘2, 다른 minor)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (10, 'GPS',    FALSE, '{}'),
    (10, 'WIFI',   FALSE, '{}'),
    (10, 'NFC',    FALSE, '{}'),
    (10, 'BEACON', TRUE,  '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 52014, "distance_m": 2.0, "tx_power": -59, "rssi_threshold": -77}]}'),
    (10, 'QR',     FALSE, '{}');

-- user 11: BEACON + GPS (잠실)
INSERT INTO user_verification_methods (user_id, method_type, is_enabled, config_data) VALUES
    (11, 'GPS',    TRUE,  '{"targets": [{"lat": 37.5133, "lng": 127.1001, "radius_m": 150}]}'),
    (11, 'WIFI',   FALSE, '{}'),
    (11, 'NFC',    FALSE, '{}'),
    (11, 'BEACON', TRUE,  '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "distance_m": 2.0, "tx_power": -59, "rssi_threshold": -77}]}'),
    (11, 'QR',     FALSE, '{}');

-- ============================================
-- 5. 인증 프리셋 (관리자 웹 카탈로그)
-- ============================================
-- 단일 카탈로그 항목 → targets[] 또는 codes[] 배열에 1개만 담아 관리.
-- 신 키 스키마 (uvm 와 동일): lat/lng/radius_m, identifier_type/identifier_value, distance_m/tx_power, codes.
INSERT INTO verification_presets (id, name, method_type, config_data, memo) VALUES
    (1,  '을지로 NFC 1번',     'NFC',    '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}',                                                                                                                  '을지로지점 정문 NFC 태그'),
    (2,  '마포 NFC',           'NFC',    '{"targets": [{"tag_id": "04:5E:55:37:C9:2A:81"}]}',                                                                                                                  '마포지점 보조 태그'),
    (3,  '회사 WiFi 5G',       'WIFI',   '{"targets": [{"ssid": "SK_WiFiGIGA8C8E_5G", "identifier_type": "bssid", "identifier_value": ""}]}',                                                                  '종합테스트센터 WiFi'),
    (4,  '비콘1 (강남삼성)',   'BEACON', '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "distance_m": 2.0, "tx_power": -59, "rssi_threshold": -77}]}',         '비콘1 테스트지점'),
    (5,  '비콘2 (강남봉은사)', 'BEACON', '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 52014, "distance_m": 2.0, "tx_power": -59, "rssi_threshold": -77}]}',         '비콘2 테스트지점'),
    (6,  '집',                 'GPS',    '{"targets": [{"lat": 37.5391, "lng": 126.9453, "radius_m": 200}]}',                                                                                                  '마포지점 인근'),
    (7,  '회사',               'GPS',    '{"targets": [{"lat": 37.541905, "lng": 126.949614, "radius_m": 200}]}',                                                                                              '회사 위치 GPS'),
    -- QR 프리셋 (GPS+QR / WIFI+QR 편집 시 끼워넣는 카탈로그)
    (8,  '본사 QR-001',        'QR',     '{"codes": ["WC-HQ-QR-001"]}', '본사 1번 QR'),
    (9,  '본사 QR-002',        'QR',     '{"codes": ["WC-HQ-QR-002"]}', '본사 2번 QR'),
    (10, '강남지점 QR',        'QR',     '{"codes": ["WC-GN-QR-001"]}', '강남지점 QR'),
    (11, '판교지점 WiFi QR',   'QR',     '{"codes": ["WC-PG-WQ-001"]}', '판교지점 WIFI_QR용 QR'),
    -- WiFi 랜덤 테스트용 프리셋 (실제 환경과 매칭되지 않는 더미값)
    (12, 'WiFi 랜덤테스트',    'WIFI',   '{"targets": [{"ssid": "TEST_RAND_8F3K2J", "identifier_type": "bssid", "identifier_value": "AA:BB:CC:11:22:33"}]}', 'WiFi 인증 실패/매칭 테스트용 더미');

-- ============================================
-- 6. 시퀀스 리셋
-- ============================================
SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('admin_users_id_seq', (SELECT MAX(id) FROM admin_users));
SELECT setval('user_verification_methods_id_seq', (SELECT MAX(id) FROM user_verification_methods));
SELECT setval('verification_presets_id_seq', (SELECT MAX(id) FROM verification_presets));
