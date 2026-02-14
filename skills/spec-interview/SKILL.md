---
name: spec-interview
description: Linear 이슈를 읽고 코드베이스를 탐색한 뒤, 인터뷰를 통해 구현 가능한 상세 스펙을 작성합니다. "스펙 작성", "스펙 인터뷰", "spec interview" 등의 요청 시 사용합니다.
---

# Spec Interview

Linear 이슈를 읽고, 코드베이스를 탐색하고, 인터뷰를 거쳐 구현 가능한 상세 스펙을 작성합니다.

## 실행 절차

### 1단계: 이슈 가져오기

**이슈 번호 결정 순서:**
1. `$ARGUMENTS`가 제공된 경우 → 해당 값 사용
2. `$ARGUMENTS`가 없는 경우 → `git branch --show-current`로 현재 브랜치 이름 확인
   - 브랜치 이름에 이슈 번호 패턴(예: `sup-907`, `eng-123`)이 포함되어 있으면 → 해당 번호 사용
   - 이슈 번호가 없으면 → `AskUserQuestion`으로 Linear 이슈 ID 또는 URL을 질문

- `mcp__claude_ai_Linear__get_issue`로 이슈 조회
- 부모 이슈가 있으면 (`parentId` 존재) 부모 이슈도 함께 조회하여 상위 컨텍스트 파악
- 복잡도 판단: **Simple** (하루 안에 완료 가능) vs **Complex** (여러 서브태스크 필요)
- 이슈 제목/설명의 **언어를 감지**하여 스펙 작성 언어로 사용

### 2단계: 코드베이스 탐색
관련 코드를 탐색하여 구현 컨텍스트를 파악합니다.

**도구 우선순위:**
1. **Grep/Glob** - 정확한 함수/클래스명 검색
2. **Task(Explore)** - 넓은 범위 탐색이 필요할 때

**탐색 대상:**
- 기존 유사 구현
- 영향받는 파일
- 코딩 패턴 및 컨벤션
- 관련 인터페이스/타입

### 3단계: 인터뷰
`AskUserQuestion`을 사용하여 심층 인터뷰를 진행합니다:
- 코드를 읽으면 알 수 있는 질문은 하지 않기
- 비즈니스 결정, 엣지 케이스 처리, 스코프 경계에 집중
- 충분한 정보가 모일 때까지 계속 진행

### 4단계: 스펙 작성

> **언어**: 이슈와 동일한 언어로 작성 (한국어/영어 등)

#### Case A: Simple 태스크
이슈 description에 직접 작성 (STICC 구조, 헤더 텍스트 없이):

```markdown
## Situation (상황)
구체적인 파일 참조와 함께 현재 상태와 컨텍스트 설명.
- 현재 구현: `path/to/file.py:ClassName`
- 문제: [코드 참조와 함께 설명]

## Task (작업)
파일 레벨의 구체적 작업:

### 1. `path/to/file.py` 수정
- `ClassName`에 `new_method()` 추가
- `existing_method()` 업데이트

### 2. `path/to/new_file.py` 생성
- `existing_pattern.py`의 패턴을 따라 `NewClass` 구현

## Intent (의도)
비즈니스 목표와 기술적 목표.

## Concerns (주의사항)
- `specific_caller.py:line_number`와의 하위 호환성
- `hot_path_function()`에 대한 성능 영향
- 엣지 케이스: [구체적 시나리오]

## Acceptance Criteria (완료 기준)

### Code Changes
- [ ] `path/to/file.py`: `new_method()` 구현됨
- [ ] `path/to/file.py`: `existing_method()` 업데이트됨
- [ ] `path/to/new_file.py`: 새 파일 생성됨

### Tests (delegate to tester)
> Delegate to `oh-my-claude-sisyphus:qa-tester` or `/test` skill.
> Pass only file patterns - tester knows how to test properly.

| Test Target | Pattern |
|-------------|---------|
| Unit tests | `tests/unit/**/test_*.py` |
| E2E tests | `tests/e2e/**/test_*.py` |
| Affected modules | `path/to/module/` |

### Quality Gates
- [ ] Tests pass (delegated)
- [ ] Lint passes

## End State (최종 상태)

### Files Changed
| File | Changes |
|------|---------|
| `path/to/file.py` | Added `new_method()`, modified `existing_method()` |
| `path/to/new_file.py` | New file with `NewClass` |

### Behavior Changes
- API `/endpoint` returns `new_field`
- `ClassName.process()` handles edge case X

### Test Targets
> For tester agent - pass these patterns only:
```
tests/unit/test_new_feature.py
tests/e2e/test_new_feature_api.py
path/to/affected/module/
```
```

#### Case B: Complex 태스크
서브태스크를 생성하고 부모 이슈를 Orchestration Issue로 전환:

```markdown
## Execution Plan for AI Agent

> **Follow this execution plan to complete subtasks in order.**
> **Refer to each subtask ticket for detailed specs and acceptance criteria.**

### Quick Reference
- **Entry point**: `src/path/to/main_file.py`
- **Test command**: `make test` or `pytest path/`
- **Key pattern**: [e.g., Repository pattern in `src/repos/`]

### Phase 1: [Phase Name]

| # | Ticket | Status | Summary | Key Files | Depends |
|---|--------|--------|---------|-----------|---------|
| 1 | TICKET-1 | ⬜ | Work summary | `file1.py` | - |
| 2 | TICKET-2 | ⬜ | Work summary | `file2.py` | - |

### Phase 2: [Phase Name]

| # | Ticket | Status | Summary | Key Files | Depends |
|---|--------|--------|---------|-----------|---------|
| 3 | TICKET-3 | ⬜ | Work summary | `file3.py` | 1, 2 |

### Phase N: Testing (delegate)

| # | Ticket | Status | Summary | Test Patterns | Depends |
|---|--------|--------|---------|---------------|---------|
| N | TICKET-N | ⬜ | Test verification | `tests/**/test_*.py` | all |

> **Testing Phase**: Delegate to `oh-my-claude-sisyphus:qa-tester`

---

### Execution Order (Linearized)

> **Follow this order. Parallelize within same step if capable.**

1. **Step 1**: TICKET-1, TICKET-2 (parallel)
2. **Step 2**: TICKET-3 (after step 1)
3. **Step N**: TICKET-N - Testing (delegate to tester)

### Status Legend
- ⬜ Not started
- 🔄 In progress
- ✅ Completed
- ⏸️ Blocked

---

## Summary

**Goal**: One-sentence overall objective

**Key Changes**:
1. Change 1
2. Change 2

**Rollout**: Deployment strategy (feature flag, gradual, big bang, etc.)
```

### 5단계: 변경사항 적용
- **Simple**: `mcp__claude_ai_Linear__update_issue`로 이슈 description 업데이트
- **Complex**:
  - `mcp__claude_ai_Linear__create_issue`로 서브태스크 생성 (`parentId` 설정)
  - 부모 이슈 description을 orchestration 내용으로 업데이트

## 주의사항
- 코드베이스를 먼저 탐색하고 질문하기 - 사용자에게 부담 주지 않기
- "STICC Framework" 같은 메타 텍스트를 이슈에 포함하지 않기
- Acceptance Criteria를 Code Changes / Tests / Quality Gates로 명확히 분리

## 체크리스트
- [ ] 이슈 조회 완료
- [ ] 코드베이스 탐색, 관련 파일/패턴 식별 완료
- [ ] 인터뷰 완료, 비즈니스 결정 확인됨
- [ ] 스펙에 구체적인 파일 경로 포함됨
- [ ] Acceptance Criteria가 Code Changes / Tests / Quality Gates로 분리됨
- [ ] End State에 Files Changed 테이블 포함됨
- [ ] Test Targets 섹션에 테스터용 패턴 명시됨
- [ ] 스펙이 Linear 이슈에 저장됨
