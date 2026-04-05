# QA 검증 체크리스트

## API ↔ 클라이언트 연결

### Flutter 앱
- [ ] 모든 Retrofit 인터페이스의 엔드포인트 URL이 백엔드 Controller 매핑과 일치
- [ ] 모든 freezed 모델의 필드명이 DTO의 JSON 직렬화 필드명과 일치
- [ ] @JsonKey(name:) 어노테이션이 snake_case ↔ camelCase 변환을 올바르게 처리
- [ ] nullable 필드가 양쪽에서 일관됨 (DTO의 ? vs freezed의 ?)
- [ ] List 래핑: API가 배열을 직접 반환하면 Retrofit 반환 타입도 List<T>
- [ ] 날짜/시간 형식: ISO 8601 직렬화가 양쪽에서 일치
- [ ] HTTP 메서드 일치 (GET/POST/PUT/DELETE)

### Admin Web
- [ ] api_service.dart의 모든 API URL이 백엔드 Controller 매핑과 일치
- [ ] 응답 파싱이 실제 API 응답 shape과 일치
- [ ] 요청 body의 필드명이 DTO의 @RequestBody 필드와 일치

## DB ↔ Entity ↔ DTO 체인
- [ ] schema.sql의 모든 컬럼이 Entity에 매핑됨
- [ ] Entity의 @Column(name=) 이 schema.sql 컬럼명과 일치
- [ ] Entity → DTO 변환에서 필수 필드 누락 없음
- [ ] JSONB 컬럼 (verification_methods.config)의 파싱이 올바름

## 인증 방법 설정 정합성
- [ ] GPS: 좌표(lat/lng), 반경(radius) — 3곳 키명 일치
- [ ] GPS+QR: 좌표, 반경, QR코드 — 3곳 키명 일치
- [ ] WiFi: SSID, BSSID — 3곳 키명 일치
- [ ] WiFi+QR: SSID, BSSID, QR코드 — 3곳 키명 일치
- [ ] NFC: 태그 ID — 3곳 키명 일치
- [ ] NFC+GPS: 태그 ID, 좌표, 반경 — 3곳 키명 일치
- [ ] Beacon: UUID, Major, Minor, RSSI — 3곳 키명 일치
- [ ] Beacon+GPS: UUID, Major, Minor, RSSI, 좌표, 반경 — 3곳 키명 일치

## 라우팅/네비게이션
- [ ] Flutter 앱의 go_router 경로가 실제 화면 파일과 매핑
- [ ] Admin Web의 라우팅이 실제 페이지 파일과 매핑
