#!/usr/bin/env bash
set -euo pipefail

# pre-push-security Hook
# git push 실행 직전, unpushed 커밋의 diff에서 시크릿/API 키 유출 패턴을 탐지합니다.
# .env 파일을 직접 읽지 않으며, git diff 출력만 분석합니다.

# stdin에서 hook payload 읽기
payload="$(cat)"

# tool_input에서 실행될 명령어 추출
command="$(echo "$payload" | jq -r '.tool_input.command // empty')"

# git push 명령이 아니면 통과
if [[ ! "$command" =~ ^git\ push ]]; then
  exit 0
fi

# upstream이 있는지 확인 (첫 push일 수 있음)
upstream=$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null || echo "")

if [[ -z "$upstream" ]]; then
  # upstream이 없으면 main/master와 비교
  base=$(git rev-parse --verify origin/main 2>/dev/null || git rev-parse --verify origin/master 2>/dev/null || echo "")
  if [[ -z "$base" ]]; then
    exit 0
  fi
  diff_text=$(git diff "$base"...HEAD 2>/dev/null || true)
else
  diff_text=$(git diff "$upstream"...HEAD 2>/dev/null || true)
fi

# diff가 비어있으면 통과
if [[ -z "$diff_text" ]]; then
  exit 0
fi

warnings=""

# 1. API 키/시크릿 할당 패턴 (diff의 추가된 라인만 검사)
added_lines=$(echo "$diff_text" | grep '^+' | grep -v '^+++' || true)

if echo "$added_lines" | grep -qiE '(api[_-]?key|secret|token|password|private[_-]?key)\s*[=:]\s*["\x27][^"\x27]{8,}'; then
  warnings="${warnings}⚠️ API 키 또는 시크릿이 할당된 패턴이 감지되었습니다.\n"
fi

# 2. 클라우드 서비스 키 패턴
if echo "$added_lines" | grep -qiE '(AWS|AZURE|GCP|SLACK|GITHUB)_[A-Z_]*(KEY|TOKEN|SECRET)\s*[=:]'; then
  warnings="${warnings}⚠️ 클라우드 서비스 키/토큰 패턴이 감지되었습니다.\n"
fi

# 3. Base64로 인코딩된 긴 문자열 (40자 이상)
if echo "$added_lines" | grep -qE '[A-Za-z0-9+/]{40,}={0,2}'; then
  # false positive 줄이기: import/require/http URL 라인 제외
  suspicious=$(echo "$added_lines" | grep -E '[A-Za-z0-9+/]{40,}={0,2}' | grep -viE '(import |require\(|https?://|sha[0-9]|integrity|hash|checksum|\.lock)' || true)
  if [[ -n "$suspicious" ]]; then
    warnings="${warnings}⚠️ Base64 인코딩된 긴 문자열이 감지되었습니다 (시크릿 가능성).\n"
  fi
fi

# 4. .env 파일이 diff에 포함되었는지 확인 (파일명 기반)
if echo "$diff_text" | grep -qE '^\+\+\+ b/.*\.env'; then
  warnings="${warnings}🚨 .env 파일이 커밋에 포함되어 있습니다!\n"
fi

# 경고가 있으면 출력
if [[ -n "$warnings" ]]; then
  echo ""
  echo "🔒 [pre-push-security] 시크릿 유출 가능성 탐지:"
  echo ""
  echo -e "$warnings"
  echo "push를 계속하려면 허용해주세요."
  echo ""
  # exit 2 = PreToolUse에서 사용자에게 확인 요청
  exit 2
fi

exit 0
