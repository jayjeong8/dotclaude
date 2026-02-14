#!/bin/bash
# 사용법: cdp-open.sh <앱이름> [포트]
# 예시: cdp-open.sh Notion 9222

APP_NAME="${1:?앱 이름을 지정하세요}"
PORT="${2:-9222}"

# 이미 해당 포트로 실행 중인지 확인
if lsof -i :$PORT &>/dev/null; then
  echo "포트 $PORT 이미 사용 중"
  exit 0
fi

# 기존 앱 프로세스 종료 (디버깅 모드로 재시작 필요)
osascript -e "tell application \"$APP_NAME\" to quit" 2>/dev/null
sleep 2

# 디버깅 모드로 실행
open -a "$APP_NAME" --args --remote-debugging-port=$PORT
echo "$APP_NAME 시작됨 (CDP: ws://localhost:$PORT)"