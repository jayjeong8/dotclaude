# Linear 검색 가이드

## 사용 가능한 MCP 도구

Linear MCP가 활성화되어 있으므로 아래 도구를 직접 사용한다.

### 이슈 검색
- `mcp__claude_ai_Linear__list_issues` — 키워드, 상태, 담당자, 라벨 등으로 이슈 목록 조회
  - `query`: 제목/설명 검색어
  - `state`: 상태 필터 (예: "Done", "In Progress")
  - `assignee`: 담당자 필터 ("me" 또는 이름)
  - `label`: 라벨 필터
  - `project`: 프로젝트 필터
  - `team`: 팀 필터
- `mcp__claude_ai_Linear__get_issue` — 특정 이슈의 상세 정보 조회
  - `includeRelations: true`로 관련 이슈도 확인

### 코멘트 확인
- `mcp__claude_ai_Linear__list_comments` — 이슈의 코멘트 목록 조회
  - 논의 히스토리, 의사결정 배경 확인에 유용

### 프로젝트/문서 검색
- `mcp__claude_ai_Linear__list_projects` — 프로젝트 목록 조회
- `mcp__claude_ai_Linear__get_project` — 프로젝트 상세 정보
- `mcp__claude_ai_Linear__list_documents` — Linear 문서 검색
  - `query`: 검색어로 문서 제목/내용 검색
- `mcp__claude_ai_Linear__get_document` — 특정 문서 내용 조회

### 팀/사용자 정보
- `mcp__claude_ai_Linear__list_teams` — 팀 목록
- `mcp__claude_ai_Linear__list_users` — 사용자 목록

## 검색 전략

### 키워드 기반 검색
1. 추출된 키워드로 `list_issues(query: "키워드")` 실행
2. 결과가 너무 많으면 `state`, `label`, `team` 등으로 필터링
3. 결과가 없으면 키워드를 영어/한국어로 바꿔서 재검색

### 이슈 번호가 있는 경우
1. `get_issue(id: "TEAM-123")`으로 바로 조회
2. `includeRelations: true`로 관련 이슈 파악
3. `list_comments`로 논의 내용 확인

### 프로젝트/기능 단위 검색
1. `list_projects(query: "키워드")`로 관련 프로젝트 찾기
2. `list_issues(project: "프로젝트명")`으로 해당 프로젝트 이슈 조회
3. `list_documents(query: "키워드")`로 문서 검색

## 결과 정리 형식
- 이슈: `TEAM-123: 이슈 제목` (상태, 담당자, 날짜)
- 코멘트: 핵심 내용 요약 + 작성자
- 문서: 문서 제목 + 관련 내용 발췌
