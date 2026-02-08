---
name: update-pr
description: 현재 브랜치의 PR 내용을 최신 변경사항으로 업데이트합니다. "PR 업데이트", "PR 내용 업데이트" 등의 요청 시 사용합니다.
---

# PR 내용 업데이트

## 실행 절차

1. 현재 PR 정보 확인
   `gh pr view --json number,title,body,url,baseRefName`

2. 최신 변경사항 분석
   `git --no-pager diff origin/<base>...HEAD --stat`
   `git --no-pager log origin/<base>...HEAD --oneline`

3. PR 본문 업데이트
   - `.github/pull_request_template.md` 형식 유지
   - 기존 배경/맥락 정보 보존
   - 작업 내용 및 참고사항만 갱신
   - 새 커밋 내용 반영

4. `gh pr edit <PR_NUMBER> --body "<updated_body>"`
