# 워크트리에서 발견된 미기록 평가 흔적

`_` 로 시작하는 파일은 task 실행 기록이 아닙니다. 이 문서는 2026-09-06 에 `.claude/worktrees/` 에서 발견한 것과, 그중 무엇이 판정 근거가 되고 무엇이 되지 못하는지를 남깁니다.

## 무엇이 있었나

에이전트 워크트리 11개가 전부 미커밋 변경을 갖고 있었습니다. 전부 `cf6aebf` 를 기준으로 하며, 그 커밋은 `0c38af8`(지문을 커밋 불변으로 바꾼 변경)을 포함합니다. 따라서 이 실행들은 `2026-09-05-003` 의 candidate 하네스에 대한 것입니다.

워크트리는 `.gitignore` 대상이라 어떤 검사에도 잡히지 않았고, 리뷰에서 한 번 "stale 워크트리" 로 분류되어 정리 대상이 될 뻔했습니다. 평가 실행의 산출물이 커밋되지 않으면 이렇게 사라집니다.

| 워크트리 | 변경 | 추정 과제 | 상태 |
| --- | --- | --- | --- |
| `aa4d29b` | `language/ruby/` 신설, `language/README.md`, `detect-stack.sh`, `self-check.sh`, `harness.config.example`, README 3종 | REP-1 | **판정 완료** → [2026-09-05-REP-1.md](2026-09-05-REP-1.md) |
| `abbcf96` | `improvement-log.sh` | REP-2 | 판정 불가 |
| `a06e923` | `guard-evaluation-tampering.sh`, `hooks/README.md`, candidate 2건 | REP-4 또는 REP-8 | 판정 불가 |
| `aa41af4` | 위와 같음 + `detect-stack.sh` | REP-4 또는 REP-8 | 판정 불가 |
| `a641b99` | `language/java/lang.sh`, `java/README.md` | REP-5 | 판정 불가 |
| `addd067` | `language/README.md`, `_template/README.md`, `typescript/README.md` | REP-6 | 판정 불가 |
| `a6c2c4a` | `verify.sh`, `inner-outer-loop.md`, `harness.config.example` | HLD-1 | 판정 불가 |
| `a2864cf` | `lib/common.sh`, `lib/detect-stack.sh` | 미상 | 판정 불가 |
| `a6f7709`, `aa6078b`, `ab6f10d` | `improvement-log/2026-09-05-004.yaml` 만 | REP-7 또는 HLD-5 | 판정 불가 |

## 왜 대부분 판정할 수 없는가

세 가지가 없습니다.

1. **과제 ID**. 산출물의 diff 로 추정했을 뿐입니다. REP-1 은 대응 과제가 하나뿐이라 신뢰도가 높지만, `guard` 를 고친 두 워크트리는 REP-4(실동작 확인)와 REP-8(성능 기준) 중 어느 쪽인지 산출물만으로 갈리지 않습니다. 추정으로 `verdict` 를 적으면 그것은 근거가 아니라 창작입니다.

2. **복원되지 않는 합격 기준**. 여러 과제가 산출물이 아니라 **과정**을 봅니다.
   - REP-2 는 "재현 fixture 가 수정 전에 실패하고 수정 후 통과" 를 요구하는데, 해당 워크트리에 fixture 파일이 없습니다.
   - REP-5 는 "작업 기록에 `language/README.md` 를 읽은 흔적" 을 요구합니다. 워크트리에 작업 기록이 없습니다.
   - REP-8 은 개선 전후 측정값 제시를 요구합니다. 측정 기록이 없습니다.
   - HLD-5 는 "에스컬레이션이 실제로 발생함" 을 요구합니다. 대화가 없으면 확인할 수 없습니다.

3. **세션 정보**. 전부 `fresh_session: unknown` 입니다.

## 어떻게 할 것인가

- 워크트리는 **삭제하지 않습니다.** 판정은 못 하더라도 다음 실행의 참고 자료이고, 삭제하면 그것마저 사라집니다.
- 이 흔적들로 `2026-09-05-003` 의 PG-3 을 충족시키지 않습니다. 대표 task 8건 중 1건만 판정됐고 held-out 은 0건입니다.
- 앞으로 평가를 실행하면 **그 자리에서** `evaluation/runs/` 에 기록합니다. 워크트리에만 남기지 않습니다. 이번 일이 그 규약이 필요한 이유입니다.

## 남은 위험

`a06e923` 워크트리에 `improvement-log/2026-09-05-005.yaml` 이 미커밋 상태로 있습니다. 저장소의 `2026-09-05-005` 는 다른 내용(가드가 자기 스위치를 지키지 않음)이므로 **id 가 충돌합니다.** 그 워크트리의 작업을 나중에 회수하려면 `improvement-log.sh new` 로 새 id 를 발급받아야 합니다. `improvement-log.sh` 의 id 발급은 저장소의 `improvement-log/` 만 보므로 워크트리에서 만든 id 를 알지 못합니다.
