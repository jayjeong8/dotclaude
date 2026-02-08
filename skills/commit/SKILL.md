---
name: commit
description: git diff를 분석하여 설명적인 커밋 메시지 생성. 사용자가 커밋 메시지 작성 또는 스테이징된 변경 사항 검토에 대한 도움을 요청할 때 사용합니다.
---

# 커밋 메시지 생성

## 커밋 메시지 형식
```
prefix: 한국어 설명
```

## Prefix 규칙
- `feat:` - 새로운 기능 추가
- `fix:` - 버그 수정
- `design:` - UI/UX 디자인 변경 (스타일, 레이아웃 등)
- `refactor:` - 기능 변경 없이 코드 개선
- `rename:` - 파일 또는 변수명 변경
- `docs:` - 문서 수정
- `test:` - 테스트 코드 추가/수정
- `chore:` - 빌드, 설정 파일 등 기타 변경

## 작성 가이드라인
1. 메시지는 한국어로 작성
2. 간결하고 명확하게 변경 내용을 설명
3. 무엇을 했는지(what) 중심으로 작성
4. 마침표 생략

## 예시
- `feat: RecentRewardBanner 동물 아이콘 및 asterisk 이미지 적용`
- `fix: buzzad tsconfig에 buzzbenefit-kit 타입 선언 경로 추가`
- `design: 중간재화 UI 단순화`
- `refactor: tsconfig include에서 불필요한 globals.d.ts 제거`
- `rename: RecentRewardBanner => RecentWinnersTicker`

## 실행 절차
1. `git status`로 변경 파일 확인
2. `git diff --staged`로 스테이징된 변경 사항 분석
3. 변경 사항의 성격에 맞는 prefix 선택
4. 변경 내용을 간결하게 요약하여 메시지 작성
5. 커밋

## 주의사항
- `git add -A` 대신 변경 파일을 개별적으로 스테이징
- .env, credentials 등 민감 파일 커밋 금지
- 변경사항이 없으면 빈 커밋 생성하지 않음
