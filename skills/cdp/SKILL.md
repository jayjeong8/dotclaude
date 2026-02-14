---
name: cdp
description: Chromium 기반 앱(Notion, Slack, Figma 등)을 CDP로 제어합니다. "노션 열어줘", "슬랙에서 메시지 보내줘" 등의 요청 시 사용합니다.
---

# CDP App Control

Chromium 기반 데스크톱 앱을 CDP(Chrome DevTools Protocol)로 제어하는 스킬.
**토큰 효율을 위해 MCP는 UI 탐색(1~2회)에만 쓰고, 실제 작업은 Bash 스크립트로 실행한다.**

## 실행 절차

### 1단계: 연결 확인

```bash
lsof -i :9222
```

- 포트 9222가 열려 있으면 → 2단계로 진행
- 열려 있지 않으면 → `cdp-open.sh`로 앱 실행:

```bash
bash ~/.claude/scripts/cdp-open.sh <앱이름>
# 예: bash ~/.claude/scripts/cdp-open.sh Notion
```

실행 후 3초 대기한 뒤 포트 확인.

### 2단계: UI 탐색 (MCP - 최소 사용)

`playwright-cdp`의 `browser_snapshot` **1회**로 현재 페이지 구조를 파악한다.

- 필요한 셀렉터, 요소 위치를 메모
- 추가 탐색이 꼭 필요한 경우에만 `browser_snapshot`을 1회 더 사용 (최대 2회)
- `browser_navigate`는 앱 내 페이지 이동이 필요할 때만 사용

### 3단계: 작업 실행 (Bash 스크립트)

2단계에서 파악한 정보로 Playwright 스크립트를 작성하여 `node -e`로 실행한다.

```javascript
const { chromium } = require('playwright');
(async () => {
  const browser = await chromium.connectOverCDP('http://localhost:9222');
  const context = browser.contexts()[0];
  const page = context.pages()[0];

  // 작업 수행 (2단계에서 파악한 셀렉터 사용)
  await page.click('...');
  await page.fill('...', 'text');

  console.log('완료');
  await browser.close();
})();
```

**주의사항:**
- `browser.close()`는 CDP 연결만 해제하며 앱을 종료하지 않음
- 여러 작업을 하나의 스크립트에 모아서 실행 (토큰 절약)
- 에러 발생 시 `browser_snapshot`으로 현재 상태 재확인 후 스크립트 수정

## 지원 앱 예시

| 앱 | 실행 명령 |
|------|-----------|
| Notion | `cdp-open.sh Notion` |
| Slack | `cdp-open.sh Slack` |
| Figma | `cdp-open.sh Figma` |
| Discord | `cdp-open.sh Discord` |
| VS Code | `cdp-open.sh "Visual Studio Code"` |

## 토큰 효율 가이드

- MCP `browser_snapshot` 1회 = 수천 토큰 (접근성 트리 전체)
- Bash 스크립트 1회 = ~1,000 토큰
- **따라서**: snapshot은 구조 파악용으로만 최소 사용하고, 실제 조작은 Bash 스크립트로 일괄 실행