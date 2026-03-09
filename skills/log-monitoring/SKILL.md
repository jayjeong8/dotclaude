---
name: log-monitoring
description: Loki 로그 모니터링 및 분석. "로그 확인", "로그 모니터링", "log check", "check logs", "monitor logs" 요청 시 활성화.
---

# Loki Log Monitoring

Loki를 사용하여 서비스의 로그를 실시간으로 모니터링합니다.

## 입력 파라미터

- $ARGUMENTS: `<app> <environment> [monitoring_type]`
  - **app**: 서비스 이름 (예: buzzad, buzzscreen-api, bi-event-logger 등)
  - **environment**: 환경 이름 (예: prod, prodmini, staging, stagingqa 등)
  - **monitoring_type** (선택): `log` 또는 `error` (기본값: 현재 세션 컨텍스트에 따라 자동 선택)

## App 이름 매핑 (중요!)

**일부 repository는 logcli에서 다른 app 이름으로 조회해야 합니다:**

| Repository | logcli app 이름 | 비고 |
|------------|-----------------|------|
| `adserver` | `buzzad` | adserver 코드는 buzzad app으로 배포됨 |

예: adserver의 `[REWARD_DIFF]` 로그를 찾으려면 → `{app="buzzad", instance="buzzad-py3-prod"}`

## Loki 환경 선택 규칙

**중요**: 환경 이름에 따라 사용할 Loki 서버가 결정됩니다.

| 환경 | Loki 서버 | URL |
|------|-----------|-----|
| `prod`, `prodmini`, `prodpostback` 등 (prod 포함) | Loki (Prod) | `https://loki.buzzvil.dev` |
| `staging`, `stagingqa`, `stagingwf` 등 (prod 미포함) | Loki (Dev) | `https://loki-dev.buzzvil.dev` |

```bash
# 환경 판단 로직 - Loki 주소 선택
if [[ "$ENVIRONMENT" == *"prod"* ]]; then
    LOKI_ADDR="https://loki.buzzvil.dev"
else
    LOKI_ADDR="https://loki-dev.buzzvil.dev"
fi
```

## Instance 라벨 구성

**쿼리 형식**: `{app="<app>", instance="<app>-<suffix>-<environment>"}`

예시:
- `{app="buzzad", instance="buzzad-py3-staging"}`
- `{app="buzzad", instance="buzzad-py3-prodpostback"}`
- `{app="buzzad", instance="buzzad-py3-prod"}`

### Instance 자동 탐색

환경에 맞는 instance를 모를 경우, 먼저 사용 가능한 instance 목록을 조회:

```bash
# 1. 해당 app의 모든 instance 목록 조회 (--addr 필수!)
logcli --addr="$LOKI_ADDR" series '{app="'"$APP"'"}' | grep -oE 'instance="[^"]+"' | cut -d'"' -f2 | sort -u

# 2. 환경 이름이 포함된 instance 필터링
logcli --addr="$LOKI_ADDR" series '{app="'"$APP"'"}' | grep -oE 'instance="[^"]+"' | cut -d'"' -f2 | sort -u | grep -i "$ENVIRONMENT"
```

**예시 결과:**
```
buzzad-py3-staging
buzzad-py3-stagingqa
buzzad-py3-prod
buzzad-py3-prodpostback
```

→ 환경이 "staging"이면 `buzzad-py3-staging` 선택

## 모니터링 타입

### 1. 로그 출력 확인 (type: log)
- **목적**: 내가 추가한 로그가 정상적으로 출력되는지 확인
- **사용 시점**: 새로운 로그를 추가한 후 배포 검증
- **쿼리 전략**: 현재 세션에서 추가한 로그 메시지/키워드 기반 필터링

### 2. 에러 로그 확인 (type: error)
- **목적**: 에러 로그 발생 여부 모니터링
- **사용 시점**: 배포 후 안정성 확인, 장애 탐지
- **쿼리 전략**: level="error" 또는 에러 패턴 매칭

## 기본 쿼리 문법

```bash
logcli --addr="<LOKI_ADDRESS>" query '<QUERY>' [OPTIONS]

# 주요 옵션
--from="<RFC3339_TIME>"  # 시작 시간
--to="<RFC3339_TIME>"    # 종료 시간
--limit=<N>              # 최대 결과 수
-o raw                   # 출력 형식: default, raw, jsonl
```

## 시간 범위 설정 (macOS)

```bash
# 최근 5분 (기본값)
--from="$(date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')"

# 최근 1시간
--from="$(date -u -v-1H '+%Y-%m-%dT%H:%M:%SZ')"

# 최근 24시간
--from="$(date -u -v-1d '+%Y-%m-%dT%H:%M:%SZ')"
```

## 분석 절차

### 1. 파라미터 파싱 및 환경 설정
```bash
APP="$1"
ENVIRONMENT="$2"
MONITORING_TYPE="${3:-auto}"  # log, error, 또는 auto

# Loki 주소 결정
if [[ "$ENVIRONMENT" == *"prod"* ]]; then
    LOKI_ADDR="https://loki.buzzvil.dev"
    echo "🔴 Using Loki (Prod): $LOKI_ADDR"
else
    LOKI_ADDR="https://loki-dev.buzzvil.dev"
    echo "🟡 Using Loki (Dev): $LOKI_ADDR"
fi

# 시간 범위: 최근 5분
FROM_TIME=$(date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')  # macOS
TO_TIME=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
```

### 1.5. Instance 자동 탐색 (중요!)
```bash
# 해당 app의 instance 목록 조회
echo "🔍 Searching instances for app=$APP..."
INSTANCES=$(logcli --addr="$LOKI_ADDR" series '{app="'"$APP"'"}' 2>/dev/null | grep -oE 'instance="[^"]+"' | cut -d'"' -f2 | sort -u)

# 환경에 맞는 instance 필터링
INSTANCE=$(echo "$INSTANCES" | grep -i "$ENVIRONMENT" | head -1)

if [[ -z "$INSTANCE" ]]; then
    echo "⚠️ No instance found matching '$ENVIRONMENT'. Available instances:"
    echo "$INSTANCES"
    echo ""
    echo "Please specify the exact instance name."
    exit 1
fi

echo "✅ Found instance: $INSTANCE"
```

### 2. 세션 컨텍스트 분석 (중요!)

**현재 대화에서 로그 관련 작업이 있었는지 확인하세요:**

1. **로그 추가 작업이 있었다면**:
   - 추가된 로그 메시지의 키워드/패턴 추출
   - 해당 패턴으로 로그 출력 확인 쿼리 구성
   - 예: `[REWARD_DIFF]`, `[REWARD_MATCH]` 등의 로그 태그

2. **에러 처리 코드 변경이 있었다면**:
   - 추가된 에러 로그 메시지 확인
   - 해당 에러가 발생하는지 모니터링

3. **컨텍스트 없으면**:
   - 일반적인 에러 로그 모니터링 수행

### 3. logcli 쿼리 구성

#### 앱별 로그 조회
```bash
logcli --addr="$LOKI_ADDR" query \
  '{app="buzzscreen-api"}' \
  --from="$(date -u -v-5M '+%Y-%m-%dT%H:%M:%SZ')" \
  --limit=100 -o raw
```

#### 로그 출력 확인 쿼리 (특정 로그 패턴)
```bash
# 세션에서 추가한 로그 패턴 기반 (예시)
LOG_PATTERN="REWARD_DIFF|REWARD_MATCH"  # 세션 컨텍스트에서 추출

logcli --addr="$LOKI_ADDR" query \
  '{app="'"$APP"'", instance="'"$INSTANCE"'"}' \
  --from="$FROM_TIME" \
  --to="$TO_TIME" \
  --limit=100 \
  -o raw \
  | grep -E "$LOG_PATTERN"
```

#### 특정 패턴 검색
```bash
logcli --addr="https://loki.buzzvil.dev" query \
  '{app="buzzscreen-api"} |~ "error|ERROR"' \
  --limit=100 -o raw
```

#### 에러 로그 확인 쿼리
```bash
# JSON 로그의 level 필드 기반
logcli --addr="$LOKI_ADDR" query \
  '{app="'"$APP"'", instance="'"$INSTANCE"'"} | json | level="error"' \
  --from="$FROM_TIME" \
  --to="$TO_TIME" \
  --limit=100 \
  -o raw

# 또는 텍스트 패턴 매칭
logcli --addr="$LOKI_ADDR" query \
  '{app="'"$APP"'", instance="'"$INSTANCE"'"} |~ "(?i)(error|exception|failed|traceback)"' \
  --from="$FROM_TIME" \
  --to="$TO_TIME" \
  --limit=100 \
  -o raw
```

#### JSON 필드 추출
```bash
logcli --addr="https://loki.buzzvil.dev" query \
  '{app="buzzscreen-api"} | json | campaign_type != ""' \
  --limit=50 -o raw
```

### 4. 분석 패턴

#### 특정 필드값 찾기
```bash
logcli --addr="https://loki.buzzvil.dev" query \
  '{app="buzzscreen-api"}' \
  --from="$(date -u -v-10M '+%Y-%m-%dT%H:%M:%SZ')" \
  --limit=200 -o raw | grep -i "campaign_type"
```

#### 고유값 추출
```bash
logcli --addr="https://loki.buzzvil.dev" query \
  '{app="buzzscreen-api"}' \
  --limit=500 -o jsonl | jq -r '.campaign_type' | sort | uniq -c
```

### 5. 대량 로그 조회

많은 로그를 조회해야 할 경우 `--limit`과 `--batch`를 활용합니다:

```bash
# 대량 로그 조회 (batch로 나눠서 요청)
# --batch: 한 번의 API 요청당 가져올 로그 수 (기본값: 1000)
# --limit: 총 가져올 로그 수
logcli --addr="$LOKI_ADDR" query \
  '{app="'"$APP"'", instance="'"$INSTANCE"'"}' \
  --from="$FROM_TIME" \
  --to="$TO_TIME" \
  --limit=5000 \
  --batch=1000 \
  -o raw
```

### 6. 연속 모니터링 스크립트

사용자가 중단할 때까지 계속 모니터링:

```bash
#!/bin/bash
# loki-monitor.sh

APP="$1"
ENV="$2"
TYPE="${3:-error}"  # log 또는 error
INTERVAL=30         # 30초 간격

# Loki 주소 결정
if [[ "$ENV" == *"prod"* ]]; then
    LOKI_ADDR="https://loki.buzzvil.dev"
    echo "🔴 Using Loki (Prod): $LOKI_ADDR"
else
    LOKI_ADDR="https://loki-dev.buzzvil.dev"
    echo "🟡 Using Loki (Dev): $LOKI_ADDR"
fi

# Instance 자동 탐색
echo "🔍 Searching instances for app=$APP..."
INSTANCES=$(logcli --addr="$LOKI_ADDR" series '{app="'"$APP"'"}' 2>/dev/null | grep -oE 'instance="[^"]+"' | cut -d'"' -f2 | sort -u)
INSTANCE=$(echo "$INSTANCES" | grep -i "$ENV" | head -1)

if [[ -z "$INSTANCE" ]]; then
    echo "⚠️ No instance found matching '$ENV'. Available instances:"
    echo "$INSTANCES"
    exit 1
fi

echo "✅ Instance: $INSTANCE"
echo "📊 Type: $TYPE | Interval: ${INTERVAL}s | Press Ctrl+C to stop"
echo "=================================================="

LAST_CHECK=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

while true; do
    NOW=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

    if [[ "$TYPE" == "error" ]]; then
        # 에러 로그 모니터링
        QUERY='{app="'"$APP"'", instance="'"$INSTANCE"'"} | json | level="error"'
    else
        # 특정 로그 패턴 모니터링 (환경변수 LOG_PATTERN 사용)
        PATTERN="${LOG_PATTERN:-.*}"
        QUERY='{app="'"$APP"'", instance="'"$INSTANCE"'"} |~ "'"$PATTERN"'"'
    fi

    RESULT=$(logcli --addr="$LOKI_ADDR" query \
        "$QUERY" \
        --from="$LAST_CHECK" \
        --to="$NOW" \
        --limit=100 \
        -o raw 2>/dev/null)

    if [[ -n "$RESULT" ]]; then
        echo ""
        echo "🕐 $(date '+%H:%M:%S') - New logs found:"
        echo "$RESULT"
        echo "--------------------------------------------------"
    else
        echo -n "."  # 진행 표시
    fi

    LAST_CHECK="$NOW"
    sleep $INTERVAL
done
```

**스크립트 사용법:**
```bash
# 에러 모니터링 (instance 자동 탐색: buzzad-py3-prod 등)
./loki-monitor.sh buzzad prod error

# 특정 로그 패턴 모니터링
LOG_PATTERN="REWARD_DIFF" ./loki-monitor.sh adserver staging log
```

## Workflow

Copy and track:
```
Log Monitoring Progress:
- [ ] Identify target app and environment (prod/staging)
- [ ] Determine time range
- [ ] Check logcli connectivity
- [ ] Build and execute LogQL query
- [ ] Analyze and summarize results
```

## 출력 형식

### 실시간 모니터링 출력
```
🔴 Using Loki (Prod): https://loki.buzzvil.dev
🔍 Searching instances for app=adserver...
✅ Instance: adserver-prod
📊 Type: log | Interval: 30s | Press Ctrl+C to stop
==================================================
🕐 12:15:30 - New logs found:
2026-01-28T03:15:25Z [REWARD_DIFF] click_id=abc123 ...
--------------------------------------------------
...
```

### 에러 요약 (모니터링 종료 후)
| 항목 | 내용 |
|------|------|
| 모니터링 기간 | HH:MM ~ HH:MM KST |
| 총 로그 수 | N건 |
| 에러 수 | N건 |
| 주요 패턴 | 발견된 로그 패턴 |

### 세션 컨텍스트 기반 분석
| 변경 사항 | 검증 결과 |
|-----------|-----------|
| [REWARD_DIFF] 로그 추가 | ✅ 정상 출력 확인 |
| display_point None 체크 추가 | ✅ 에러 미발생 |

### 결과 보고 형식

분석 완료 후 다음 형식으로 보고:

```markdown
## 쿼리
<사용한 logcli 명령어>

## 결과 요약
<핵심 발견 사항>

## 상세 내용
<관련 로그 엔트리 또는 패턴>

## 권장 사항
<인사이트 또는 다음 단계>
```

## 트러블슈팅

| 문제 | 해결책 |
|------|--------|
| Connection refused | VPN 연결 확인 |
| No such host | Loki 서버 주소 확인 |
| Empty results | 시간 범위 확장 또는 필터 확인 |
| Timeout | limit 줄이거나 쿼리 범위 좁히기 |

## 주의사항

1. **logcli 설치 필요**: `brew install logcli` 또는 Grafana Loki 패키지에서 설치
2. **인증**: Loki 접근에 인증이 필요한 경우 `--username`, `--password` 또는 `--org-id` 옵션 사용
3. **타임존**: logcli는 UTC 기준, KST 변환 시 +9시간 고려
4. **rate limit**: 과도한 쿼리 시 rate limit에 걸릴 수 있음, interval 조절 필요
