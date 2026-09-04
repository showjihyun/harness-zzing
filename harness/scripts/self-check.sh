#!/usr/bin/env bash
# self-check.sh — 하네스 번들 자신이 성립하는지 검사합니다.
#
# 대상 프로젝트의 코드가 아니라 **하네스 설치 상태**를 봅니다. 하네스를 처음 붙인 직후,
# 언어 팩을 추가한 뒤, 그리고 verify 단계로 등록해 매 검증마다 자동으로 실행합니다.
#
# 이 스크립트가 존재하는 이유:
#   언어 팩 계약, 보호 패턴 병합, 문서 링크는 전부 기계로 판정할 수 있는데 문서로만 규정하면
#   어겨져도 아무 신호가 나지 않습니다. 특히 팩이 계약을 어기면 guard hook 의 보호 목록이
#   조용히 줄어듭니다. 그 판정을 지시문(EL-1)에서 검증(EL-5)으로 올리는 것이 이 스크립트입니다.
#   근거: improvement-log 2026-09-03-002, rules/lesson-placement.rule.md LP-1.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1090,SC1091
source "${SCRIPT_DIR}/lib/common.sh"

# 프로젝트 설정을 읽습니다. HARNESS_SELF_CHECK_LINK_DIRS 를 여기서 가져옵니다.
# verify.sh 가 각 단계를 bash -c 로 띄우므로 부모의 변수는 전달되지 않습니다.
# (guard hook 과 달리 이 스크립트는 사람이 실행하는 검증 명령이라 설정을 읽어도 됩니다.)
HARNESS_PROJECT_ROOT_RESOLVED="$(find_project_root "$PWD")"
load_config "${HARNESS_PROJECT_ROOT_RESOLVED}" || true

usage() {
  cat <<'USAGE'
사용법: self-check.sh [옵션]

하네스 번들 자신의 무결성을 검사합니다. 대상 프로젝트의 코드는 보지 않습니다.

검사 항목:
  syntax      번들의 모든 bash 스크립트가 파싱되는가
  packs       언어 팩이 하나 이상 로드되고 전부 계약을 지키는가
  protection  보호 패턴이 감지와 무관하게 모든 팩의 합집합으로 병합되는가
  links       번들 안 마크다운의 상대 링크가 전부 실재하는가
              HARNESS_SELF_CHECK_LINK_DIRS 로 프로젝트 문서를 검사 대상에 더할 수 있습니다
  log-schema  번들이 제공하는 improvement-log 예시가 스키마를 만족하는가

옵션:
  --only <검사>   지정한 검사만 실행합니다. 여러 번 지정할 수 있습니다.
  --list          검사 목록만 출력합니다.
  -h, --help      이 도움말을 출력합니다.

종료 코드:
  0  모든 검사 통과
  1  하나 이상 실패
  3  인자가 잘못되었습니다
USAGE
}

CHECKS=(syntax packs protection links log-schema)
ONLY=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --list) printf '%s\n' "${CHECKS[@]}"; exit 0 ;;
    --only)
      [[ $# -ge 2 ]] || die "--only 에는 검사 이름이 필요합니다." 3
      ONLY+=("$2"); shift 2 ;;
    --only=*) ONLY+=("${1#*=}"); shift ;;
    *) die "알 수 없는 옵션입니다: $1 (--help 를 보십시오)" 3 ;;
  esac
done

selected() {
  [[ ${#ONLY[@]} -eq 0 ]] && return 0
  local o
  for o in "${ONLY[@]}"; do [[ "$o" == "$1" ]] && return 0; done
  return 1
}

FAILED=0
report_pass() { printf '  [ok]   %s — %s\n' "$1" "$2"; }
report_fail() { printf '  [FAIL] %s — %s\n' "$1" "$2"; FAILED=$((FAILED + 1)); }

printf '하네스 자기 점검: %s\n\n' "${HARNESS_DIR}"

# --- 1. syntax -----------------------------------------------------------------
if selected syntax; then
  bad=""
  while IFS= read -r f; do
    bash -n "$f" 2>/dev/null || bad="${bad} ${f#"${HARNESS_DIR}/"}"
  done < <(find "${HARNESS_DIR}" -name '*.sh' -type f)
  if [[ -z "$bad" ]]; then
    report_pass syntax "번들의 모든 bash 스크립트가 파싱됩니다"
  else
    report_fail syntax "파싱 실패:${bad}"
  fi
fi

# --- 2. packs ------------------------------------------------------------------
# 팩 로더를 서브셸에서 돌려 계약 위반 개수와 로드된 팩 수를 회수합니다.
if selected packs; then
  pack_out="$(
    # shellcheck disable=SC1090,SC1091
    source "${SCRIPT_DIR}/lib/detect-stack.sh" 2>/dev/null || exit 9
    harness_lang_load_packs 2>/dev/null || true
    printf '%s|%s\n' "${#HARNESS_LANG_PACKS[@]}" "${HARNESS_LANG_PACK_PROBLEMS:-0}"
  )" || pack_out="0|9"
  pack_count="${pack_out%%|*}"
  pack_problems="${pack_out##*|}"
  if [[ "$pack_count" -eq 0 ]]; then
    report_fail packs "언어 팩을 하나도 로드하지 못했습니다. 언어별 보호와 기본 단계가 없습니다"
  elif [[ "$pack_problems" -ne 0 ]]; then
    report_fail packs "계약을 어긴 팩 ${pack_problems}개가 비활성화되었습니다 (사유는 위 stderr)"
  else
    report_pass packs "팩 ${pack_count}개가 전부 계약을 지킵니다"
  fi
fi

# --- 3. protection --------------------------------------------------------------
# 보호 목록이 감지에 의존하지 않는지 확인합니다. 스택을 감지할 수 없는 디렉터리에서
# guard --list 를 돌려도 언어별 패턴이 나와야 합니다.
if selected protection; then
  guard="${HARNESS_DIR}/hooks/guard-evaluation-tampering.sh"
  if [[ ! -x "$guard" && ! -f "$guard" ]]; then
    report_fail protection "guard-evaluation-tampering.sh 를 찾을 수 없습니다"
  else
    empty_dir="$(mktemp -d)"
    trap 'rm -rf "${empty_dir}"' EXIT
    listing="$(CLAUDE_PROJECT_DIR="${empty_dir}" bash "$guard" --list 2>/dev/null || true)"
    blocked="$(printf '%s' "$listing" | sed -n '/^blocked:/,/^warned:/p' | grep -c '^  ' || true)"
    # 코어 목록만 12개입니다. 팩이 병합되면 그보다 많아야 합니다.
    if [[ "$blocked" -le 12 ]]; then
      report_fail protection "스택 미감지 상태에서 차단 패턴이 ${blocked}개뿐입니다. 언어별 보호가 감지에 의존하고 있습니다"
    else
      # 대표 패턴 몇 개가 실제로 차단되는지 확인합니다.
      miss=""
      for p in tsconfig.json checkstyle.xml ruff.toml .golangci.yml clippy.toml; do
        c=0
        printf '{"tool_input":{"file_path":"%s"}}' "$p" \
          | CLAUDE_PROJECT_DIR="${empty_dir}" bash "$guard" >/dev/null 2>&1 || c=$?
        [[ "$c" -eq 2 ]] || miss="${miss} ${p}"
      done
      if [[ -n "$miss" ]]; then
        report_fail protection "스택 미감지 상태에서 차단되지 않은 파일:${miss}"
      else
        report_pass protection "보호 패턴 ${blocked}개가 감지와 무관하게 병합됩니다"
      fi
    fi
  fi
fi

# --- 4. links ------------------------------------------------------------------
if selected links; then
  # 기본 대상은 번들입니다. 프로젝트가 자기 문서도 함께 검사하려면
  # harness.config 에서 HARNESS_SELF_CHECK_LINK_DIRS 에 프로젝트 루트 기준 상대 경로를 공백으로 나열합니다.
  # 채택하지 않은 프로젝트의 문서를 임의로 훑으면 의도적인 외부 링크까지 실패로 잡히므로 기본값은 번들뿐입니다.
  link_roots=("${HARNESS_DIR}")
  if [[ -n "${HARNESS_SELF_CHECK_LINK_DIRS:-}" ]]; then
    _proj="${HARNESS_PROJECT_ROOT_RESOLVED}"
    for _d in ${HARNESS_SELF_CHECK_LINK_DIRS}; do
      if [[ -e "${_proj}/${_d}" ]]; then
        link_roots+=("${_proj}/${_d}")
      else
        report_fail links "HARNESS_SELF_CHECK_LINK_DIRS 의 경로가 없습니다: ${_d}"
      fi
    done
  fi
  broken=""
  count=0
  while IFS= read -r f; do
    d="$(dirname "$f")"
    while IFS= read -r link; do
      target="${link%%#*}"
      [[ -n "$target" ]] || continue
      count=$((count + 1))
      [[ -e "${d}/${target}" ]] || broken="${broken}\n    ${f#"${HARNESS_DIR}/"} -> ${link}"
    done < <(grep -oE '\]\([^)]+\)' "$f" | sed -E 's/^\]\((.*)\)$/\1/' | grep -vE '^(http|mailto)' || true)
  done < <(find "${link_roots[@]}" -name '*.md' -type f)
  if [[ -z "$broken" ]]; then
    report_pass links "상대 링크 ${count}건이 전부 실재합니다 (대상 ${#link_roots[@]}곳)"
  else
    report_fail links "끊어진 링크:$(printf '%b' "$broken")"
  fi
fi

# --- 5. log-schema --------------------------------------------------------------
if selected log-schema; then
  examples=()
  while IFS= read -r f; do examples+=("$f"); done < <(
    find "${HARNESS_DIR}" -name '*improvement-log*.yaml' -o -name '*.example.yaml' | sort -u
  )
  if [[ ${#examples[@]} -eq 0 ]]; then
    report_pass log-schema "검사할 예시가 없습니다"
  elif out="$("${SCRIPT_DIR}/improvement-log.sh" validate "${examples[@]}" 2>&1)"; then
    report_pass log-schema "예시 ${#examples[@]}건이 스키마를 만족합니다"
  else
    report_fail log-schema "$(printf '%s' "$out" | tail -n 5)"
  fi
fi

printf '\n'
if [[ "$FAILED" -eq 0 ]]; then
  printf '자기 점검 통과.\n'
  exit 0
fi
printf '자기 점검 실패: %s건.\n' "$FAILED"
printf '하네스가 성립하지 않는 상태입니다. 대상 코드를 고치기 전에 이것부터 해소하십시오.\n'
exit 1
