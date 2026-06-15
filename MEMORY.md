# SkillOpt Memory

## 현재 상태
```yaml
status: active
last_agent: claude-code
last_branch: main
last_session: 2026-06-15T17:01+09:00
session_count: 1
```

## 프로젝트 개요
SkillOpt — 에이전트 스킬 문서를 신경망처럼 학습(가중치 미변경, 텍스트만 검증-게이트 편집)하는 Microsoft Research 공식 코드의 내 포크(`Suvinpapa/skillopt`). 일상 적용판은 `skillopt_sleep`(SkillOpt-Sleep, preview).

## 기술 스택
- Python 3.10+ (로컬 설치: editable `pip install -e .`, 패키지 `skillopt` + `skillopt_sleep`)
- 플러그인: Claude Code / Codex / Copilot (`plugins/`), bash 러너
- 백엔드: OpenAI/Azure/Claude/Qwen/MiniMax, 엔진 mock/claude/codex

## 아키텍처 결정
- 원본 upstream = `github.com/microsoft/SkillOpt` (공식). 이 레포 origin = `Suvinpapa/skillopt` (내 포크). 수정은 포크에만, upstream PR 안 함.
- `skillopt_sleep`는 논문 `skillopt/`에 의존성 0 (gate만 vendoring).
- Sleep 쓰기 대상: 메모리=`프로젝트/CLAUDE.md` LEARNED 블록(프로젝트별), 스킬=`~/.claude/skills/skillopt-sleep-learned/SKILL.md`(글로벌). 기존 스킬은 직접 수정 안 함.

## 코드 컨벤션
- 표준 에이전트 ID: claude-code / claude-desktop / claude-web / claude-mobile / gemini-cli / antigravity / opencode / other.

## 알려진 제약사항
- 플러그인 슬래시 명령은 bash 러너 → Windows는 Git Bash 필요. cron 스케줄은 Windows 미지원(WSL/작업스케줄러 대체).
- `karpathy-memory`(루트 `MEMORY.md`)와 SkillOpt-Sleep(`CLAUDE.md`/`SKILL.md`)는 파일 충돌 없음, 상보적. 같은 내용 양쪽 중복만 주의.

## 하지 말 것
- Sleep `run` 결과를 직접 `adopt` 없이 라이브 파일에 손대지 말 것: 게이트/staging 우회 금지.
- 캐시(`~/.claude/plugins/cache/...`) 수동 패치는 임시 — 재설치 시 소실. 근본 수정은 repo에서.

## 세션 로그
| session_end | agent | branch | status | summary |
|---|---|---|---|---|
| 2026-06-15T17:01+09:00 | claude-code | main | active | SkillOpt/Sleep 구조 설명, dry-run 시연(112세션→40작업), `pip install -e .`, claude-code 플러그인 설치(user scope). 플러그인 패키징 버그(run-sleep.sh 미동봉) 진단·수정 → `plugins/claude-code/scripts/sleep.sh` self-contained 재작성, `SKILLOPT_SLEEP_REPO` env 등록. |
