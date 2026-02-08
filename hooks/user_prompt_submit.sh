#!/usr/bin/env bash
set -euo pipefail

# 1) Claude Code가 훅으로 넘겨주는 payload(JSON)를 stdin에서 읽음
payload="$(cat)"

# 2) prompt 텍스트 추출 (jq 필요)
prompt="$(echo "$payload" | jq -r '.prompt // empty')"

# 3) prompt가 비어있으면 아무 것도 하지 않음
[[ -z "$prompt" ]] && exit 0

# task-notification은 로깅하지 않음
if echo "$prompt" | grep -q '<task-notification>'; then
  exit 0
fi

# 4) 로그 파일 경로 (글로벌 한곳에서 관리)
LOG_DIR="$HOME/.claude/prompt-log"
LOG_FILE="$LOG_DIR/prompts.md"

mkdir -p "$LOG_DIR"

# 5) Markdown으로 append
{
  echo ""
  echo "## $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  echo '```'
  echo "$prompt"
  echo '```'
} >> "$LOG_FILE"

# 6) 코드 변경 작업 시 워크플로우 리마인더
# 슬래시 명령어로 시작하거나 .claude 관련 작업은 제외
if [[ ! "$prompt" =~ ^/ ]] && [[ ! "$prompt" =~ \.claude ]]; then
  cat << 'EOF'
<user-prompt-submit-hook>
[리마인더] 코드 변경 시: 한 단계 구현 → 린트 → /commit → 다음 단계. 여러 단계를 한꺼번에 구현하지 마세요.
</user-prompt-submit-hook>
EOF
fi
