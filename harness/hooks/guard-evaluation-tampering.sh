#!/usr/bin/env bash
# guard-evaluation-tampering.sh — PreToolUse hook.
# 평가·게이트를 규정하는 파일을 에이전트가 임의로 고치는 것을 차단합니다.
# exit 0: 허용(경고는 stderr) / exit 2: 차단(stderr 사유가 에이전트에게 전달됨)
set -euo pipefail

# ---------------------------------------------------------------------------
# 코어 보호 목록. 언어에 고정되지 않은 하네스 자체의 파일만 담습니다.
# 언어별 목록(eslint, tsconfig, checkstyle, ruff …)은 harness/language/<언어>/lang.sh 가 소유하며,
# **감지 결과와 무관하게 모든 팩의 목록이 합쳐집니다**(아래 "언어 팩 패턴 병합" 참조).
# 프로젝트 고유 추가분은 이 배열에 적습니다.
#
# 패턴 규칙:
#   - '/' 가 없는 패턴은 경로 전체와 파일명 양쪽에 대해 검사합니다.
#   - '/' 가 있는 패턴은 경로 전체와 **하위 경로 접미사** 양쪽에 대해 검사합니다.
#     (하네스를 tools/harness/ 로 벤더링하거나 monorepo 하위 패키지를 편집할 때도 걸립니다)
# ---------------------------------------------------------------------------

# 차단 대상: 이 파일들이 바뀌면 평가 결과의 의미가 달라집니다.
HARNESS_PROTECTED_PATTERNS=(
  "harness.config"
  "harness.config.local"
  "harness/evaluation/*"
  # 프로젝트가 실체화한 평가 세트. 번들 템플릿과 같은 이유로 에이전트의 자가 수정 대상이 아닙니다.
  "evaluation/*"
  "harness/rules/*"
  "harness/hooks/*"
  # scripts/ 전체를 봅니다. 개별 파일을 열거하면 새 스크립트가 목록에 빠진 채
  # 게이트를 지탱하게 됩니다. 실제로 improvement-log.sh 와 loop.sh 가 그 상태였습니다.
  # improvement-log.sh 는 필수 단계 log-schema 의 판정을 전부 수행하고,
  # loop.sh 는 반복 예산과 보안 에스컬레이션 패턴을 소유합니다. 둘 다 고치면 게이트가 무력해집니다.
  "harness/scripts/*.sh"
  "harness/scripts/lib/*"
  "harness/language/*/lang.sh"
  ".harness/latest-eval.json"
  ".harness/verify.json"
)

# 경고 대상: 차단하지는 않지만 평가에 영향을 줄 수 있어 사실을 알립니다.
HARNESS_WARN_PATTERNS=(
  ".github/workflows/*"
  ".gitlab-ci.yml"
  "sonar-project.properties"
  "codecov.yml"
  "improvement-log/*"
)

# ---------------------------------------------------------------------------

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
HARNESS_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
COMMON_LIB="${HARNESS_DIR}/scripts/lib/common.sh"
DETECT_LIB="${HARNESS_DIR}/scripts/lib/detect-stack.sh"

emit() { printf '%s\n' "$*" >&2; }

usage() {
  cat <<'USAGE'
사용법: guard-evaluation-tampering.sh [--help] [--list]

Claude Code 의 PreToolUse hook 으로 등록해 사용합니다. hook JSON 을 stdin 으로 받고
tool_input.file_path 를 보호 목록과 대조합니다.

보호 목록 = 코어 목록(이 스크립트 상단) + **로드된 모든** 언어 팩의 목록.
언어 팩 목록은 스택 감지 결과에 의존하지 않습니다. 감지에 의존하면 스택 미감지 저장소,
monorepo, kind 오판정에서 다른 언어의 평가 설정 파일이 조용히 무방비가 되기 때문입니다.
팩 패턴 이름은 언어 간에 겹치지 않으므로 합집합의 오탐 비용은 없습니다.

동작:
  - 차단 대상과 일치하면 exit 2 로 도구 호출을 막고 사유를 stderr 에 출력합니다.
  - 경고 대상과 일치하면 exit 0 으로 허용하되 stderr 에 경고를 남깁니다.
  - 어느 목록에도 없으면 아무것도 출력하지 않고 exit 0 합니다.
  - 팩을 하나도 로드하지 못했거나 팩이 계약을 어기면 그 사실을 stderr 에 남깁니다.
    보호 목록이 줄어든 상태를 조용히 통과시키지 않습니다.

옵션:
  --list   합쳐진 보호 목록과 감지된 스택·kind 를 출력합니다.

환경 변수:
  HARNESS_ALLOW_GUARDED_EDIT=1   차단을 1회 우회합니다. 사람 승인이나 harness-promote
                                 절차를 거친 변경에만 사용합니다.
  CLAUDE_PROJECT_DIR             프로젝트 루트. 없으면 스스로 탐색합니다.

이 hook 은 프로젝트의 harness.config 를 읽지 않습니다. 그 파일은 bash 이므로 읽으면
가드 프로세스 안에서 임의 명령이 실행되고, 한 줄로 가드를 무력화할 수 있기 때문입니다.
USAGE
}

MODE="hook"
case "${1:-}" in
  --help|-h)
    usage
    exit 0
    ;;
  --list)
    MODE="list"
    ;;
esac

if [[ -f "${COMMON_LIB}" ]]; then
  # shellcheck source=../scripts/lib/common.sh
  source "${COMMON_LIB}" || true
fi

fallback_find_project_root() {
  local dir="${1:-${PWD}}"
  while [[ "${dir}" != "/" && -n "${dir}" ]]; do
    if [[ -e "${dir}/.git" || -f "${dir}/harness.config" || -d "${dir}/harness" ]]; then
      printf '%s\n' "${dir}"
      return 0
    fi
    dir="$(dirname -- "${dir}")"
  done
  printf '%s\n' "${1:-${PWD}}"
  return 0
}

resolve_project_root() {
  if [[ -n "${CLAUDE_PROJECT_DIR:-}" && -d "${CLAUDE_PROJECT_DIR}" ]]; then
    printf '%s\n' "${CLAUDE_PROJECT_DIR}"
    return 0
  fi
  if declare -F find_project_root >/dev/null 2>&1; then
    local root=""
    root="$(find_project_root 2>/dev/null || true)"
    if [[ -n "${root}" && -d "${root}" ]]; then
      printf '%s\n' "${root}"
      return 0
    fi
  fi
  fallback_find_project_root "$(cd -- "${HARNESS_DIR}/.." && pwd)"
}

PROJECT_ROOT="$(resolve_project_root)"

# --- 언어 팩 패턴 병합 --------------------------------------------------------------
# 감지를 하지 않고 로드된 모든 팩의 패턴을 합칩니다. 감지는 --list 표시용으로만 뒤에서 수행합니다.
# 팩은 이 프로세스에서 한 번만 로드하므로, 아래 프로세스 치환은 이미 로드된 함수와 배열을 물려받습니다.
LANG_STATUS="언어 팩 없음 (코어 목록만 적용)"
LANG_LOADED=0
if [[ -f "${DETECT_LIB}" ]]; then
  # shellcheck source=../scripts/lib/detect-stack.sh
  if source "${DETECT_LIB}" 2>/dev/null && declare -F harness_lang_load_packs >/dev/null 2>&1; then
    harness_lang_load_packs || true
    _pack_count=0
    if declare -p HARNESS_LANG_PACKS >/dev/null 2>&1; then
      _pack_count="${#HARNESS_LANG_PACKS[@]}"
    fi
    if [[ "${_pack_count}" -gt 0 ]]; then
      LANG_LOADED=1
      LANG_STATUS="팩 ${_pack_count}개 병합: ${HARNESS_LANG_PACKS[*]}"
      while IFS= read -r _p; do
        [[ -n "${_p}" ]] && HARNESS_PROTECTED_PATTERNS+=("${_p}")
      done < <(lang_all_protected_patterns 2>/dev/null || true)
      while IFS= read -r _p; do
        [[ -n "${_p}" ]] && HARNESS_WARN_PATTERNS+=("${_p}")
      done < <(lang_all_warn_patterns 2>/dev/null || true)
    else
      emit "[harness] 경고: 언어 팩을 하나도 로드하지 못했습니다. 언어별 평가 설정 파일(lint·타입·테스트 러너·아키텍처 규칙)이 보호되지 않습니다."
      emit "  확인: ./harness/hooks/guard-evaluation-tampering.sh --list"
    fi
  else
    emit "[harness] 경고: ${DETECT_LIB} 를 로드하지 못했습니다. 코어 목록만 적용합니다."
  fi
else
  emit "[harness] 경고: ${DETECT_LIB} 가 없습니다. 코어 목록만 적용합니다."
fi

if [[ "${HARNESS_LANG_PACK_PROBLEMS:-0}" -gt 0 ]]; then
  emit "[harness] 경고: 계약을 어긴 언어 팩 ${HARNESS_LANG_PACK_PROBLEMS}개를 비활성화했습니다. 그 언어의 보호 패턴이 적용되지 않습니다."
fi

if [[ "${MODE}" == "list" ]]; then
  _stack="(미측정)"; _kind="(미측정)"
  if [[ "${LANG_LOADED}" -eq 1 ]]; then
    _stack="$(detect_stack "${PROJECT_ROOT}" 2>/dev/null || true)"
    _kind="$(detect_kind "${PROJECT_ROOT}" "${_stack}" 2>/dev/null || true)"
  fi
  printf 'project_root: %s\n' "${PROJECT_ROOT}"
  printf 'language_packs: %s\n' "${LANG_STATUS}"
  printf 'detected_stack: %s (kind: %s)  ← 기본 verify 단계 선택용. 보호 목록에는 영향을 주지 않습니다.\n' \
    "${_stack:-unknown}" "${_kind:-unknown}"
  printf 'blocked:\n'
  printf '  %s\n' ${HARNESS_PROTECTED_PATTERNS[@]+"${HARNESS_PROTECTED_PATTERNS[@]}"}
  printf 'warned:\n'
  printf '  %s\n' ${HARNESS_WARN_PATTERNS[@]+"${HARNESS_WARN_PATTERNS[@]}"}
  exit 0
fi

read_stdin_payload() {
  if [[ -t 0 ]]; then
    printf '%s' ""
  else
    cat || true
  fi
}

# json_field <payload> <jq-path> <grep-key> — 문자열 값을 출력합니다.
json_field() {
  local payload="$1" jq_path="$2" grep_key="$3" value=""
  if command -v jq >/dev/null 2>&1; then
    value="$(printf '%s' "${payload}" | jq -r "${jq_path} // empty" 2>/dev/null || true)"
  fi
  if [[ -z "${value}" ]]; then
    value="$(printf '%s' "${payload}" \
      | grep -oE "\"${grep_key}\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" \
      | head -n 1 \
      | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/' || true)"
  fi
  printf '%s' "${value}"
}

# to_relative <project_root> <path>
# Windows 절대 경로는 역슬래시로 들어옵니다. 정규화하지 않으면 '/' 를 포함한 패턴이 전부 빗나갑니다.
to_relative() {
  local root="$1" path="$2" lroot lpath
  root="${root//\\//}"
  path="${path//\\//}"
  root="${root%/}"
  path="${path#./}"
  if [[ "${path}" == "${root}/"* ]]; then
    printf '%s' "${path#"${root}/"}"
    return 0
  fi
  # Windows 는 드라이브 문자 대소문자가 다를 수 있습니다. hook 은 매 편집마다 도므로 내장만 씁니다.
  lroot="${root,,}"
  lpath="${path,,}"
  if [[ "${lpath}" == "${lroot}/"* ]]; then
    printf '%s' "${path:$((${#root} + 1))}"
    return 0
  fi
  printf '%s' "${path}"
}

# matches_any <rel> <base> <pattern...>
matches_any() {
  local rel="$1" base="$2" pat=""
  shift 2
  for pat in "$@"; do
    # shellcheck disable=SC2053
    if [[ "${rel}" == ${pat} ]]; then
      printf '%s' "${pat}"
      return 0
    fi
    if [[ "${pat}" == */* ]]; then
      # 경로를 포함한 패턴은 하위 경로에서도 일치시킵니다.
      # 이것이 없으면 하네스를 tools/harness/ 로 벤더링했을 때 가드가 자기 자신을 지키지 못하고,
      # monorepo 하위 패키지의 평가 설정도 빗나갑니다.
      # shellcheck disable=SC2053
      if [[ "${rel}" == */${pat} ]]; then
        printf '%s' "${pat}"
        return 0
      fi
    else
      # shellcheck disable=SC2053
      if [[ "${base}" == ${pat} ]]; then
        printf '%s' "${pat}"
        return 0
      fi
    fi
  done
  return 1
}

PAYLOAD="$(read_stdin_payload)"
FILE_PATH="$(json_field "${PAYLOAD}" '.tool_input.file_path' 'file_path')"
if [[ -z "${FILE_PATH}" ]]; then
  FILE_PATH="$(json_field "${PAYLOAD}" '.tool_input.notebook_path' 'notebook_path')"
fi

# 파일 경로가 없는 도구 호출은 이 hook 의 관심사가 아닙니다.
if [[ -z "${FILE_PATH}" ]]; then
  exit 0
fi

REL_PATH="$(to_relative "${PROJECT_ROOT}" "${FILE_PATH}")"
BASE_NAME="${REL_PATH##*/}"

MATCHED=""
if MATCHED="$(matches_any "${REL_PATH}" "${BASE_NAME}" ${HARNESS_PROTECTED_PATTERNS[@]+"${HARNESS_PROTECTED_PATTERNS[@]}"})"; then
  if [[ "${HARNESS_ALLOW_GUARDED_EDIT:-}" == "1" ]]; then
    emit "[harness] HARNESS_ALLOW_GUARDED_EDIT=1 로 보호 파일 변경을 허용했습니다: ${REL_PATH} (패턴 ${MATCHED})"
    emit "이 변경은 사람 승인 또는 harness-promote 절차의 기록으로 남겨야 합니다."
    exit 0
  fi
  emit "[harness] 변경을 차단했습니다: ${REL_PATH}"
  emit "이 경로는 평가·게이트를 규정하는 보호 대상입니다(일치 패턴: ${MATCHED})."
  emit "평가 기준을 스스로 고쳐 통과시키는 것은 개선이 아니라 평가 조작입니다."
  emit "다음 조치:"
  emit "  1. 이번 실패는 대상 코드에서 고칩니다."
  emit "  2. 기준 자체가 잘못되었다고 판단하면 improvement candidate 를 남깁니다(harness/subagents/harness-reviewer.md)."
  emit "  3. 기준 변경은 harness-promote 절차와 사람 검토를 거쳐 적용합니다."
  emit "  4. 승인된 변경이라면 HARNESS_ALLOW_GUARDED_EDIT=1 을 붙여 다시 실행합니다."
  exit 2
fi

if MATCHED="$(matches_any "${REL_PATH}" "${BASE_NAME}" ${HARNESS_WARN_PATTERNS[@]+"${HARNESS_WARN_PATTERNS[@]}"})"; then
  emit "[harness] 경고: ${REL_PATH} 는 평가 결과에 영향을 줄 수 있는 파일입니다(일치 패턴: ${MATCHED})."
  emit "검증 명령, 임계값, 테스트 범위를 약화시키는 변경인지 확인하고, 그렇다면 되돌립니다."
  exit 0
fi

exit 0
