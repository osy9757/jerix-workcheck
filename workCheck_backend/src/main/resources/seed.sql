-- workCheck MVP - 시드 데이터 (기준표 기반 테스트 계정)
-- 모든 직원 비밀번호: 1111 / 모든 관리자 비밀번호: admin1234

-- ============================================
-- 1. 회사
-- ============================================
INSERT INTO companies (id, name, code) VALUES
    (1, '테스트 회사', 'jerix');

-- ============================================
-- 2. 근무지
-- ============================================
INSERT INTO workplaces (id, company_id, name, address, latitude, longitude) VALUES
    (1,  1, '본사',             '서울시 중구 세종대로 110',         37.5665, 126.9780),
    (2,  1, '강남지점',          '서울시 강남구 테헤란로 152',        37.4979, 127.0276),
    (3,  1, '여의도지점',        '서울시 영등포구 여의대로 108',       37.5219, 126.9245),
    (4,  1, '판교지점',          '경기도 성남시 분당구 판교역로 235',   37.3943, 127.1115),
    (5,  1, '을지로지점',        '서울시 중구 을지로 170',            37.5660, 126.9910),
    (6,  1, '종로지점',          '서울시 종로구 종로 104',            37.5704, 126.9922),
    (7,  1, '마포지점',          '서울시 마포구 마포대로 122',         37.5391, 126.9453),
    (8,  1, '비콘1 테스트지점',   '서울시 강남구 삼성로 512',          37.5088, 127.0631),
    (9,  1, '비콘2 테스트지점',   '서울시 강남구 봉은사로 524',        37.5100, 127.0620),
    (10, 1, '잠실지점',          '서울시 송파구 올림픽로 300',         37.5133, 127.1001),
    (11, 1, '종합테스트센터',     '서울시 중구 세종대로 110',          37.5665, 126.9780);

-- ============================================
-- 3. 직원 (앱 로그인: company_code=jerix, password=1111)
-- ============================================
INSERT INTO users (id, company_id, workplace_id, employee_id, name, email, department, password_hash) VALUES
    (1,  1, 1,  '11', 'GPS테스트',      'gps@test.com',        'GPS팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (2,  1, 2,  '12', 'GPS_QR테스트',   'gpsqr@test.com',      'GPS_QR팀',   '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (3,  1, 3,  '21', 'WiFi테스트',     'wifi@test.com',       'WiFi팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (4,  1, 4,  '22', 'WiFi_QR테스트',  'wifiqr@test.com',     'WiFi_QR팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (5,  1, 5,  '31', 'NFC테스트',      'nfc@test.com',        'NFC팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (6,  1, 6,  '32', 'NFC_GPS테스트',  'nfcgps@test.com',     'NFC_GPS팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (7,  1, 7,  '33', 'NFC마포테스트',  'nfcmapo@test.com',    'NFC마포팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (8,  1, 5,  '34', 'NFC테스트2',     'nfc2@test.com',       'NFC팀',      '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (9,  1, 8,  '41', '비콘테스트1',    'beacon1@test.com',    '비콘팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (10, 1, 9,  '42', '비콘테스트2',    'beacon2@test.com',    '비콘팀',     '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W'),
    (11, 1, 10, '43', '비콘GPS테스트',  'beacongps@test.com',  '비콘GPS팀',  '$2b$10$zmYHCWn.gdu3grX2tPQO9O/uaI9EFDmb1hJOp89Vu2mMoS44u2c/W');

-- ============================================
-- 4. 관리자 (웹 로그인: password=admin1234)
-- ============================================
INSERT INTO admin_users (id, company_id, username, password_hash, name) VALUES
    (1, 1, 'admin',     '$2b$10$hcslXCF28slWKJt/Ot2WqO8QjBAFtBrxCaIBlSSewMyergofPXnZa', '관리자'),
    (2, 1, 'testadmin', '$2b$10$hcslXCF28slWKJt/Ot2WqO8QjBAFtBrxCaIBlSSewMyergofPXnZa', '테스트관리자');

-- ============================================
-- 5. 인증 방법 등록
-- ============================================

-- 본사 (workplace 1): GPS만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (1, 1, 'GPS', TRUE);

-- 강남지점 (workplace 2): GPS_QR만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (2, 2, 'GPS_QR', TRUE);

-- 여의도지점 (workplace 3): WIFI만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (3, 3, 'WIFI', TRUE);

-- 판교지점 (workplace 4): WIFI_QR만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (4, 4, 'WIFI_QR', TRUE);

-- 을지로지점 (workplace 5): NFC만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (5, 5, 'NFC', TRUE);

-- 종로지점 (workplace 6): NFC_GPS만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (6, 6, 'NFC_GPS', TRUE);

-- 마포지점 (workplace 7): NFC만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (7, 7, 'NFC', TRUE);

-- 비콘1 테스트지점 (workplace 8): BEACON만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (8, 8, 'BEACON', TRUE);

-- 비콘2 테스트지점 (workplace 9): BEACON만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (9, 9, 'BEACON', TRUE);

-- 잠실지점 (workplace 10): BEACON_GPS만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (10, 10, 'BEACON_GPS', TRUE);

-- 종합테스트센터 (workplace 11): 8가지 모두 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (11, 11, 'GPS',        TRUE),
    (12, 11, 'GPS_QR',     TRUE),
    (13, 11, 'WIFI',       TRUE),
    (14, 11, 'WIFI_QR',    TRUE),
    (15, 11, 'NFC',        TRUE),
    (16, 11, 'NFC_GPS',    TRUE),
    (17, 11, 'BEACON',     TRUE),
    (18, 11, 'BEACON_GPS', TRUE);

-- ============================================
-- 6. 인증 방법별 설정값 (config_data) — 신 schema (targets[] / *_targets[] / qr_codes[])
-- ============================================
-- 신 schema 규칙:
--   단독 메서드(GPS/WIFI/NFC/BEACON): {"targets":[...]}
--   복합(GPS_QR/WIFI_QR): {"targets":[...gps|wifi...], "qr_codes":[...]}
--   복합(NFC_GPS): {"nfc_targets":[...], "gps_targets":[...]}
--   복합(BEACON_GPS): {"beacon_targets":[...], "gps_targets":[...]}
-- 좌표가 비어있는 GPS target 은 런타임에 근무지 컬럼 좌표로 폴백됨

-- 본사 GPS (단일 타겟, 좌표는 근무지 컬럼 폴백)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (1, '{"targets": [{"radius_meters": 200}]}');

-- 강남지점 GPS_QR (좌표 1개 + QR 코드 1개)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (2, '{"targets": [{"radius_meters": 150}], "qr_codes": ["WC-GN-QR-001"]}');

-- 여의도지점 WIFI (단일 타겟)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (3, '{"targets": [{"ssid": "WorkCheck-YID", "bssid": "AA:BB:CC:DD:EE:03"}]}');

-- 판교지점 WIFI_QR (단일 WiFi + QR)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (4, '{"targets": [{"ssid": "WorkCheck-PG", "bssid": "AA:BB:CC:DD:EE:04"}], "qr_codes": ["WC-PG-WQ-001"]}');

-- 을지로지점 NFC (단일 태그)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (5, '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}');

-- 종로지점 NFC_GPS (NFC 태그 1개 + GPS 1개)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (6, '{"nfc_targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}], "gps_targets": [{"radius_meters": 100}]}');

-- 마포지점 NFC (단일 태그)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (7, '{"targets": [{"tag_id": "04:AA:BB:CC:DD:EE:77"}]}');

-- 비콘1 테스트지점 BEACON
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (8, '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "rssi_threshold": -80}]}');

-- 비콘2 테스트지점 BEACON (동일 UUID, 다른 Minor)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (9, '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 52014, "rssi_threshold": -80}]}');

-- 잠실지점 BEACON_GPS (Beacon 1개 + GPS 1개)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (10, '{"beacon_targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "rssi_threshold": -80}], "gps_targets": [{"radius_meters": 150}]}');

-- 종합테스트센터 (8가지 모두 활성, 일부는 멀티 타겟으로 시연)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    -- GPS: 본사+회사 좌표 2개 (멀티)
    (11, '{"targets": [{"latitude": 37.5665, "longitude": 126.9780, "radius_meters": 200}, {"latitude": 37.541905, "longitude": 126.949614, "radius_meters": 200}]}'),
    -- GPS_QR: GPS 1개 + QR 코드 2개 (멀티)
    (12, '{"targets": [{"radius_meters": 200}], "qr_codes": ["WC-ALL-QR-001", "WC-ALL-QR-002"]}'),
    -- WIFI: SSID 2개 (멀티)
    (13, '{"targets": [{"ssid": "SK_WiFiGIGA8C8E_5G", "bssid": ""}, {"ssid": "WorkCheck-Office", "bssid": ""}]}'),
    -- WIFI_QR: WiFi 1개 + QR 1개
    (14, '{"targets": [{"ssid": "SK_WiFiGIGA8C8E_5G", "bssid": ""}], "qr_codes": ["WC-ALL-WQ-001"]}'),
    -- NFC: 태그 2개 (멀티)
    (15, '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}, {"tag_id": "04:AA:BB:CC:DD:EE:77"}]}'),
    -- NFC_GPS: 태그 2개 + GPS 1개
    (16, '{"nfc_targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}, {"tag_id": "04:AA:BB:CC:DD:EE:77"}], "gps_targets": [{"radius_meters": 200}]}'),
    -- BEACON: 비콘 2개 (멀티)
    (17, '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "rssi_threshold": -80}, {"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 52014, "rssi_threshold": -80}]}'),
    -- BEACON_GPS: 비콘 1개 + GPS 1개
    (18, '{"beacon_targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "rssi_threshold": -80}], "gps_targets": [{"radius_meters": 200}]}');

-- ============================================
-- 7. 인증 프리셋 (관리자 웹 카탈로그 - 자주 쓰는 값 저장)
-- ============================================
-- 프리셋은 단일 카탈로그 항목 → targets[] 배열에 1개만 담아 관리 (확장성 일관성)
INSERT INTO verification_presets (id, name, method_type, config_data, memo) VALUES
    (1, '사무실 정문 NFC',   'NFC',    '{"targets": [{"tag_id": "04:E9:D8:3E:C8:2A:81"}]}',                                                                          '을지로지점 정문 NFC 태그'),
    (2, '마포 NFC 백업',     'NFC',    '{"targets": [{"tag_id": "04:AA:BB:CC:DD:EE:77"}]}',                                                                          '마포지점 보조 태그'),
    (3, '회사 WiFi 5G',      'WIFI',   '{"targets": [{"ssid": "SK_WiFiGIGA8C8E_5G", "bssid": ""}]}',                                                                  '종합테스트센터 WiFi'),
    (4, '비콘1 (강남삼성)',   'BEACON', '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 57342, "rssi_threshold": -80}]}',     '비콘1 테스트지점'),
    (5, '비콘2 (강남봉은사)', 'BEACON', '{"targets": [{"uuid": "E2C56DB5-DFFB-48D2-B060-D0F5A71096E0", "major": 40011, "minor": 52014, "rssi_threshold": -80}]}',     '비콘2 테스트지점'),
    (6, '집',                'GPS',    '{"targets": [{"latitude": 37.5391, "longitude": 126.9453, "radius_meters": 200}]}',                                          '마포지점 인근'),
    (7, '회사',              'GPS',    '{"targets": [{"latitude": 37.541905, "longitude": 126.949614, "radius_meters": 200}]}',                                      '회사 위치 GPS');

-- ============================================
-- 8. 시퀀스 리셋
-- ============================================
SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));
SELECT setval('workplaces_id_seq', (SELECT MAX(id) FROM workplaces));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('admin_users_id_seq', (SELECT MAX(id) FROM admin_users));
SELECT setval('verification_methods_id_seq', (SELECT MAX(id) FROM verification_methods));
SELECT setval('verification_configs_id_seq', (SELECT MAX(id) FROM verification_configs));
SELECT setval('verification_presets_id_seq', (SELECT MAX(id) FROM verification_presets));
