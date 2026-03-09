---
name: slack-to-linear
description: 슬랙 논의를 요약하여 리니어 이슈를 자동 생성합니다. "/slack-to-linear #channel keyword", "/slack-to-linear <slack-url>" 등의 요청 시 사용합니다.
---

# Slack 논의 → Linear 이슈 생성

슬랙 채널/스레드의 논의를 분석하여 구조화된 Linear 이슈를 생성합니다.

## 입력 형식

`$ARGUMENTS`는 다음 형태 중 하나:
- `<slack-url>` — 특정 메시지/스레드 URL
- `<channel> <keyword>` — 채널명 + 검색 키워드
- `<keyword>` — 키워드만 (전체 검색)

## 실행 절차

### 1단계: Slack 검색 및 수집

`domain-knowledge/search-slack.md`의 검색 패턴을 따릅니다.

**URL이 주어진 경우:**
1. URL에서 채널 ID와 메시지 timestamp 추출
2. `mcp__claude_ai_Slack__slack_read_thread`로 스레드 전체 읽기
3. 스레드가 없으면 `mcp__claude_ai_Slack__slack_read_channel`로 주변 컨텍스트 읽기

**채널 + 키워드가 주어진 경우:**
1. `mcp__claude_ai_Slack__slack_search_public_and_private`로 메시지 검색
2. 관련 스레드의 답글까지 확인
3. 가장 관련성 높은 논의 선택

**키워드만 주어진 경우:**
1. `mcp__claude_ai_Slack__slack_search_public_and_private`로 전체 검색
2. 결과에서 가장 활발한 논의 스레드 선택

### 2단계: 논의 분석 및 요약

수집된 메시지를 다음 구조로 정리:

```
## 배경
[논의가 시작된 맥락]

## 핵심 논의
- @참여자1: [주요 발언 요약]
- @참여자2: [주요 발언 요약]

## 결정사항
- [합의된 내용 1]
- [합의된 내용 2]

## 액션아이템
- [ ] [구체적 작업 1] (담당: @참여자)
- [ ] [구체적 작업 2] (담당: @참여자)
```

### 3단계: 사용자 확인

`AskUserQuestion`으로 이슈 생성 전 확인:

```
## Linear 이슈 생성 계획

**제목**: [제안 제목]
**프로젝트**: [프로젝트명 - 선택]
**라벨**: [라벨 - 선택]
**우선순위**: [긴급/높음/보통/낮음]

**설명 미리보기**:
[요약 내용]

이대로 생성할까요? 수정할 부분이 있으면 알려주세요.
```

### 4단계: Linear 이슈 생성

1. `mcp__claude_ai_Linear__list_teams`로 팀 확인 (캐시 활용)
2. 필요시 `mcp__claude_ai_Linear__list_projects`로 프로젝트 확인
3. `mcp__claude_ai_Linear__save_issue`로 이슈 생성
   - title: 확인된 제목
   - description: 요약 + Slack 출처 링크 포함
   - teamId, projectId, labelIds, priority 설정

### 5단계: 결과 보고

```
✅ Linear 이슈가 생성되었습니다.

**이슈**: [TEAM-123] 이슈 제목
**URL**: https://linear.app/team/issue/TEAM-123

**출처**: Slack #channel-name (날짜)
```

## 주의사항

- Slack에서 읽은 내용 중 민감 정보(토큰, 비밀번호 등)는 이슈에 포함하지 않음
- 논의가 결론 없이 진행 중인 경우, 현재까지의 상태를 명시하고 사용자에게 알림
- 여러 액션아이템이 있으면 하나의 이슈 vs 여러 이슈 생성 여부를 사용자에게 확인
- 출처 Slack 링크를 이슈 설명 하단에 반드시 포함
