# Testing Tools (Playwright MCP / tmux)

## Playwright MCP (웹 테스트)

- 웹 UI 테스트 시 Playwright MCP 우선 사용 (Chrome 네이티브보다 안정적)
- `browser_snapshot` 우선 (접근성 트리 기반, 효율적) → `browser_screenshot`는 시각 확인 필요 시만
- 워크플로우: `navigate` → `snapshot` → 요소 확인 → `click`/`type` → `snapshot`으로 결과 검증
- 테스트 완료 후 반드시 `browser_close` 호출

## tmux (터미널/CLI 테스트)

- CLI 도구, 인터랙티브 프로세스 테스트 시 tmux 사용
- 패턴: `tmux new-session -d -s test` → `send-keys` → `capture-pane -p` → 결과 검증
- git bisect 자동화, CI 테스트 등에 활용
- 테스트 완료 후 반드시 `tmux kill-session` 호출
