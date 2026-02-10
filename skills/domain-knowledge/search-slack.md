# Slack 검색 가이드

## MCP 설정 상태

Slack MCP 서버가 설치됨 (`mcp.slack.com/sse`, SSE 방식).
OAuth 인증 완료 후 `mcp__slack__*` 도구가 활성화된다.

## MCP 유무에 따른 분기

### Slack MCP가 활성화된 경우

`mcp__slack__` 접두사의 도구가 사용 가능하면 MCP를 통해 직접 검색한다.

**주요 도구** (공식 Slack MCP 서버 기준):
- `mcp__slack__search_messages` — 메시지 검색 (query, sort, sort_dir, count)
- `mcp__slack__search_files` — 파일 검색
- `mcp__slack__get_channels` — 채널 목록 조회
- `mcp__slack__get_channel_messages` — 채널 메시지 조회
- `mcp__slack__get_thread_replies` — 스레드 답글 조회
- `mcp__slack__get_users` — 사용자 목록 조회

> **참고**: 실제 도구명은 MCP 서버 버전에 따라 다를 수 있다.
> 사용 가능한 도구는 `mcp__slack__` 접두사로 자동 감지할 것.

**검색 절차**:
1. 관련 채널 특정 (채널명을 알면 바로 검색, 모르면 채널 목록에서 탐색)
2. 키워드로 메시지 검색 (최근 3개월 우선)
3. 유관 메시지의 스레드 답글까지 확인
4. 결과 정리: 작성자, 날짜, 채널, 핵심 내용

### Slack MCP가 없거나 인증 미완료인 경우

`mcp__slack__*` 도구가 없으면 사용자에게 직접 검색을 요청한다.

**인증 안내** (MCP 서버는 설치되었으나 인증이 안 된 경우):
```
Slack MCP가 설치되어 있지만 인증이 필요합니다.
Claude Code를 재시작하면 OAuth 인증 플로우가 시작됩니다.
```

**검색 요청 템플릿** (MCP 사용 불가 시):
```
Slack에서 직접 검색이 필요합니다:

1. Slack 검색창에 다음 키워드를 입력해 주세요:
   - 검색어: `[키워드1] [키워드2]`
   - 추천 필터: `in:#[채널명]` `after:2025-01-01`

2. 관련 메시지를 찾으시면 내용을 공유해 주세요.
```

## 검색 팁
- Slack 검색 연산자 활용: `from:@사용자`, `in:#채널`, `before:날짜`, `after:날짜`
- 한국어/영어 키워드 모두 시도
- 일반 채널뿐 아니라 프로젝트/팀 전용 채널도 확인
- 중요 결정은 보통 스레드 답글에 있으므로 스레드 확인 필수

## 결과 정리 형식
- 채널: `#channel-name`
- 메시지: `@작성자` - 핵심 내용 요약 (날짜)
- 스레드가 있으면: 주요 답글 내용 포함
