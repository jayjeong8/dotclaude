#!/usr/bin/env bash
set -euo pipefail

# PostToolUse 컨텍스트화 Hook
# Edit/Write 후 상황에 맞는 제안을 표시합니다.
# - .claude/ 하위 수정 시: 제안 생략
# - 테스트 파일 수정 시: /testcase 제안
# - 3회 이상 연속 수정 (커밋 없이): /commit 제안
# - 그 외에는 출력 없음 (잡음 방지)

payload="$(cat)"

# tool_input에서 파일 경로 추출
file_path="$(echo "$payload" | jq -r '.tool_input.file_path // empty')"

# 파일 경로가 없으면 통과
[[ -z "$file_path" ]] && exit 0

# .claude/ 하위 수정 시 제안 생략
if [[ "$file_path" == *"/.claude/"* ]] || [[ "$file_path" == *".claude/"* ]]; then
  exit 0
fi

# 수정 카운터 파일 (세션별)
COUNTER_FILE="/tmp/claude_edit_counter_$$"

# 카운터가 없으면 상위 프로세스의 카운터 찾기
if [[ ! -f "$COUNTER_FILE" ]]; then
  # PPID 기반으로도 찾기 시도
  COUNTER_FILE="/tmp/claude_edit_counter"
fi

# 카운터 읽기/증가
count=0
if [[ -f "$COUNTER_FILE" ]]; then
  count=$(cat "$COUNTER_FILE" 2>/dev/null || echo "0")
fi
count=$((count + 1))
echo "$count" > "$COUNTER_FILE"

# 테스트 파일 수정 시
if [[ "$file_path" =~ (test|spec|__tests__) ]]; then
  echo "💡 테스트 파일 수정됨. /testcase로 테스트 케이스를 검토할 수 있습니다."
  exit 0
fi

# 3회 이상 연속 수정 (커밋 없이)
if [[ $count -ge 3 ]]; then
  echo "💡 ${count}회 수정됨. /commit으로 변경사항을 커밋할 수 있습니다."
  exit 0
fi

# 첫 1~2회 수정: 잡음 방지를 위해 아무 메시지도 출력하지 않음
exit 0
