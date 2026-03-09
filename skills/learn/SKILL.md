---
name: learn
description: 주제/URL/파일을 기반으로 가속 학습 워크플로우를 실행합니다. 소스 수집 → 멘탈모델 추출 → 소크라틱 Q&A까지 자동화합니다. "/learn React Server Components", "/learn https://...", "/learn --resume topic", "/learn --assess topic" 등의 요청 시 사용합니다.
---

# Accelerated Learning System

주제/URL/파일을 입력받아 소스 수집 → 핵심 추출 → 소크라틱 Q&A까지 자동화된 가속 학습 워크플로우를 실행합니다.

## 입력 파싱

`$ARGUMENTS`를 분석하여 모드와 입력 타입을 결정합니다.

### 플래그 처리
- `--resume <topic-slug>`: 기존 `~/.claude/learning/<topic-slug>/progress.json`에서 마지막 완료 단계 이후부터 재개
- `--assess <topic-slug>`: 기존 synthesis.md 기반으로 바로 Phase 3 (Q&A) 진입

### 입력 타입 판별 (플래그 없을 때)
- URL 패턴 (`http://`, `https://`) → URL 기반 학습
- 파일 경로 (존재하는 파일) → 파일 기반 학습
- 그 외 텍스트 → 주제 기반 학습

### topic-slug 생성
입력에서 핵심 키워드를 추출하여 kebab-case slug 생성 (예: "React Server Components" → `react-server-components`)

## 디렉토리 초기화

```
~/.claude/learning/<topic-slug>/
  ├── sources/
  ├── sessions/
  ├── synthesis.md
  ├── questions.md
  └── progress.json
```

`progress.json` 초기 구조:
```json
{
  "topic": "<원본 입력>",
  "slug": "<topic-slug>",
  "phases": {
    "research": { "status": "pending", "completedAt": null },
    "synthesize": { "status": "pending", "completedAt": null },
    "assess": { "status": "pending", "completedAt": null }
  },
  "sessions": [],
  "createdAt": "<ISO timestamp>"
}
```

## 실행 절차

### Phase 1: 소스 수집

**Agent 실행** (`learn-research`):
- 입력 타입에 따라 적절한 프롬프트 구성:
  - **주제**: `"주제 '<topic>'에 대해 영/한 양쪽으로 검색하여 핵심 소스 5-8개를 수집하세요."`
  - **URL**: `"URL '<url>'의 내용을 수집하고, 관련 추가 소스도 검색하세요."`
  - **파일**: `"파일 '<path>'의 내용을 읽고, 관련 추가 소스도 검색하세요."`
- 저장 경로: `~/.claude/learning/<topic-slug>/`
- Agent가 sources/ 디렉토리에 결과 저장 후 반환

**사용자 확인** (AskUserQuestion):
수집된 소스 목록을 제시하고 확인:
```
📚 수집된 소스 (N개):
1. [제목] - 핵심 요약 한 줄
2. [제목] - 핵심 요약 한 줄
...

추가하고 싶은 소스나 제거할 소스가 있나요?
(엔터로 계속 진행, 또는 URL/키워드 입력)
```

- 추가 소스 요청 시: Agent를 다시 실행하여 추가 수집
- 제거 요청 시: 해당 파일 삭제
- 확인 시: progress.json 업데이트 후 Phase 2 진행

### Phase 2: 핵심 추출

**Agent 실행** (`learn-synthesize`):
- sources/ 디렉토리의 모든 소스를 분석하여 synthesis.md 생성
- 저장 경로: `~/.claude/learning/<topic-slug>/`

**사용자 피드백** (AskUserQuestion):
synthesis.md의 핵심 내용을 요약 제시:
```
🧠 핵심 멘탈모델 5가지:
1. [모델명] - 원리 한 줄 요약
2. ...

⚔️ 전문가 논쟁 3가지:
1. [논쟁 주제] - 현재 합의 상태
2. ...

🗺️ 참조 프레임워크: [핵심 개념 관계 한 줄]

수정하거나 보충할 내용이 있나요?
(엔터로 Q&A 단계 진행, 또는 피드백 입력)
```

- 피드백 있으면: Agent를 다시 실행하여 synthesis.md 업데이트
- 확인 시: progress.json 업데이트 후 Phase 3 진행

### Phase 3: 소크라틱 Q&A

**질문 생성** (Agent `learn-assess`):
- synthesis.md 기반으로 questions.md 생성 (10개 질문 + 모범답안)
- 저장 경로: `~/.claude/learning/<topic-slug>/`

**Q&A 루프** (이 SKILL에서 직접 실행):

세션 파일 생성: `sessions/YYYY-MM-DD-HH-MM.md`

각 질문에 대해 순서대로:

1. **질문 제시** (AskUserQuestion):
   ```
   📝 질문 [N/10]:
   [질문 내용]

   (답변을 입력하세요. "힌트" → 단서 제공, "스킵" → 모범답안 공개)
   ```

2. **답변 처리**:
   - `"힌트"` 입력 시: 모범답안에서 핵심 키워드만 추출하여 단서 제공 → 재질문
   - `"스킵"` 입력 시: 모범답안 전체 공개 → 점수 0점 기록 → 다음 질문
   - 답변 입력 시: 모범답안·평가 기준과 비교하여 평가

3. **평가 및 피드백**:
   ```
   점수: [0-100]
   ✅ 잘 짚은 부분: ...
   ❌ 놓친 부분: ...
   💡 보충: [소스 기반 추가 설명]
   ```
   - 70점 미만: 보충 설명 + 다른 각도에서 후속 질문 제시 (AskUserQuestion)
   - 70점 이상: 다음 질문으로 진행

4. **세션 기록**: 각 Q&A를 세션 파일에 기록

**세션 완료 후**:
영역별 점수 분석 결과 출력:
```
📊 학습 결과:
- 전체 평균: [점수]/100
- 강점 영역: [영역명]
- 약점 영역: [영역명]
- 추천 다음 단계: [구체적 제안]
```

progress.json 업데이트:
```json
{
  "sessions": [..., {
    "date": "<ISO>",
    "averageScore": 75,
    "questionScores": [80, 60, ...],
    "weakAreas": ["영역1"],
    "strongAreas": ["영역2"]
  }]
}
```

## --resume 처리

1. `~/.claude/learning/<topic-slug>/progress.json` 읽기
2. 마지막으로 완료된 phase 확인
3. 다음 미완료 phase부터 재개
4. 이미 모든 phase 완료 시: 새 Q&A 세션 시작 (Phase 3)

## --assess 처리

1. `~/.claude/learning/<topic-slug>/synthesis.md` 존재 확인
2. 없으면 에러: "먼저 `/learn <주제>`로 학습을 시작하세요."
3. 있으면 바로 Phase 3 (Q&A) 실행

## 주의사항
- Agent는 사용자와 상호작용할 수 없음. 모든 사용자 인터랙션은 이 SKILL에서 AskUserQuestion으로 처리
- 소스 수집 시 저작권 있는 전체 텍스트 복사 금지. 핵심 요약만 저장
- Q&A에서 단순 정의/사실 재현 질문 금지. 적용·비교·전이·반례·통합 유형만 사용
