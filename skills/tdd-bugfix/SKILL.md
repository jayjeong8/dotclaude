---
name: tdd-bugfix
description: Use when fixing a bug, regression, or incorrect behavior with a reproducible symptom — user-reported bugs, failing test output, wrong return values, empty/zero/null/boundary edge cases, "X doesn't work" reports, "이 버그 고쳐줘" 류 요청.
---

# TDD Bug Fix

## 핵심 원칙

버그는 **재현 가능한 실패 테스트가 먼저**다. 구현 코드보다 테스트가 먼저 작성되어야 하고, 테스트 없이 "고쳤다"고 보고하지 않는다. **테스트가 없으면 버그가 다시 돌아온다.**

**REQUIRED BACKGROUND:**
- `superpowers:test-driven-development` — RED-GREEN-REFACTOR 사이클
- `superpowers:systematic-debugging` — 근본 원인 우선 원칙

**REQUIRED LOOP:** `~/.claude/rules/workflow.md` 의 원자적 커밋 루프(한 단계 → 린트 → `/commit`)

## When to Use

- 사용자 보고 버그 / 재현 가능한 잘못된 동작
- 회귀(regression) — 예전에 동작했는데 깨진 것
- 엣지 케이스: 빈 배열, `0`, `null`/`undefined`, 경계값, 유니코드, 음수
- 특정 입력에서 틀린 반환값
- 이미 실패하고 있는 테스트가 존재

## When NOT to Use

- 타입 에러만 있는 경우 → `fix-types`
- 재현 불가능한 플래키 → 먼저 `debug` + `superpowers:systematic-debugging`으로 원인 좁히고, 재현이 잡히면 그때 이 스킬
- 리팩토링·코드 정리 → `refactor`, `simplify`
- UX 개선이나 신규 기능 → `brainstorming` 후 일반 구현 워크플로우

## 절차

1. **재현 이해** — 관련 소스 읽기, 현재 동작 파악, 스택트레이스/에러 메시지 수집. 코드를 만지기 전에 "왜 이렇게 동작하는가"를 한 문장으로 말할 수 있어야 한다.
2. **실패 테스트 작성** — 버그를 정확히 찌르는 테스트 1개. 보고된 입력과 같은 종류의 엣지 케이스(empty/0/null/boundary)를 포함시킨다.
3. **테스트 실행 → 실패 확인** — 에러 메시지가 보고된 증상과 일치하는지 검증. 일치하지 않으면 1단계로 돌아가 재현이 틀린 것이다.
4. **최소 수정** — 테스트를 통과시킬 최소한의 변경. 주변 코드 정리·리팩토링·"겸사겸사" 금지.
5. **전체 테스트 실행** — 프로젝트 전체 테스트. 다른 테스트가 깨지면 분석 → 수정 → 재실행 루프. 모두 그린이 될 때까지 멈추지 않는다.
6. **린트 + 빌드/타입체크** — 수정 파일 린트, 전체 타입체크/빌드. 실패 시 커밋 금지.
7. **원자적 커밋** — `/commit` 호출. 테스트와 구현은 같은 커밋에 묶어도 좋다(원자적 = 버그 하나 = 커밋 하나).

## 커밋 메시지 형식

```
fix: <한 줄 증상>

- 근본 원인: <왜 이 버그가 발생했는가>
- 수정: <무엇을 어떻게 바꿨는가>
- 테스트: <어떤 테스트가 회귀를 막는가>
```

## Red Flags — STOP and Restart

다음 생각이 떠오르면 이 스킬 위반이다. 수정을 폐기하고 2단계(실패 테스트 작성)부터 다시 시작.

- "테스트 먼저는 번거로우니 고치고 나서 쓰자"
- "이 버그는 너무 자명해서 테스트 필요 없음"
- "수동으로 확인했으니 OK"
- "겸사겸사 주변도 정리했음"
- "근본 원인은 다음에 보고 일단 패치"
- 테스트 작성 없이 "수정 완료" 보고

## 합리화 대응표

| 변명 | 현실 |
|------|------|
| "버그가 너무 자명해서 테스트 불필요" | 자명한 버그일수록 30초면 테스트가 써진다. 안 쓰는 건 게으름. |
| "기존 테스트만 살짝 고치면 됨" | 기존 테스트는 기존 동작을 보호한다. 이 버그는 **새 테스트**가 필요. |
| "통합테스트 환경 구성이 어려움" | 유닛 테스트라도 좋다. 단, **반드시 재현해야 함**. |
| "린트만 실패하니 커밋 강행" | 린트 실패 = 커밋 금지. `~/.claude/rules/workflow.md`. |
| "테스트 한 번 깨지는 거 봤으면 충분" | 봐야 할 건 **버그 증상과 동일한 실패 메시지**. 그냥 빨간색이 아니다. |

## 참고

- TypeScript 에러만 있는 경우: `fix-types`
- 일반 디버깅(원인 탐색): `debug` + `superpowers:systematic-debugging`
- 멀티 스텝 수정이 필요하면: 계획 후 `stepwise-refactor`로 단계별 실행
