#!/usr/bin/env bash
set -euo pipefail

# completion-notify Hook (Stop event)
# Claude 응답 완료 시 macOS 알림 + 터미널 벨 발송

# macOS 알림
osascript -e 'display notification "작업 완료" with title "Claude Code"' 2>/dev/null || true

# 터미널 벨
printf '\a'

exit 0
