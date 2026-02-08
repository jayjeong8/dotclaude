---
name: pr-review
description: 현재 브랜치의 PR에 달린 리뷰 코멘트를 분석하여 유효한 리뷰를 정리합니다. "리뷰 확인", "PR 리뷰", "코멘트 확인" 등의 요청 시 사용합니다.
---

# PR 리뷰 코멘트 분석

현재 브랜치의 PR에 달린 리뷰 코멘트를 분석하여 정리합니다.

## 실행 절차

1. **현재 브랜치의 PR 찾기**
   ```bash
   gh pr list --head $(git branch --show-current) --json number,url --jq '.[0]'
   ```

2. **PR 리뷰 코멘트 가져오기**
   ```bash
   gh pr view <PR_NUMBER> --json reviews,comments
   gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments
   ```

3. **코멘트 분류**
   - **필수 수정**: 버그, 보안 이슈, 로직 오류
   - **권장 수정**: 코드 품질, 가독성 개선
   - **질문/논의**: 설계 관련 논의, 확인 필요 사항
   - **완료됨**: 이미 반영된 코멘트

4. **정리된 리뷰 출력**

## 출력 형식

```markdown
## PR 리뷰 요약

### 필수 수정 (Critical)
1. **[파일명:라인]** 코멘트 내용
   - 리뷰어: @username
   - 상태: 미해결/해결됨

### 권장 수정 (Suggested)
1. ...

### 질문/논의 (Discussion)
1. ...

### 완료된 항목
1. ...
```

## 유용한 gh 명령어

```bash
# PR 상세 정보
gh pr view <PR_NUMBER>

# PR 코멘트 목록
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/comments

# PR 리뷰 목록
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews

# 특정 리뷰의 코멘트
gh api repos/{owner}/{repo}/pulls/<PR_NUMBER>/reviews/<REVIEW_ID>/comments
```

## 코멘트 우선순위 판단 기준

### 필수 수정 키워드
- bug, error, fix, critical, security
- 반드시, 필수, 수정 필요

### 권장 수정 키워드
- suggest, consider, could, might
- 제안, 고려, 개선

### 질문 키워드
- ?, why, how, what
- 왜, 어떻게, 확인
