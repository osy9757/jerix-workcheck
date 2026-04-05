---
name: workcheck-feature
description: "WorkCheck 프로젝트의 기능 개발 오케스트레이터. 에이전트 팀을 구성하여 분석→설계→구현(병렬)→QA→테스트를 조율한다. '기능 추가', '새 기능', 'feature 구현', '기능 개발', '~ 추가해줘', '~ 만들어줘' 등 새 기능 구현 요청 시 반드시 이 스킬을 사용할 것. 단순 버그 수정이나 기존 코드 리팩토링에는 사용하지 않는다."
---

# WorkCheck Feature Orchestrator

WorkCheck 프로젝트에 새 기능을 추가할 때 에이전트 팀을 조율하는 오케스트레이터.

## 실행 모드: 에이전트 팀

## 에이전트 구성

| 팀원 | 에이전트 타입 | 역할 | 출력 |
|------|-------------|------|------|
| researcher | researcher | 현재 코드 상태 분석, 영향 범위 파악 | analysis_report.md |
| backend-dev | backend-dev | API 설계 및 구현 | API 코드 + contract.md |
| flutter-dev | flutter-dev | Flutter 앱 기능 구현 | Flutter 코드 |
| web-dev | web-dev | Admin Web 기능 구현 | Web 코드 |
| qa-inspector | qa-inspector | 통합 정합성 검증 | qa_report.md |
| tester | tester | 테스트 작성 및 실행 | 테스트 코드 + 결과 |

> 모든 에이전트가 필요하지 않으면 해당 기능에 필요한 에이전트만 선택적으로 포함한다.

## 워크플로우

### Phase 0: 범위 판단

사용자 요청을 분석하여 영향 범위를 파악한다:

| 영향 범위 | 필요 에이전트 | 예시 |
|----------|-------------|------|
| 백엔드만 | backend-dev, tester, qa-inspector | 새 API 추가 |
| 프론트만 | flutter-dev, tester | UI 내부 로직 변경 |
| 풀스택 | 전원 | 새 인증 방법 추가 |
| 웹만 | web-dev, tester | 관리자 페이지 기능 |
| 백엔드+프론트 | backend-dev, flutter-dev, qa-inspector, tester | API 변경 + 앱 연동 |
| 백엔드+웹 | backend-dev, web-dev, qa-inspector, tester | API 변경 + 관리자 연동 |

### Phase 1: 분석

researcher를 서브 에이전트로 호출 (팀 구성 전 선행 분석):

```
Agent(
  name: "researcher",
  subagent_type: "researcher",
  model: "opus",
  prompt: "다음 기능에 대해 코드베이스를 분석하라: {기능 설명}
    1. 관련 파일 목록 (백엔드/프론트/웹 각각)
    2. 영향받는 API 엔드포인트
    3. 변경이 필요한 DB 테이블/Entity/DTO
    4. 기존 유사 기능의 구현 패턴
    결과를 _workspace/01_analysis.md에 저장하라."
)
```

### Phase 2: 팀 구성 + 작업 등록

1. TeamCreate(team_name: "workcheck-feature")
2. Phase 0에서 결정한 필요 에이전트만 스폰 (model: "opus" 필수)
3. TaskCreate로 작업 등록 (의존성 명시)

각 에이전트 프롬프트 필수 포함:
```
너는 workcheck-feature 팀의 {에이전트명}이다.
1. workCheck/CLAUDE.md를 읽어라
2. _workspace/01_analysis.md를 읽어 분석 결과를 파악하라
3. TaskList를 확인하여 태스크를 claim하고 작업을 시작하라
```

### Phase 3: 구현

**실행 방식**: 팀원들이 자체 조율

- backend-dev가 먼저 API를 구현하고 `_workspace/api_contract.md`에 요청/응답 shape 기록
- API Contract 완성 후 flutter-dev와 web-dev가 병렬로 클라이언트 구현
- 구현 중 API 질문이 있으면 backend-dev에게 직접 SendMessage

**핵심 산출물 — API Contract**:
```markdown
# API Contract: {기능명}
## POST /api/v1/{resource}
- Request Body: { "field1": "string" }
- Response (200): { "id": 1, "field1": "string" }
- Response (400): { "error": "메시지" }
```

### Phase 4: 점진적 QA

각 모듈 완성 직후 qa-inspector가 해당 경계면을 검증:
- backend-dev 완성 → DB↔Entity↔DTO 체인 검증
- flutter-dev 완성 → API↔Flutter 경계면 검증
- web-dev 완성 → API↔Admin Web 경계면 검증

불일치 발견 시 해당 에이전트에게 직접 수정 요청 (최대 2회 재검증).

### Phase 5: 테스트

tester가 통합 테스트 수행:
- API 엔드포인트 동작 확인
- Flutter 빌드 확인
- Admin Web 빌드 확인

### Phase 6: 정리

1. 모든 작업 완료 확인 (TaskGet)
2. 팀원들에게 종료 요청 (SendMessage shutdown_request)
3. 팀 정리 (TeamDelete)
4. `_workspace/` 보존
5. 사용자에게 결과 요약

## 데이터 흐름

```
[사용자 요청]
      ↓
[researcher] → _workspace/01_analysis.md
      ↓
[팀리드] → TeamCreate + TaskCreate
      ↓
[backend-dev] → API 코드 + _workspace/api_contract.md
      ↓ (API Contract 공유)
[flutter-dev] ──병렬──→ Flutter 코드
[web-dev]    ──병렬──→ Web 코드
      ↓ (각 모듈 완성 시)
[qa-inspector] → 경계면 검증 → 수정 요청 or 통과
      ↓
[tester] → 통합 테스트
      ↓
[팀리드] → 결과 종합 → 사용자 보고
```

## 에러 핸들링

| 상황 | 전략 |
|------|------|
| 에이전트 1명 중지 | SendMessage로 상태 확인 → 재시작 또는 작업 재할당 |
| API Contract 지연 | flutter-dev/web-dev에게 대기 알림, 선행 가능 작업부터 |
| QA 불일치 발견 | 해당 에이전트에 수정 요청 → 수정 후 재검증 (최대 2회) |
| 빌드 실패 | tester가 에러 분석 → 해당 에이전트에 수정 요청 |
| 에이전트 과반 실패 | 사용자에게 알리고 진행 여부 확인 |

## 테스트 시나리오

### 정상 흐름
1. 사용자: "출퇴근 기록에 메모 필드를 추가해줘"
2. researcher 분석 → 백엔드+프론트 범위
3. backend-dev: DB 컬럼 추가 → Entity/DTO 수정 → API 수정 → Contract 작성
4. flutter-dev: Contract 기반으로 모델/BLoC 수정
5. qa-inspector: API↔Flutter 경계면 검증 → 통과
6. tester: API + 빌드 테스트 → 통과

### 에러 흐름
1. qa-inspector가 DTO 필드명 불일치 발견
2. flutter-dev에게 수정 요청 → 수정 → 재검증 → 통과

상세 워크플로우는 `references/workflow-guide.md` 참조.
