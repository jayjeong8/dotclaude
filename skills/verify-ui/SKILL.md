---
name: verify-ui
description: Playwright MCP로 웹 UI를 검증합니다. "UI 확인해줘", "화면 검증" 등의 요청 시 사용합니다.
---

# UI 검증

Playwright MCP를 사용하여 웹 UI가 의도대로 렌더링/동작하는지 검증하는 스킬.

## 트리거

`/verify-ui [URL] [확인사항]` 또는 `/verify-ui`

## 실행 절차

### 1단계: dev 서버 확인

tmux로 dev 서버 실행 여부를 확인한다.

```bash
tmux has-session -t dev 2>/dev/null && echo "running" || echo "not running"
```

- 실행 중이면 → 2단계로 진행
- 미실행 시 → 프로젝트 구조를 파악하여 tmux 세션에서 시작:
  1. `package.json`의 `scripts.dev` 명령 확인
  2. monorepo면 해당 앱 디렉토리에서 실행 (CLAUDE.md 또는 workspace 구조 참조)
  3. `tmux new-session -d -s dev -c "<앱 디렉토리>" '<패키지매니저> dev'`
  4. 서버 준비까지 3~5초 대기 후 진행

### 2단계: URL 결정

- 인자로 URL 전달 시 → 해당 URL 사용
- 없으면 아래 순서로 추론:
  1. dev 서버 출력에서 URL 확인: `tmux capture-pane -t dev -p | grep -oE 'https?://localhost:[0-9]+'`
  2. 현재 작업 중인 파일에서 라우트 추론 (router 설정 파일 참조)
  3. 위 방법으로 확인 불가 시 사용자에게 질문

### 3단계: 구조 검증 (browser_snapshot)

1. `browser_navigate` → URL 접속
2. `browser_snapshot` → 접근성 트리로 페이지 구조 확인
3. 기대하는 요소가 렌더링되었는지 확인

### 4단계: 인터랙션 검증 (선택)

확인사항에 인터랙션이 포함되면:

1. `browser_click`, `browser_type`, `browser_select_option` 등으로 조작
2. 각 인터랙션 후 `browser_snapshot`으로 결과 확인

### 5단계: 시각 검증 (선택)

- 레이아웃/디자인 확인이 필요한 경우에만 `browser_screenshot` 사용
- 기본은 `browser_snapshot` (토큰 효율)

### 6단계: 결과 보고

검증 결과를 정리하여 보고:

- 통과/실패 항목 목록
- 실패 시 원인 분석과 수정 제안

### 7단계: 정리

- `browser_close` 호출
- dev 서버는 유지 (사용자가 계속 작업할 수 있도록)

## 토큰 효율 가이드

- `browser_snapshot` 우선 (접근성 트리, 텍스트 기반)
- `browser_screenshot`는 시각적 확인 필요 시만 사용
- 한 페이지 검증에 snapshot 2~3회 이내 권장
