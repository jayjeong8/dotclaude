---
name: init
description: Next.js + TypeScript + Tailwind CSS + Biome + pnpm + shadcn/ui 기반 프로젝트 초기화. "/init", "/init my-app" 등의 요청 시 사용합니다.
---

# 프로젝트 초기화

인터랙티브하게 옵션을 선택하며 Next.js 프로젝트를 생성합니다.

## 실행 절차

### 1단계: 인터뷰

`AskUserQuestion`으로 다음을 질문합니다. `$ARGUMENTS`가 있으면 프로젝트 이름 질문은 스킵합니다.

**질문 1** (프로젝트 이름, `$ARGUMENTS` 없을 때만):
- header: "프로젝트명"
- question: "프로젝트 이름을 입력해주세요."
- options: ["my-app", "my-project"]

**질문 2** (추가 옵션, multiSelect: true):
- header: "추가 옵션"
- question: "추가로 설치할 옵션을 선택해주세요."
- options:
  - shadcn/ui: UI 컴포넌트 라이브러리
  - lefthook: Git hooks 관리 도구
  - @t3-oss/env-nextjs: 타입 안전한 환경변수 관리
  - next-themes: 다크모드/테마 전환

**질문 3** (src 디렉토리):
- header: "src 디렉토리"
- question: "src 디렉토리를 사용할까요?"
- options: ["Yes (Recommended)", "No"]

### 2단계: Next.js 프로젝트 생성

```bash
pnpm create next-app@latest <project-name> \
  --typescript --tailwind --eslint=false \
  --app --import-alias="@/*" \
  --use-pnpm --turbopack \
  [--src-dir | --no-src-dir]
```

- `--src-dir` 또는 `--no-src-dir`는 인터뷰 응답에 따라 결정
- 생성 후 해당 디렉토리로 이동하여 이후 작업 수행

### 3단계: ESLint 제거 + Biome 설치

```bash
# ESLint 관련 패키지 제거 (존재하는 것만)
pnpm remove eslint eslint-config-next @eslint/eslintrc 2>/dev/null || true

# .eslintrc* 파일 제거
rm -f .eslintrc* eslint.config.*

# Biome 설치
pnpm add -D @biomejs/biome

# biome.json 생성
pnpm biome init
```

biome.json을 다음과 같이 커스터마이즈:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "organizeImports": {
    "enabled": true
  },
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true
    }
  }
}
```

> biome.json의 `$schema` 버전은 `pnpm biome init`이 생성한 값을 유지합니다.

package.json scripts에 추가:

```json
{
  "lint": "biome check .",
  "lint:fix": "biome check --write .",
  "format": "biome format --write ."
}
```

### 4단계: shadcn/ui 설치 (선택 시)

```bash
pnpm dlx shadcn@latest init -d
```

### 5단계: 추가 옵션 설치 (선택 시)

#### lefthook

```bash
pnpm add -D lefthook
pnpm lefthook install
```

`lefthook.yml` 생성:

```yaml
pre-commit:
  commands:
    check:
      glob: "*.{js,ts,jsx,tsx,json,css}"
      run: pnpm biome check --no-errors-on-unmatched --files-ignore-unknown=true {staged_files}
      stage_fixed: true
```

#### @t3-oss/env-nextjs

```bash
pnpm add @t3-oss/env-nextjs zod
```

`src/env.ts` (또는 `env.ts`) 생성:

```typescript
import { createEnv } from "@t3-oss/env-nextjs";
import { z } from "zod";

export const env = createEnv({
  server: {},
  client: {},
  runtimeEnv: {},
});
```

#### next-themes

```bash
pnpm add next-themes
```

`src/components/theme-provider.tsx` (또는 `components/theme-provider.tsx`) 생성:

```tsx
"use client";

import { ThemeProvider as NextThemesProvider } from "next-themes";
import type { ComponentProps } from "react";

export function ThemeProvider({
  children,
  ...props
}: ComponentProps<typeof NextThemesProvider>) {
  return <NextThemesProvider {...props}>{children}</NextThemesProvider>;
}
```

`layout.tsx`에 ThemeProvider 적용:

```tsx
import { ThemeProvider } from "@/components/theme-provider";

// body 내부를 ThemeProvider로 감싸기
<ThemeProvider attribute="class" defaultTheme="system" enableSystem disableTransitionOnChange>
  {children}
</ThemeProvider>
```

### 6단계: 프로젝트 정리

- `globals.css`: Tailwind 지시어만 남기고 나머지 삭제
  ```css
  @import "tailwindcss";
  ```
- `page.tsx`: 기본 보일러플레이트를 심플한 내용으로 교체
  ```tsx
  export default function Home() {
    return (
      <div className="flex min-h-svh items-center justify-center">
        <h1 className="text-4xl font-bold">Hello, World!</h1>
      </div>
    );
  }
  ```
- `layout.tsx`: 불필요한 font import나 metadata 외 보일러플레이트 정리
- `README.md`: 프로젝트명으로 업데이트
- `.gitignore` 확인하여 누락된 항목 추가 (`.env*.local` 등)
- `public/` 내 기본 SVG 파일 삭제

### 7단계: Biome 포맷 적용 + 초기 커밋

```bash
pnpm biome check --write .
git add -A && git commit -m "chore: 프로젝트 초기화"
```

## 주의사항

- 각 단계 실행 후 에러가 발생하면 즉시 수정 후 다음 단계 진행
- src 디렉토리 사용 여부에 따라 파일 경로 조정 (예: `src/env.ts` vs `env.ts`)
- `pnpm create next-app`이 실패하면 사용자에게 Node.js/pnpm 설치 확인 요청
- 이미 같은 이름의 디렉토리가 존재하면 사용자에게 확인 후 진행
