# WorkCheck 프로젝트

출퇴근 관리 앱 모노레포. Flutter 앱 + Kotlin Spring Boot 백엔드 + Flutter Web 관리자.

## 프로젝트 구조

```
workCheck/              # Flutter 모바일 앱 (attendance_app)
workCheck_backend/      # Kotlin Spring Boot API 서버
workCheck/admin_web/    # Flutter Web 관리자 페이지
docker-compose.yml      # api + db + web 컨테이너
```

## 코딩 규칙

- **MVP 우선**: 최소 기능 구현, 과도한 추상화/설계 금지
- **한국어 주석**: 모든 코드에 간단한 한국어 주석 작성
- **테스트 가능성**: 설정값을 변경하며 기능 테스트 가능하게 구현

## 커밋

- Co-Authored-By 라인 절대 추가하지 않음
- 커밋 메시지에 Claude/AI 관련 표시 없이 작성

## 하네스: WorkCheck 기능 개발

**목표:** 에이전트 팀으로 분석-설계-구현(병렬)-QA-테스트를 조율하여 기능을 개발한다.

**트리거:** 기능 추가, 새 기능 구현, '~ 추가해줘', '~ 만들어줘' 등 새 기능 구현 요청 시 `workcheck-feature` 스킬을 사용하라. QA/정합성 검증 요청 시 `qa-verify` 스킬을 사용하라. 단순 질문이나 버그 수정은 직접 응답 가능.

**변경 이력:**
| 날짜 | 변경 내용 | 대상 | 사유 |
|------|----------|------|------|
| 2026-04-12 | 초기 구성 (기존 하네스 정리) | 전체 | 루트 CLAUDE.md 부재, 중복 정보 정리 |
| 2026-04-12 | log-inspector 에이전트 추가 | agents/log-inspector.md | 컨테이너 로그 분석/디버깅 에이전트 필요 |
