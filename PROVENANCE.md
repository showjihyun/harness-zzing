# 이 하네스는 어디에서 왔는가

이 문서는 저장소에 지금 있는 것이 **어디에서 도출되었고, 무엇이 도출되지 않았는지**를 기록합니다. 하네스를 바꾸려는 사람이 "이 규칙은 왜 여기에 있는가"를 되짚을 때, 근거 없이 슬며시 추가된 것이 없는지 검토할 때 먼저 읽습니다.

기록의 층위는 셋입니다. 원문에서 온 것, 이 저장소에서 관측되어 추가된 것, 검토했으나 도입하지 않은 것입니다. 세 번째를 남기는 이유는 도입하지 않은 판단도 근거이기 때문입니다. 근거가 남지 않으면 다음 라운드에 같은 제안이 다시 올라옵니다.

## 1. 원문

| 항목 | 값 |
| --- | --- |
| 제목 | AI Agentic Coding의 Self-Improving Loop란 무엇인가 |
| 매체 | Toby's Codex |
| 사이트 | codex.epril.com |
| 발행일 | 2026-08-08 |

번들의 뼈대 전부가 이 글에서 나왔습니다. `HE-1`~`HE-15` 요소 인벤토리, `HP-1`~`HP-8` 불변 원칙, `EL-1`~`EL-7` 강제력 사다리, L0~L5 성숙도, 여섯 평가 계층, 개선 로그 스키마입니다.

**행 단위 대응은 [harness/references/source-mapping.md](harness/references/source-mapping.md) 가 소유합니다.** 원문의 섹션 하나하나가 어느 산출물로 승격되었는지가 거기에 표로 있습니다. 이 문서에 그 표를 복제하지 마십시오.

번들은 원문의 요약이 아닙니다. 원문에서 도출한 요구사항을 규칙 ID, 절차, 스크립트, 스키마로 승격시킨 결과입니다. 따라서 산출물의 문장과 원문의 문장은 일대일로 대응하지 않으며, 대응하는 것은 요구사항입니다. 번들은 원문 사본을 포함하지 않습니다. 대조가 필요하면 위 출처에서 원문을 먼저 확보하십시오.

## 2. 이 저장소에서 추가된 것

아래는 원문에 없고 **이 저장소에서 관측된 실패로부터** 추가된 것입니다. 각 항목은 개선 로그 하나를 근거로 답니다. 로그가 없는 항목은 근거가 없다는 뜻이며 제거 검토 대상입니다.

| 추가된 것 | 왜 | 근거 |
| --- | --- | --- |
| `harness/language/` 언어 팩 5종 | 코어 문서와 스크립트가 Java·Spring 예시와 Node 설정 예시에 묶여 있어 다른 스택에 그대로 쓸 수 없었습니다. 언어 종속을 팩으로 분리하고 FE·BE 를 구분했습니다. | [improvement-log/2026-09-03-002.yaml](improvement-log/2026-09-03-002.yaml) |
| 보호 패턴의 감지 무관 합집합 | 팩 분리 직후, 가드 훅의 언어별 보호가 스택 감지 성공에 의존해 감지 실패 저장소에서 보호가 조용히 사라졌습니다. 감지 결과와 무관하게 모든 팩의 패턴을 합칩니다. | [improvement-log/2026-09-03-001.yaml](improvement-log/2026-09-03-001.yaml) |
| `harness/scripts/self-check.sh` | 팩의 계약을 문서로만 규정해 두어 계약 위반이 조용히 통과했습니다. 계약 검사를 `EL-5` 로 올린 새 번들 자산입니다. | [improvement-log/2026-09-03-002.yaml](improvement-log/2026-09-03-002.yaml) |
| 팩 문서를 델타만 담도록 축소 | 팩 예시 문서가 코어를 복제해 같은 lesson 이 여러 자리에 정본으로 존재했고 이미 드리프트가 발생했습니다. | [improvement-log/2026-09-03-003.yaml](improvement-log/2026-09-03-003.yaml) |
| `harness/skills/harness-score/` | 감사 모드가 내놓는 L0~L5 값 하나로는 다음에 무엇을 고칠지 알 수 없었고, 그 자리를 메우려고 만든 채점 기준이 세션 임시 파일에만 존재했습니다. | [improvement-log/2026-09-04-001.yaml](improvement-log/2026-09-04-001.yaml) |

### 채점 축 여섯 개 중 하나는 관측에서 나왔습니다

`harness/skills/harness-score/rubric.md` 의 P·E·X·G·R 다섯 축은 번들 자신의 규범(`EL-*` 사다리, `GC-2`, 공통 근거 모델)에서 끌어왔습니다. 여섯 번째 **D 문서 부패** 축만 이 저장소의 관측에서 나왔습니다. 문서와 구현이 어긋난 사례가 실제로 여덟 건 확인되었기 때문입니다. 다른 축과 출처가 다르므로 여기 적어 둡니다.

### 배치

하네스는 처음 `compare_resource/harness` 에 있었고 2026-09-04 에 워크스페이스 루트로 옮겼습니다. 이 저장소는 자기 자신을 검증합니다. `harness.config` 의 다섯 단계가 전부 `harness/scripts/self-check.sh` 이며, 계층별로 나눠 등록되어 있습니다.

## 3. 검토했으나 도입하지 않은 것

`compare_resource/baseline` 은 별개의 프런트엔드 기준 번들입니다. 이 저장소의 하네스와 계보가 다르며 **의도적으로 손대지 않았습니다.** 참고 자료로만 남아 있습니다.

이 번들을 하네스 엔지니어링 관점에서 비판적으로 검토해 다섯 가지 도입안을 만들었고, **다섯 모두 도입하지 않기로 판정했습니다.** 판정 근거는 번들 자신의 규칙입니다.

- 다섯 중 넷은 이 저장소에서 **관측된 근거가 0건**이었습니다. `rules/untrusted-experience.rule.md` 의 `UT-1` 이 외부 문서에서 읽은 것을 관측 없이 규칙으로 옮기지 말라고 규정합니다. 좋아 보인다는 것은 근거가 아닙니다.
- 나머지 하나(문서 라우팅 검사)는 **우리가 갖고 있지 않은 문제를 푸는 것**이었습니다. 이 저장소에서 관측된 문제는 문서를 덜 읽는 것이 아니라 더 읽는 것이었습니다. 방향이 반대인 처방입니다.
- 다섯을 한 번에 제안한 것 자체가 `rules/harness-change-control.rule.md` 의 한 번에 하나 규칙과 어긋납니다.

이 판정을 기록으로 남기는 이유는, 근거 없이 좋아 보이는 것을 들여오는 것이 하네스가 비대해지는 가장 흔한 경로이기 때문입니다. 나중에 관측된 필요가 생기면 그때 근거와 함께 다시 올립니다.

## 4. 근거가 없는 것

현재 이 저장소에는 원문 근거도 관측 근거도 없이 추가된 산출물이 **없습니다.** 새 산출물을 추가할 때는 다음 중 하나를 만족시켜야 합니다.

1. `harness/references/source-mapping.md` 의 어느 행에 연결됩니다.
2. `improvement-log/` 의 항목 하나가 관측된 실패를 근거로 답니다.

둘 다 아니면 그 산출물은 근거 없이 추가된 것이므로, 근거를 새로 밝히거나 제거 대상으로 분류합니다. 판정 절차는 [harness/skills/harness-gardener/SKILL.md](harness/skills/harness-gardener/SKILL.md) 를 따릅니다.

## 5. 이 문서의 수명

| 소유자 | 재검토 조건 |
| --- | --- |
| unassigned | 새 산출물이 원문·관측 어느 근거에도 연결되지 않은 채 추가된 것이 발견될 때, 또는 `compare_resource/baseline` 의 도입안이 관측된 근거와 함께 다시 올라올 때 |

## 관련 문서

- [harness/references/source-mapping.md](harness/references/source-mapping.md) — 원문 섹션과 산출물의 행 단위 대응
- [harness/HARNESS.md](harness/HARNESS.md) — `HE-*` 요소 인벤토리와 `HP-*` 불변 원칙
- [improvement-log/README.md](improvement-log/README.md) — 관측된 실패를 근거로 남기는 형식
- [harness/rules/untrusted-experience.rule.md](harness/rules/untrusted-experience.rule.md) — 외부에서 읽은 것을 규칙으로 옮기지 않는 근거
- [harness/rules/harness-change-control.rule.md](harness/rules/harness-change-control.rule.md) — 한 번에 하나만 제안하고 평가하는 근거
