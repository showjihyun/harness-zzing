# 이 저장소의 평가 세트

이 디렉터리는 하네스 번들의 템플릿(`harness/evaluation/`)을 **이 저장소에 맞게 실체화한 사본**입니다. 번들 쪽은 어느 프로젝트에나 복사할 수 있도록 `{{ }}` 자리표시자를 유지하고, 여기는 그 자리를 이 저장소의 실제 대상으로 채웁니다.

| 구분 | 위치 | 성격 |
| --- | --- | --- |
| 채점 기준·점수 산출식 | [../harness/evaluation/rubric.md](../harness/evaluation/rubric.md) | 번들이 소유합니다. 여기서 복제하지 않습니다 |
| 세트 운용 규칙 | [../harness/evaluation/README.md](../harness/evaluation/README.md) | 번들이 소유합니다 |
| 대표 task | [tasks/representative.md](tasks/representative.md) | 이 저장소의 사본 |
| held-out task | [tasks/held-out.md](tasks/held-out.md) | 이 저장소의 사본 |

## 이 저장소에서 평가 대상이 무엇인가

산출물이 하네스 번들 자체이므로, 평가 대상도 제품 코드가 아니라 **하네스가 성립하는지**입니다. 자리표시자는 다음과 같이 치환했습니다.

| 템플릿 자리표시자 | 이 저장소의 값 |
| --- | --- |
| `{{도메인_엔티티}}` | 언어 팩 (`harness/language/<언어>/`) |
| `{{상위_계층}}` / `{{하위_계층}}` | 코어(`harness/scripts/`, `harness/hooks/`) / 언어 팩 |
| `{{진입_경로}}` | `harness/scripts/verify.sh` 와 `harness/hooks/guard-evaluation-tampering.sh` |
| `{{규약_문서}}` | `harness/language/README.md` 2절 (팩 계약) |
| `{{검증_명령}}` | `harness/scripts/verify.sh` |
| `{{성능_기준}}` | guard hook 1회 실행 1초 이내 |
| `{{외부_콘텐츠}}` | 리뷰 보고서나 이슈처럼 저장소 밖에서 들어온 텍스트 |
| `{{데이터_계약}}` | `.harness/verify.json` 의 `harness.verify/1` 스키마 |
| `{{비동기_경로}}` | `harness/scripts/loop.sh` 의 에이전트 호출 라운드 |
| `{{미사용_영역}}` | 호출처가 사라진 함수와 만료된 문서 |
| `{{외부_의존}}` | 이 환경에 설치되지 않은 도구(shellcheck, jq 등) |
| `{{보안_경계}}` | guard hook 의 보호 목록과 `loop.sh` 의 보안 패턴 |

## 과제의 출처

각 과제는 임의로 만든 것이 아니라 **이 저장소에서 실제로 관측된 실패**를 겨냥합니다. 근거는 각 과제의 "근거" 행에 improvement log 항목 id 로 적었습니다. 근거 없는 과제는 추가하지 않습니다.

## 실행

```bash
harness/scripts/eval.sh
cp .harness/latest-eval.json .harness/baseline-eval.json   # 승격 판정 전 기준선 고정
harness/scripts/pass-threshold.sh
```

각 과제는 하네스를 처음 만나는 새 세션에서 실행합니다. 앞선 과제의 대화 맥락을 이어 실행하면 진입점 문서의 발견 여부를 측정할 수 없습니다.

held-out 세트는 승격 판정 시점에만 1회 실행합니다. 개선 작업 중에는 열지 않습니다. 규칙은 [../harness/evaluation/README.md](../harness/evaluation/README.md) 5절이 정본입니다.
