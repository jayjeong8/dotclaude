---
name: update-spec
description: 브랜치 변경사항을 분석하여 .claude/specs/ 문서를 자동 업데이트합니다. "스펙 업데이트", "문서 업데이트" 등의 요청 시 사용합니다.
---

# 스펙 문서 업데이트

브랜치의 변경사항을 분석하여 `.claude/specs/` 폴더의 관련 문서를 업데이트합니다.

## Base 브랜치 확인

다음 순서로 base 브랜치를 확인하세요:

```bash
# 1단계: merge 커밋에서 대상 브랜치 추출
git --no-pager log --first-parent --oneline -10 HEAD | grep -m1 "Merge branch" | sed -n "s/.*into \([^']*\)$/origin\/\1/p"

# 2단계: 결과 없으면 reflog에서 브랜치 생성 시점 찾기
CURRENT_BRANCH=$(git --no-pager rev-parse --abbrev-ref HEAD)
CREATION_COMMIT=$(git reflog show $CURRENT_BRANCH | tail -1 | awk '{print $1}')
git --no-pager branch -r --contains $CREATION_COMMIT | grep -v $CURRENT_BRANCH | head -1

# 3단계: 위 방법들로 찾을 수 없으면 origin/main 사용
```

## 실행 절차

1. **프로젝트 루트 확인**
   ```bash
   PROJECT_ROOT=$(git rev-parse --show-toplevel)
   SPECS_DIR="$PROJECT_ROOT/.claude/specs"
   ```

2. **변경사항 분석**
   ```bash
   git --no-pager diff <base-branch>...HEAD --name-only
   git --no-pager diff <base-branch>...HEAD
   ```

3. **관련 스펙 파일 찾기**
   - 브랜치명에서 티켓 번호 추출 (예: `sup-596` → `$SPECS_DIR/sup-596.md`)
   - `$SPECS_DIR/` 폴더의 관련 파일 확인

4. **업데이트 항목 분석**
   - 구현된 기능 목록
   - 변경된 컴포넌트/훅 인터페이스
   - BI Event 정의
   - 관련 파일 경로

5. **문서 업데이트**
   - 스펙 문서 업데이트
   - 테스트케이스 문서도 함께 업데이트 (있는 경우)

## 스펙 문서 구조

```markdown
# [티켓번호] 기능명

## 개요
- 목적 및 배경

## 구현 내용
- 주요 변경사항
- 추가된 컴포넌트/훅
- 수정된 파일 목록

## BI Events
| 이벤트명 | 설명 | Attributes |
|---------|------|------------|

## 참고사항
- 관련 코드 경로
- 의존성
```

## 주의사항

- 기존 문서 구조를 유지하면서 업데이트
- 변경된 내용만 반영 (불필요한 내용 추가 금지)
- 테스트케이스 파일이 있으면 함께 업데이트
