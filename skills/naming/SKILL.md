---
name: naming
description: 변수명, 함수명, 컴포넌트명 개선 제안. 네이밍이 적합하지 않거나 더 나은 이름이 필요할 때 사용합니다.
---

# 네이밍 가이드

## 네이밍 원칙
1. **명확성**: 이름만 보고 목적을 이해할 수 있어야 함
2. **일관성**: 프로젝트 내 기존 네이밍 컨벤션 따르기
3. **간결성**: 불필요하게 길지 않으면서 의미 전달

## 네이밍 컨벤션

### 변수/함수
- camelCase 사용
- 동사로 시작 (함수): `getUserData`, `handleClick`, `isValid`
- 명사/형용사 (변수): `userName`, `isLoading`, `hasError`
- Boolean: `is`, `has`, `can`, `should` 접두사

### 컴포넌트
- PascalCase 사용
- 명사 또는 명사구: `UserProfile`, `RecentWinnersTicker`
- 역할을 명확히: `Button`, `Modal`, `List`

### 상수
- UPPER_SNAKE_CASE: `MAX_RETRY_COUNT`, `API_BASE_URL`

## 실행 절차
1. 현재 이름과 사용 맥락 파악
2. 코드에서 해당 변수/함수의 실제 역할 분석
3. 프로젝트 내 유사한 네이밍 패턴 참고
4. 3-5개의 대안 이름 제안 (장단점 포함)
5. 사용자 선택 후 모든 관련 위치 일괄 변경

## 제안 형식
```
현재: oldName
제안:
1. newName1 - [설명: 왜 이 이름이 적합한지]
2. newName2 - [설명]
3. newName3 - [설명]

추천: newName1 (이유)
```

## 피해야 할 패턴
- 약어 남용: `usr`, `btn`, `msg` (맥락이 명확하지 않으면)
- 숫자 접미사: `data1`, `temp2`
- 모호한 이름: `data`, `info`, `temp`, `result`
- 너무 긴 이름: 3-4단어 이상이면 재고려
