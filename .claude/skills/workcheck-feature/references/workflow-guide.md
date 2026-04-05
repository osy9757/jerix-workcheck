# 워크플로우 상세 가이드

## 범위별 에이전트 조합 레시피

### 백엔드만
```
에이전트: backend-dev, tester, qa-inspector
작업 흐름:
1. backend-dev → DB/Entity/DTO/API 구현
2. qa-inspector → DB↔Entity↔DTO 체인 검증
3. tester → API 테스트
```

### 프론트만 (Flutter 앱)
```
에이전트: flutter-dev, tester
작업 흐름:
1. flutter-dev → 모델/BLoC/서비스 구현
2. tester → Flutter 테스트
```

### 풀스택
```
에이전트: 전원 (6명)
작업 흐름: SKILL.md Phase 1~6 전체
```

### 새 인증 방법 추가 (특수)
```
에이전트: 전원
추가 주의:
- 8가지 방법 목록에 새 방법 추가
- verification_methods JSONB config 구조 설계
- Flutter VerificationManager에 새 방법 핸들러 추가
- Admin Web에 새 설정 폼 추가
- 3곳의 config 키명 일치 필수 → QA 검증 강화
```

## API Contract 작성 규칙

1. 모든 필드명은 camelCase로 통일 (DB는 snake_case이지만 API 응답은 camelCase)
2. 날짜/시간은 ISO 8601 형식 ("2024-01-01T00:00:00")
3. 목록 API는 배열 직접 반환 (래핑 없음)
4. 에러 응답은 `{ "error": "메시지" }` 형식
5. ID는 Long/int 타입

## 팀 크기 가이드라인

| 기능 규모 | 권장 팀원 수 |
|----------|------------|
| 소규모 (필드 추가, 단순 CRUD) | 2~3명 |
| 중규모 (새 엔티티 + CRUD + 연동) | 3~5명 |
| 대규모 (새 인증 방법, 대규모 리팩토링) | 5~6명 |
