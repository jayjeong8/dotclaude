---
name: fix-types
description: TypeScript 타입 에러 분석 및 자동 수정. TS 에러 발생 시 사용합니다.
---

# TypeScript 에러 수정 가이드

## 일반적인 TS 에러 유형

### TS2307: Cannot find module
**원인**: 모듈을 찾을 수 없음
**해결 방법**:
1. 파일 경로 확인 (대소문자 포함)
2. 파일 확장자 확인 (.ts, .tsx, .d.ts)
3. tsconfig.json의 `paths`, `baseUrl` 설정 확인
4. 타입 선언 파일 존재 여부 확인 (*.d.ts)
5. node_modules/@types 패키지 설치 확인

### TS2339: Property does not exist
**원인**: 타입에 속성이 정의되지 않음
**해결 방법**:
1. 인터페이스/타입에 속성 추가
2. 타입 단언 사용 (as Type)
3. 옵셔널 체이닝 (?.) 사용
4. 타입 가드 추가

### TS2345: Argument type mismatch
**원인**: 함수 인자 타입 불일치
**해결 방법**:
1. 올바른 타입으로 변환
2. 함수 시그니처 수정
3. 제네릭 타입 파라미터 조정

### TS2322: Type is not assignable
**원인**: 할당 타입 불일치
**해결 방법**:
1. 타입 정의 확장
2. 유니온 타입 사용
3. 타입 가드로 범위 좁히기

## 실행 절차
1. 에러 메시지와 에러 코드 확인
2. 해당 파일 및 라인 읽기
3. 관련 타입 정의 파일 확인
4. tsconfig.json 설정 확인 (필요시)
5. 근본 원인 파악 후 최소한의 수정 적용
6. `npx tsc --noEmit`으로 검증 (pnpm 모노레포: `pnpm --filter <package-name> exec tsc --noEmit`)

## 자주 사용하는 명령어
```bash
# 타입 체크 실행 (프로젝트 설정에 따라)
npx tsc --noEmit
# 또는 pnpm 모노레포의 경우
pnpm --filter <package-name> exec tsc --noEmit

# 특정 파일만 체크
npx tsc --noEmit path/to/file.ts

# 타입 선언 파일 찾기
find . -name "*.d.ts" | grep [keyword]
```

## 주의사항
- `any` 타입 사용 최소화
- `@ts-ignore` 사용 지양 (임시 해결책으로만)
- 타입 단언(as)보다 타입 가드 선호
- 수정 후 반드시 타입 체크 실행
