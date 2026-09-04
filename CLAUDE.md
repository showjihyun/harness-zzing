@AGENTS.md

# Repository Map

## Harness

| 목적 | 명령 또는 문서 |
| --- | --- |
| 완료 선언 전 검증 | `./harness/scripts/verify.sh` → `.harness/verify.json` |
| 하네스 자기 점검 | `./harness/scripts/self-check.sh` (verify 의 다섯 단계가 이것입니다) |
| 계층별 평가 | `./harness/scripts/eval.sh` → `.harness/latest-eval.json` |
| 개선 후보 기록 | `./harness/scripts/improvement-log.sh new` → `improvement-log/` |
| 보호 목록 확인 | `./harness/hooks/guard-evaluation-tampering.sh --list` |
| 규칙 목록 | `harness/rules/RULES.md` |

## Project

- 진입점 지침: `AGENTS.md`
- 기준서: `harness/HARNESS.md`
- 언어 팩: `harness/language/README.md` (감지된 스택의 팩 하나만 읽습니다)
- 검증 단계 정의: `harness.config`
- 개선 후보: `improvement-log/`
- 평가 세트: [evaluation/README.md](evaluation/README.md) (held-out 은 승격 판정 때만 엽니다)
- 비교용 참고 번들: `compare_resource/baseline/` (이 저장소의 산출물이 아닙니다)

## 이 파일의 규칙

- 지식을 이 파일에 쌓지 않습니다. 설명이 필요하면 문서를 만들고 여기에는 경로만 둡니다.
- 작업 중에 이 파일을 편집해 규칙을 추가하지 않습니다. 반복 실패는 `improvement-log/` 에 후보로 남깁니다.
- 항목을 추가할 때는 대체·삭제할 항목을 함께 정합니다. 추가만 하는 편집은 받지 않습니다.
