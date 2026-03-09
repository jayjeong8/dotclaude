---
name: branch-workflow
description: Linear 이슈에서 브랜치 생성 및 상태 업데이트를 자동화합니다. "/branch-workflow SUP-907", "이 이슈 작업 시작해줘" 등의 요청 시 사용합니다.
---

# Branch Workflow

Linear 이슈 → 브랜치 생성 → 상태 업데이트를 자동화합니다.

## 입력 형식

`$ARGUMENTS`는 다음 형태 중 하나:
- Linear 이슈 ID (e.g., `SUP-907`, `ENG-123`)
- Linear 이슈 URL
- 없음 → 현재 브랜치에서 이슈 ID 추출 시도

## 실행 절차

### 1단계: Linear 이슈 확인

1. `$ARGUMENTS`에서 이슈 ID 추출
   - 없으면 `git branch --show-current`에서 이슈 번호 패턴 추출
   - 그래도 없으면 `AskUserQuestion`으로 이슈 ID 요청
2. `mcp__claude_ai_Linear__get_issue`로 이슈 조회
3. 이슈 상태 확인 (이미 In Progress이면 브랜치만 생성)

### 2단계: 브랜치명 생성

이슈 ID + 제목을 기반으로 브랜치명 생성:

**규칙:**
- prefix: 이슈 ID를 소문자로 (e.g., `sup-907`)
- suffix: 제목에서 핵심 키워드 2-3개를 kebab-case로
- 총 길이 50자 이내

**예시:**
- `SUP-907 중개 필드 매핑 개선` → `sup-907/mediation-field-mapping`
- `ENG-123 로그인 페이지 리디자인` → `eng-123/login-redesign`

### 3단계: 브랜치 생성

```bash
# main (또는 master)에서 최신 코드 가져오기
git fetch origin

# base 브랜치 결정 (create-pr 스킬의 base branch 감지 로직 재사용)
# 기본: origin/main 또는 origin/master
BASE=$(git rev-parse --verify origin/main 2>/dev/null && echo "origin/main" || echo "origin/master")

# 브랜치 생성 및 체크아웃
git checkout -b <branch-name> $BASE
```

### 4단계: Linear 이슈 상태 업데이트

1. `mcp__claude_ai_Linear__list_issue_statuses`로 팀의 상태 목록 조회
2. "In Progress" (또는 "진행 중") 상태 ID 찾기
3. `mcp__claude_ai_Linear__save_issue`로 상태 업데이트

### 5단계: 결과 보고

```
✅ 작업 환경이 준비되었습니다.

**이슈**: [SUP-907] 중개 필드 매핑 개선
**브랜치**: sup-907/mediation-field-mapping
**상태**: In Progress

## 이슈 요약
[이슈 설명 요약]

## 인수 기준
[Acceptance criteria가 있으면 표시]
```

### 6단계: 추가 제안

- 이슈 설명이 부족하면: "`/spec-interview`로 상세 스펙을 작성할 수 있습니다." 제안
- 서브태스크가 있으면: 서브태스크 목록과 상태를 함께 표시

## 주의사항

- 이미 해당 이슈의 브랜치가 존재하면 기존 브랜치 checkout 제안
- `git stash`가 필요한 경우 (uncommitted changes) 사용자에게 알림
- Linear 이슈가 존재하지 않으면 에러 메시지와 함께 종료
