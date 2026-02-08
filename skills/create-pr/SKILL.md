---
name: create-pr
description: 현재 브랜치의 변경사항을 분석하여 PR 설명을 자동 생성합니다. "PR 작성", "PR 생성" "PR 만들어줘" 등의 요청 시 사용합니다.
---

# Pull Request 생성

현재 브랜치와 base 브랜치 간의 커밋 변경사항을 분석하고, `.github/pull_request_template.md` 템플릿을 참고하여 Pull Request를 작성합니다.

## Base 브랜치 확인 방법 (중요!)

다음 순서대로 base 브랜치를 확인하세요:

### 1단계: first-parent merge 커밋에서 대상 브랜치 추출
```bash
git --no-pager log --first-parent --oneline -10 HEAD | grep -m1 "Merge branch" | sed -n "s/.*into \([^']*\)$/origin\/\1/p"
```
- 이 명령은 merge 커밋 메시지의 `into <branch>` 부분에서 현재 브랜치가 분기된 부모 브랜치를 찾습니다
- 예: `Merge branch 'feat/daou-integration-4' into feat/daou-integration-5` → `origin/feat/daou-integration-5`가 base
- 결과가 있으면 해당 브랜치를 base로 사용하세요

### 2단계: merge 커밋이 없는 경우 - reflog에서 브랜치 생성 시점 찾기
1단계에서 결과가 없으면, reflog에서 브랜치가 생성된 커밋을 찾고 해당 커밋이 속한 브랜치를 확인하세요:
```bash
# 현재 브랜치 이름
CURRENT_BRANCH=$(git --no-pager rev-parse --abbrev-ref HEAD)

# 브랜치 생성 시점의 커밋 해시
CREATION_COMMIT=$(git reflog show $CURRENT_BRANCH | tail -1 | awk '{print $1}')

# 해당 커밋이 속한 remote 브랜치 중 현재 브랜치가 아닌 것
git --no-pager branch -r --contains $CREATION_COMMIT | grep -v $CURRENT_BRANCH | head -1
```
- 결과가 있으면 해당 브랜치를 base로 사용하세요

### 3단계: 위 방법들로 찾을 수 없는 경우
2단계에서도 결과가 없으면 `origin/master` (또는 `origin/main`)를 기본값으로 사용하세요.

**주의: master를 무조건 기본값으로 가정하지 마세요. 반드시 위 명령어들로 먼저 확인하세요.**

## 변경사항 확인
- git diff를 수행할 때는 `git --no-pager` 옵션을 꼭 사용해주세요.
- 변경사항 확인 시 위에서 확인한 base 브랜치를 사용하세요. 예: `git --no-pager diff <base-branch>...HEAD`
- 커맨드 실행하고 3초 이상 결과를 기다리면 커맨드를 다시 실행해주세요.

## 작성 가이드라인

1. 현재 브랜치의 모든 변경사항을 분석하여 PR 내용을 작성
2. `.github/pull_request_template.md` 파일의 구조와 형식을 반드시 따라야 함
3. 배경 섹션은 간결하게 작성하되, 코드 변경사항이 아닌 비즈니스 맥락을 포함해야 함
4. 비즈니스 맥락에 대한 정보가 필요한 경우 사용자에게 질문하여 확인
5. 변경된 파일들과 주요 변경 내용을 명확히 설명
6. 테스트 방법이나 체크리스트가 템플릿에 있다면 해당 항목도 작성

## 실행 절차

1. PR 템플릿(`.github/pull_request_template.md`)을 먼저 확인
2. Base 브랜치를 위의 방법으로 확인
3. `git --no-pager diff <base-branch>...HEAD`로 변경사항 분석
4. 필요한 비즈니스 맥락이 있다면 사용자에게 질문
5. 완성도 높은 PR 설명 작성
6. `gh pr create --title "<제목>" --base <base-branch> --body "<본문>"`으로 PR 생성

## 예시

```markdown
## 배경
> Linear: [TICKET-123](https://linear.app/team/issue/TICKET-123)

<비즈니스 맥락: 왜 이 변경이 필요한지 1-2문장>

## 작업 내용
- <주요 변경사항 1>
- <주요 변경사항 2>

## 참고사항
- <관련 문서, 주의사항 등>
```
