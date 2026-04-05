# /team - 개발 팀 스폰 및 관리

프로젝트에 개발 팀을 생성하고 에이전트를 스폰한다. 워크플로우 없이, 팀 생성과 에이전트 관리만 담당.

## 사용법

```
/team                      # 5명 전원 스폰
/team backend              # backend-dev만
/team frontend             # frontend-dev만
/team web                  # web-dev만
/team test                 # tester만
/team research             # researcher만
/team backend frontend     # 복수 선택
```

## 기본 멤버 (5명)

| 별칭 | 에이전트 이름 | subagent_type | 역할 |
|------|-------------|--------------|------|
| backend | backend-dev | backend-dev | 백엔드 API 개발 |
| frontend | frontend-dev | flutter-dev | 프론트엔드 앱 개발 |
| web | web-dev | web-dev | 웹 프론트엔드 개발 |
| test | tester | tester | 테스트 작성/실행 |
| research | researcher | researcher | 코드베이스 분석 (읽기 전용) |

## 실행 절차

### 1. 인자 파싱
- 인자 없음 → 5명 전원 스폰
- 인자 있음 → 해당 별칭의 멤버만 스폰 (복수 가능)
- 인식 가능한 별칭: backend, frontend, web, test, research

### 2. 팀 생성
TeamCreate로 팀 생성. 팀 이름은 현재 프로젝트 디렉토리명 기반으로 자동 생성.

### 3. 에이전트 스폰
요청된 멤버를 Agent tool로 **모두 병렬로** 백그라운드 스폰한다.

각 에이전트의 프롬프트에 반드시 포함:
```
너는 {팀이름} 팀의 {에이전트이름}이다.

## 시작 절차
1. 프로젝트의 CLAUDE.md를 찾아서 읽어라 (Glob으로 **/CLAUDE.md 검색)
2. TaskList를 확인해라
   - 태스크가 있으면: 너에게 적합한 태스크를 claim하고 (TaskUpdate로 owner 설정 + status를 in_progress로) 작업을 시작해라
   - 태스크가 없으면: 팀리드에게 "대기 중입니다. 태스크를 할당해주세요."라고 SendMessage를 보내라

## 작업 규칙
- CLAUDE.md의 코딩 규칙을 반드시 따라라
- 태스크 완료 시: TaskUpdate로 completed 처리 → 팀리드에게 결과 보고 (SendMessage)
- 보고 후: TaskList에서 다음 태스크 확인 → 있으면 claim, 없으면 대기
- shutdown 요청이 올 때까지 종료하지 마라
```

### 4. 팀 상태 보고
모든 에이전트 스폰 후, 사용자에게 팀 구성을 보고:
```
팀 생성 완료:
- backend-dev ✓
- frontend-dev ✓
- ...

태스크를 지시하면 적절한 에이전트에게 배분하겠습니다.
```

## 팀 운영 규칙

### 태스크 배분 (팀리드 역할)
1. 사용자가 작업을 지시하면
2. 팀리드가 TaskCreate로 태스크 생성
3. 적절한 에이전트에게 SendMessage로 태스크 할당
4. 에이전트가 TaskUpdate로 claim 후 작업

### 테스트 검증 (필수)
모든 태스크는 완료 후 반드시 **tester가 검증**한다:
1. 구현 에이전트가 태스크 완료 보고
2. 팀리드가 tester에게 검증 태스크를 생성/할당 (원래 태스크의 결과물을 검증)
3. tester가 빌드 확인, 테스트 실행, 기능 동작 확인
4. tester 검증 통과 → 태스크 최종 완료
5. tester 검증 실패 → 원래 담당 에이전트에게 수정 요청

팀리드는 구현 에이전트의 완료 보고를 받으면, **자동으로 tester 검증 태스크를 생성**해야 한다.
검증 태스크 예시: "Task #N 검증: [원래 태스크 제목]의 구현 결과를 테스트하라"

### 에이전트 유지
- 태스크 완료 후 에이전트를 **종료하지 않는다**
- idle 상태로 대기하다가 새 태스크가 오면 다시 작업
- 사용자가 명시적으로 종료를 요청할 때만 shutdown_request

### 세션 종료 시 정리
- 비활성 에이전트의 tmux 패널 정리: `tmux kill-pane -t {pane_id}`
- 팀 config에서 비활성 멤버 제거

### 팀 종료
사용자가 "팀 종료", "팀 정리" 등을 요청하면:
1. 모든 에이전트에게 shutdown_request
2. 전원 종료 확인 후 TeamDelete

## 핵심 원칙
1. **워크플로우 없음**: 스킬이 태스크를 자동 생성하지 않음
2. **사용자 → 팀리드 → 에이전트**: 팀리드가 중간에서 태스크 배분
3. **에이전트 유지**: 한번 스폰하면 shutdown 전까지 유지
4. **CLAUDE.md 우선**: 모든 에이전트는 프로젝트 CLAUDE.md를 따름
5. **병렬 스폰**: 에이전트는 항상 병렬로 스폰
6. **테스트 필수**: 모든 태스크 완료 후 tester 검증 필수
