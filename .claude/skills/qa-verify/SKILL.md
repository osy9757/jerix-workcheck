---
name: qa-verify
description: "WorkCheck 프로젝트의 통합 정합성 검증 스킬. API↔Flutter, API↔Admin Web, DB↔Entity↔DTO 경계면을 교차 비교한다. QA, 검증, 정합성, 통합 테스트, 경계면 확인 요청 시 반드시 이 스킬을 사용할 것."
---

# QA Verify — 통합 정합성 검증

WorkCheck 프로젝트의 모듈 간 경계면을 교차 비교하여 통합 정합성을 검증하는 스킬.

## 검증 영역

### 1. API DTO ↔ Flutter Retrofit/Freezed 모델

백엔드 DTO 클래스의 필드와 Flutter freezed 모델의 필드를 1:1 비교한다.

```
검증 단계:
1. workCheck_backend/src/main/kotlin/.../dto/ 에서 DTO 클래스의 필드명/타입 추출
2. workCheck/attendance_app/lib/features/.../data/models/ 에서 freezed 모델 필드 추출
3. 필드명 매핑 확인 (camelCase ↔ snake_case → @JsonKey 확인)
4. 타입 매핑 확인 (Long→int, String→String, LocalDateTime→DateTime 등)
5. nullable 여부 일치 확인
```

주의 패턴:
- Kotlin `Long` vs Dart `int` — 범위 문제
- Kotlin `LocalDateTime` vs Dart `DateTime` — 직렬화 형식 일치
- JSONB config 필드 — Map<String, dynamic> vs 구체 DTO

### 2. API DTO ↔ Admin Web api_service.dart

```
검증 단계:
1. API 응답 shape (DTO 필드 목록) 추출
2. admin_web/lib/의 api_service.dart에서 해당 API 호출 찾기
3. 응답 파싱 로직이 DTO shape과 일치하는지 확인
4. List 래핑 여부 (API가 {items:[]} 반환 vs 배열 직접 반환)
```

### 3. DB 스키마 ↔ JPA Entity ↔ DTO 체인

```
검증 단계:
1. schema.sql에서 테이블 컬럼명/타입 추출
2. Entity 클래스에서 @Column 매핑 확인
3. Entity → DTO 변환 로직에서 필드 누락 없는지 확인
4. verification_methods.config (JSONB) → VerificationMethod entity → DTO 변환
```

### 4. 인증 설정 정합성

8가지 인증 방법의 설정 구조가 3곳(DB, Flutter, Admin Web)에서 일관되는지 확인한다.

```
검증 단계:
1. 백엔드의 VerificationMethod config JSONB 구조 확인
2. Flutter의 VerificationManager가 같은 config 키를 사용하는지
3. Admin Web의 설정 폼이 같은 키를 편집하는지
4. 8가지 방법 각각에 대해 반복
```

## 검증 리포트 형식

```markdown
# QA 검증 리포트

## 요약
- ✅ 통과: N건
- ❌ 실패: N건
- ⏸️ 미검증: N건

## 경계면별 결과

### API ↔ Flutter
- [x] AttendanceRecord DTO ↔ attendance_record.freezed.dart — 일치
- [ ] VerificationConfig DTO ↔ verification_config.freezed.dart — 불일치
  - 불일치: DTO.configData (Map) vs Model.config (String)
  - 위치: DTO — VerificationConfigDto.kt:15, Model — verification_config.dart:8
  - 수정: Flutter 모델에서 config 필드 타입을 Map<String, dynamic>으로 변경
```

상세 체크리스트는 `references/checklist.md` 참조.
