# Confluence 검색 가이드

## MCP 설정 상태

Atlassian MCP 서버가 설치됨 (`mcp.atlassian.com/v1/sse`, SSE 방식).
OAuth 인증 완료 후 `mcp__atlassian__*` 도구가 활성화된다.

## 검색 방법 (우선순위순)

### 방법 1: Atlassian MCP를 통한 직접 검색 (권장)

`mcp__atlassian__` 접두사의 도구가 사용 가능하면 MCP를 통해 직접 검색한다.

**Confluence 관련 주요 도구**:
- `mcp__atlassian__searchConfluenceUsingCql` — CQL로 문서 검색
- `mcp__atlassian__getConfluenceSpaces` — 스페이스 목록 조회
- `mcp__atlassian__getConfluencePage` — 페이지 내용 조회
- `mcp__atlassian__getPagesInConfluenceSpace` — 스페이스 내 페이지 목록
- `mcp__atlassian__getConfluencePageDescendants` — 하위 페이지 조회
- `mcp__atlassian__getConfluencePageFooterComments` — 페이지 댓글 조회
- `mcp__atlassian__getConfluencePageInlineComments` — 인라인 댓글 조회
- `mcp__atlassian__getConfluencePageAncestors` — 상위 페이지 조회

**검색 절차**:
1. CQL 검색으로 관련 문서 탐색: `searchConfluenceUsingCql`
   - 예: `text ~ "키워드" AND space = "SPACE_KEY"`
   - 예: `title ~ "키워드" AND type = "page"`
2. 검색된 페이지의 상세 내용 조회: `getConfluencePage`
3. 필요시 하위 페이지나 댓글도 확인
4. 결과 정리: 문서 제목, 스페이스, 핵심 내용, 최종 수정일

**CQL 검색 팁**:
- 텍스트 검색: `text ~ "검색어"` 또는 `title ~ "검색어"`
- 스페이스 필터: `space = "KEY"`
- 라벨 필터: `label = "라벨명"`
- 날짜 필터: `lastModified >= "2025-01-01"`
- 결합: `text ~ "API" AND space = "DEV" AND lastModified >= "2025-01-01"`

### 방법 2: URL 기반 WebFetch (MCP 미사용 시 대안)

사용자가 Confluence URL을 제공하면 `WebFetch`로 내용을 조회한다.

```
WebFetch(url: "https://wiki.example.com/pages/...", prompt: "이 문서에서 [키워드] 관련 내용을 추출해 주세요")
```

**주의**: 인증이 필요한 Confluence는 WebFetch가 실패할 수 있다. 실패 시 방법 3으로 전환.

### 방법 3: 사용자에게 직접 검색 요청

MCP가 비활성이고 URL도 없는 경우.

**인증 안내** (MCP 서버는 설치되었으나 인증이 안 된 경우):
```
Atlassian MCP가 설치되어 있지만 인증이 필요합니다.
Claude Code를 재시작하면 OAuth 인증 플로우가 시작됩니다.
```

**검색 요청 템플릿** (MCP 사용 불가 시):
```
Confluence에서 관련 문서 확인이 필요합니다:

1. Confluence 검색창에서 다음을 검색해 주세요:
   - 검색어: [키워드1], [키워드2]
   - 추천 스페이스: [관련 스페이스명]

2. 다음 유형의 문서를 찾아 주세요:
   - [스펙 문서 / ADR / API 문서 / 회의록] 등

3. 관련 문서를 찾으시면 URL 또는 내용을 공유해 주세요.
```

## 문서 유형별 검색 키워드

| 문서 유형 | 검색 키워드 예시 |
|-----------|-----------------|
| 기능 스펙 | "PRD", "스펙", "요구사항", 기능명 |
| ADR (Architecture Decision Record) | "ADR", "의사결정", "설계" |
| API 문서 | "API", 엔드포인트명, "스웨거" |
| 회의록 | "회의록", "미팅노트", 날짜 |
| 온보딩 | "온보딩", "가이드", "시작하기" |

## 결과 정리 형식
- 문서: 제목 + URL (있으면)
- 내용: 관련 섹션 발췌 또는 요약
- 최종 수정일 명시 (문서 최신성 판단용)
