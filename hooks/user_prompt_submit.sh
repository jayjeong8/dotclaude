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
# 추가: 코드 작업을 시사하는 키워드가 포함된 경우에만 출력 (질문/탐색 프롬프트 잡음 제거)
CODE_WORK_PATTERN='구현|만들|작성|추가|수정|고쳐|리팩토|refactor|implement|add |fix |write |feature|build |create '
if [[ ! "$prompt" =~ ^/ ]] && [[ ! "$prompt" =~ \.claude ]] && echo "$prompt" | grep -qiE "$CODE_WORK_PATTERN"; then
  cat << 'EOF'
<user-prompt-submit-hook>
⚠️ [원자적 커밋 - 최우선 규칙]
멀티 스텝 작업 시 반드시 아래 루프를 지켜야 합니다:
  한 단계 구현 → 린트 → /commit → 다음 단계
위반 금지사항:
  - 여러 단계를 연속 구현한 뒤 마지막에 한 번 커밋하는 것
  - TaskUpdate completed 처리 전에 커밋이 없는 것
  - --amend로 이전 커밋에 합치는 것 (사용자 명시 요청 시에만 허용)
</user-prompt-submit-hook>
EOF
fi

# 7) "반영" / "적용" / "피드백 반영" 축약 명령은 PR 리뷰 피드백 반영 의도로 해석
#    사용자가 /pr-review 직후 흔히 입력하므로 pr-fixup 에이전트 사용을 제안
trimmed_prompt="$(echo "$prompt" | tr -d '[:space:]')"
if [[ "$trimmed_prompt" == "반영" ]] || [[ "$trimmed_prompt" == "적용" ]] || [[ "$trimmed_prompt" == "피드백반영" ]] || [[ "$trimmed_prompt" == "리뷰반영" ]]; then
  cat << 'EOF'
<user-prompt-submit-hook>
💡 [축약 명령 감지] "반영"/"적용"은 PR 리뷰 피드백 반영 의도로 해석됩니다.
직전에 /pr-review를 실행했다면 `pr-fixup` 에이전트를 사용해 자동으로 피드백을 반영하세요.
</user-prompt-submit-hook>
EOF
fi
