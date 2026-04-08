# CLAUDE.md

개인 글로벌 가이드. 모든 프로젝트에 적용. 상세 내용은 `~/.claude/rules/` 하위 파일을 참조한다.

## 핵심 원칙

- **원자적 커밋**: 멀티 스텝 작업은 한 단계 = 하나의 커밋. 한 단계 구현 → 린트 → `/commit` → 다음 단계
- **출처 명시**: 외부 도구(Slack/Linear/Confluence)에서 정보를 가져오면 반드시 출처 링크 포함
- **사용자 명시 요청 없이는 git push 금지**

## 상세 규칙 (필요 시 참조)

- 워크플로우(원자적 커밋, 린트→테스트→커밋, 작업 분해, 컨텍스트 관리, 한국어 커밋) → `~/.claude/rules/workflow.md`
- MCP 도구 우선순위(Slack/Linear/Confluence) → `~/.claude/rules/mcp-priority.md`
- 테스팅 도구(Playwright MCP, tmux) → `~/.claude/rules/testing-tools.md`
- 외부 스킬/플러그인 보안 → `~/.claude/rules/external-skill-security.md`
- 테스트 작성 규칙(구현 미러링 금지 등) → `~/.claude/rules/testing-rules.md` (ts/tsx 편집 시 자동 로드)

## 메타 규칙

- 이 파일은 목차이며 상세는 `rules/`에. 내용 추가 시 적절한 rules/ 파일로 이동 우선
