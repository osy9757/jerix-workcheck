-- workCheck MVP - 시드 데이터 (전체 인증 케이스 테스트용)
-- 8가지 인증 방법별 전용 근무지 + 직원 + 출퇴근 기록
-- 모든 직원 비밀번호: 1111 / 모든 관리자 비밀번호: admin1234

-- ============================================
-- 1. 회사
-- ============================================
INSERT INTO companies (id, name, code) VALUES
    (1, '테스트 회사', 'CU01');

-- ============================================
-- 2. 근무지 (인증 방법별 전용 + 종합테스트센터)
-- ============================================
INSERT INTO workplaces (id, company_id, name, address, latitude, longitude) VALUES
    (1, 1, '본사',             '서울시 중구 세종대로 110',     37.5665, 126.9780),  -- GPS 전용
    (2, 1, '강남지점',          '서울시 강남구 테헤란로 152',    37.4979, 127.0276),  -- GPS+QR 전용
    (3, 1, '여의도지점',        '서울시 영등포구 여의대로 108',   37.5219, 126.9245),  -- WiFi 전용
    (4, 1, '판교지점',          '경기도 성남시 분당구 판교역로 235', 37.3943, 127.1115), -- WiFi+QR 전용
    (5, 1, '을지로지점',        '서울시 중구 을지로 170',       37.5660, 126.9910),  -- NFC 전용
    (6, 1, '종로지점',          '서울시 종로구 종로 104',       37.5704, 126.9922),  -- NFC+GPS 전용
    (7, 1, '삼성지점',          '서울시 강남구 삼성로 512',     37.5088, 127.0631),  -- Beacon 전용
    (8, 1, '잠실지점',          '서울시 송파구 올림픽로 300',    37.5133, 127.1001),  -- Beacon+GPS 전용
    (9, 1, '종합테스트센터',     '서울시 중구 세종대로 110',     37.5665, 126.9780);  -- 전체 인증 방법

-- ============================================
-- 3. 직원 (앱 로그인: company_code=CU01, password=1111)
-- BCrypt hash of "1111"
-- ============================================
INSERT INTO users (id, company_id, workplace_id, employee_id, name, email, department, password_hash) VALUES
    -- 본사 (GPS 전용) - 기존 직원
    (1,  1, 1, '4',  '사원A',     'a@test.com',        '개발팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (2,  1, 1, '2',  '사원B',     'b@test.com',        '인사팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (3,  1, 1, '3',  '사원C',     'c@test.com',        '기획팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (4,  1, 1, '1',  '사원D',     'd@test.com',        '개발팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    -- 인증 방법별 전용 직원
    (5,  1, 2, '5',  '김GPS_QR',  'gpsqr@test.com',    '강남팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (6,  1, 3, '6',  '이WiFi',    'wifi@test.com',     '여의도팀', '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (7,  1, 4, '7',  '박WiFi_QR', 'wifiqr@test.com',   '판교팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (8,  1, 5, '8',  '최NFC',     'nfc@test.com',      '을지로팀', '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (9,  1, 6, '9',  '정NFC_GPS', 'nfcgps@test.com',   '종로팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (10, 1, 7, '10', '강Beacon',  'beacon@test.com',   '삼성팀',   '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    (11, 1, 8, '11', '조Beacon_GPS', 'beacongps@test.com', '잠실팀', '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW'),
    -- 종합테스트센터 직원
    (12, 1, 9, '12', '윤종합',    'all@test.com',      '테스트팀', '$2a$10$cm/AlwBvrdMesG8m/HyQfONqa6FYH6Q9MQaPLYoTmcA.3wiVF2FGW');

-- ============================================
-- 4. 관리자 (웹 로그인: password=admin1234)
-- BCrypt hash of "admin1234"
-- ============================================
INSERT INTO admin_users (id, company_id, username, password_hash, name) VALUES
    (1, 1, 'admin',     '$2a$10$Eo9IvxqyxQGjKZgvrlAUb.LKEXRMVr0k1NXSr1SFNOHOqxAKWxyZi', '관리자'),
    (2, 1, 'testadmin', '$2a$10$Eo9IvxqyxQGjKZgvrlAUb.LKEXRMVr0k1NXSr1SFNOHOqxAKWxyZi', '테스트관리자');

-- ============================================
-- 5. 인증 방법 등록
-- ============================================

-- 본사 (workplace 1): 8가지 등록, GPS만 활성화 (관리자 토글 테스트용)
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (1, 1, 'GPS',        TRUE),
    (2, 1, 'GPS_QR',     FALSE),
    (3, 1, 'WIFI',       FALSE),
    (4, 1, 'WIFI_QR',    FALSE),
    (5, 1, 'NFC',        FALSE),
    (6, 1, 'NFC_GPS',    FALSE),
    (7, 1, 'BEACON',     FALSE),
    (8, 1, 'BEACON_GPS', FALSE);

-- 강남지점 (workplace 2): GPS_QR만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (9, 2, 'GPS_QR', TRUE);

-- 여의도지점 (workplace 3): WIFI만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (10, 3, 'WIFI', TRUE);

-- 판교지점 (workplace 4): WIFI_QR만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (11, 4, 'WIFI_QR', TRUE);

-- 을지로지점 (workplace 5): NFC만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (12, 5, 'NFC', TRUE);

-- 종로지점 (workplace 6): NFC_GPS만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (13, 6, 'NFC_GPS', TRUE);

-- 삼성지점 (workplace 7): BEACON만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (14, 7, 'BEACON', TRUE);

-- 잠실지점 (workplace 8): BEACON_GPS만 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (15, 8, 'BEACON_GPS', TRUE);

-- 종합테스트센터 (workplace 9): 8가지 모두 활성화
INSERT INTO verification_methods (id, workplace_id, method_type, is_enabled) VALUES
    (16, 9, 'GPS',        TRUE),
    (17, 9, 'GPS_QR',     TRUE),
    (18, 9, 'WIFI',       TRUE),
    (19, 9, 'WIFI_QR',    TRUE),
    (20, 9, 'NFC',        TRUE),
    (21, 9, 'NFC_GPS',    TRUE),
    (22, 9, 'BEACON',     TRUE),
    (23, 9, 'BEACON_GPS', TRUE);

-- ============================================
-- 6. 인증 방법별 설정값 (config_data)
-- ============================================

-- 본사 (8가지 모두 설정값 등록)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (1, '{"radius_meters": 200}'),
    (2, '{"radius_meters": 200, "qr_code": "WC-MAIN-QR-001"}'),
    (3, '{"ssid": "WorkCheck-Main", "bssid": "AA:BB:CC:DD:EE:01"}'),
    (4, '{"ssid": "WorkCheck-Main", "bssid": "AA:BB:CC:DD:EE:01", "qr_code": "WC-MAIN-WQ-001"}'),
    (5, '{"tag_id": "04:E9:D8:3E:C8:2A:81"}'),
    (6, '{"tag_id": "04:E9:D8:3E:C8:2A:81", "radius_meters": 200}'),
    (7, '{"uuid": "11111111-1111-1111-1111-111111111111", "major": 1, "minor": 100, "rssi_threshold": -70}'),
    (8, '{"uuid": "11111111-1111-1111-1111-111111111111", "major": 1, "minor": 100, "rssi_threshold": -70, "radius_meters": 200}');

-- 강남지점 (GPS_QR)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (9, '{"radius_meters": 150, "qr_code": "WC-GN-QR-001"}');

-- 여의도지점 (WIFI)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (10, '{"ssid": "WorkCheck-YID", "bssid": "AA:BB:CC:DD:EE:03"}');

-- 판교지점 (WIFI_QR)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (11, '{"ssid": "WorkCheck-PG", "bssid": "AA:BB:CC:DD:EE:04", "qr_code": "WC-PG-WQ-001"}');

-- 을지로지점 (NFC)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (12, '{"tag_id": "04:E9:D8:3E:C8:2A:81"}');

-- 종로지점 (NFC_GPS)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (13, '{"tag_id": "04:E9:D8:3E:C8:2A:81", "radius_meters": 100}');

-- 삼성지점 (BEACON)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (14, '{"uuid": "22222222-2222-2222-2222-222222222222", "major": 2, "minor": 200, "rssi_threshold": -75}');

-- 잠실지점 (BEACON_GPS)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (15, '{"uuid": "33333333-3333-3333-3333-333333333333", "major": 3, "minor": 300, "rssi_threshold": -75, "radius_meters": 150}');

-- 종합테스트센터 (8가지 모두)
INSERT INTO verification_configs (verification_method_id, config_data) VALUES
    (16, '{"radius_meters": 200}'),
    (17, '{"radius_meters": 200, "qr_code": "WC-ALL-QR-001"}'),
    (18, '{"ssid": "SK_WiFiGIGA8C8E_5G", "bssid": ""}'),
    (19, '{"ssid": "SK_WiFiGIGA8C8E_5G", "bssid": "", "qr_code": "WC-ALL-WQ-001"}'),
    (20, '{"tag_id": "04:E9:D8:3E:C8:2A:81"}'),
    (21, '{"tag_id": "04:E9:D8:3E:C8:2A:81", "radius_meters": 200}'),
    (22, '{"uuid": "99999999-9999-9999-9999-999999999999", "major": 9, "minor": 900, "rssi_threshold": -70}'),
    (23, '{"uuid": "99999999-9999-9999-9999-999999999999", "major": 9, "minor": 900, "rssi_threshold": -70, "radius_meters": 200}');

-- ============================================
-- 7. 테스트용 출퇴근 기록 (인증 방법별 1건씩)
-- ============================================

-- GPS 출퇴근 (사원A, 본사)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (1, 'CLOCK_IN',  'APPROVED', 1,
     '{"latitude": 37.5668, "longitude": 126.9782, "accuracy": 8.5, "timestamp": "2026-03-10T08:55:00+09:00"}',
     '2026-03-10 08:55:00+09'),
    (1, 'CLOCK_OUT', 'APPROVED', 1,
     '{"latitude": 37.5667, "longitude": 126.9781, "accuracy": 10.2, "timestamp": "2026-03-10T18:05:00+09:00"}',
     '2026-03-10 18:05:00+09');

-- GPS+QR 출퇴근 (김GPS_QR, 강남지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (5, 'CLOCK_IN',  'APPROVED', 9,
     '{"latitude": 37.4981, "longitude": 127.0278, "accuracy": 5.0, "qr_data": "WC-GN-QR-001", "timestamp": "2026-03-10T09:00:00+09:00"}',
     '2026-03-10 09:00:00+09'),
    (5, 'CLOCK_OUT', 'APPROVED', 9,
     '{"latitude": 37.4980, "longitude": 127.0277, "accuracy": 7.3, "qr_data": "WC-GN-QR-001", "timestamp": "2026-03-10T18:10:00+09:00"}',
     '2026-03-10 18:10:00+09');

-- WiFi 출퇴근 (이WiFi, 여의도지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (6, 'CLOCK_IN',  'APPROVED', 10,
     '{"ssid": "WorkCheck-YID", "bssid": "AA:BB:CC:DD:EE:03", "ip": "192.168.3.101", "timestamp": "2026-03-10T08:50:00+09:00"}',
     '2026-03-10 08:50:00+09'),
    (6, 'CLOCK_OUT', 'APPROVED', 10,
     '{"ssid": "WorkCheck-YID", "bssid": "AA:BB:CC:DD:EE:03", "ip": "192.168.3.101", "timestamp": "2026-03-10T18:00:00+09:00"}',
     '2026-03-10 18:00:00+09');

-- WiFi+QR 출퇴근 (박WiFi_QR, 판교지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (7, 'CLOCK_IN',  'APPROVED', 11,
     '{"ssid": "WorkCheck-PG", "bssid": "AA:BB:CC:DD:EE:04", "ip": "192.168.4.101", "qr_data": "WC-PG-WQ-001", "timestamp": "2026-03-10T09:05:00+09:00"}',
     '2026-03-10 09:05:00+09'),
    (7, 'CLOCK_OUT', 'APPROVED', 11,
     '{"ssid": "WorkCheck-PG", "bssid": "AA:BB:CC:DD:EE:04", "ip": "192.168.4.101", "qr_data": "WC-PG-WQ-001", "timestamp": "2026-03-10T18:15:00+09:00"}',
     '2026-03-10 18:15:00+09');

-- NFC 출퇴근 (최NFC, 을지로지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (8, 'CLOCK_IN',  'APPROVED', 12,
     '{"tag_id": "04:E9:D8:3E:C8:2A:81", "tag_data": "workcheck-nfc-gate", "timestamp": "2026-03-10T08:45:00+09:00"}',
     '2026-03-10 08:45:00+09'),
    (8, 'CLOCK_OUT', 'APPROVED', 12,
     '{"tag_id": "04:E9:D8:3E:C8:2A:81", "tag_data": "workcheck-nfc-gate", "timestamp": "2026-03-10T18:20:00+09:00"}',
     '2026-03-10 18:20:00+09');

-- NFC+GPS 출퇴근 (정NFC_GPS, 종로지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (9, 'CLOCK_IN',  'APPROVED', 13,
     '{"tag_id": "04:E9:D8:3E:C8:2A:81", "tag_data": "workcheck-nfc-gate", "latitude": 37.5706, "longitude": 126.9924, "accuracy": 6.0, "timestamp": "2026-03-10T09:10:00+09:00"}',
     '2026-03-10 09:10:00+09'),
    (9, 'CLOCK_OUT', 'APPROVED', 13,
     '{"tag_id": "04:E9:D8:3E:C8:2A:81", "tag_data": "workcheck-nfc-gate", "latitude": 37.5705, "longitude": 126.9923, "accuracy": 8.1, "timestamp": "2026-03-10T18:30:00+09:00"}',
     '2026-03-10 18:30:00+09');

-- Beacon 출퇴근 (강Beacon, 삼성지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (10, 'CLOCK_IN',  'APPROVED', 14,
     '{"detected_devices": [{"device_id": "22222222-2222-2222-2222-222222222222", "device_name": "WC-Beacon-SS", "rssi": -62}], "device_count": 1, "timestamp": "2026-03-10T08:58:00+09:00"}',
     '2026-03-10 08:58:00+09'),
    (10, 'CLOCK_OUT', 'APPROVED', 14,
     '{"detected_devices": [{"device_id": "22222222-2222-2222-2222-222222222222", "device_name": "WC-Beacon-SS", "rssi": -68}], "device_count": 1, "timestamp": "2026-03-10T18:02:00+09:00"}',
     '2026-03-10 18:02:00+09');

-- Beacon+GPS 출퇴근 (조Beacon_GPS, 잠실지점)
INSERT INTO attendance_records (user_id, type, status, verification_method_id, verification_data, recorded_at) VALUES
    (11, 'CLOCK_IN',  'APPROVED', 15,
     '{"detected_devices": [{"device_id": "33333333-3333-3333-3333-333333333333", "device_name": "WC-Beacon-JS", "rssi": -59}], "device_count": 1, "latitude": 37.5135, "longitude": 127.1003, "accuracy": 4.5, "timestamp": "2026-03-10T09:02:00+09:00"}',
     '2026-03-10 09:02:00+09'),
    (11, 'CLOCK_OUT', 'APPROVED', 15,
     '{"detected_devices": [{"device_id": "33333333-3333-3333-3333-333333333333", "device_name": "WC-Beacon-JS", "rssi": -64}], "device_count": 1, "latitude": 37.5134, "longitude": 127.1002, "accuracy": 6.0, "timestamp": "2026-03-10T18:08:00+09:00"}',
     '2026-03-10 18:08:00+09');

-- ============================================
-- 8. 시퀀스 리셋 (시드 데이터 ID 충돌 방지)
-- ============================================
SELECT setval('companies_id_seq', (SELECT MAX(id) FROM companies));
SELECT setval('workplaces_id_seq', (SELECT MAX(id) FROM workplaces));
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('admin_users_id_seq', (SELECT MAX(id) FROM admin_users));
SELECT setval('verification_methods_id_seq', (SELECT MAX(id) FROM verification_methods));
SELECT setval('verification_configs_id_seq', (SELECT MAX(id) FROM verification_configs));
SELECT setval('attendance_records_id_seq', (SELECT MAX(id) FROM attendance_records));
