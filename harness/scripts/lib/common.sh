#!/usr/bin/env bash
# harness 공통 함수 라이브러리입니다. 직접 실행하지 않고 source 해서 사용합니다.
# 제공 함수: log_info log_warn log_error die json_escape require_cmd have_cmd
#            find_project_root now_ms load_config
set -euo pipefail

if [[ -n "${HARNESS_COMMON_SH_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
HARNESS_COMMON_SH_LOADED=1

# --- 경로 상수 ---------------------------------------------------------------
HARNESS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
HARNESS_SCRIPTS_DIR="$(cd "${HARNESS_LIB_DIR}/.." && pwd -P)"
HARNESS_DIR="$(cd "${HARNESS_SCRIPTS_DIR}/.." && pwd -P)"
HARNESS_PARENT_DIR="$(cd "${HARNESS_DIR}/.." && pwd -P)"
export HARNESS_LIB_DIR HARNESS_SCRIPTS_DIR HARNESS_DIR HARNESS_PARENT_DIR

# 런타임 산출 경로 (정본: README.md 의 "런타임 산출 경로"). 프로젝트 루트 기준 상대 경로입니다.
HARNESS_STATE_DIR=".harness"
HARNESS_LOG_DIR=".harness/logs"
HARNESS_VERIFY_JSON=".harness/verify.json"
HARNESS_EVAL_JSON=".harness/latest-eval.json"
HARNESS_LOOP_JSON=".harness/loop-state.json"
HARNESS_IMPROVEMENT_DIR="improvement-log"

# 평가 계층 (6종 고정. 정본: references/evaluation-layers.md)
HARNESS_LAYERS=(correctness architecture quality behavior performance subjective)

# --- 색상 --------------------------------------------------------------------
# 색상은 stderr 가 TTY 이고 NO_COLOR 가 없을 때만 사용합니다.
if [[ -t 2 && -z "${NO_COLOR:-}" ]]; then
  HARNESS_C_RESET=$'\033[0m'
  HARNESS_C_DIM=$'\033[2m'
  HARNESS_C_RED=$'\033[31m'
  HARNESS_C_GREEN=$'\033[32m'
  HARNESS_C_YELLOW=$'\033[33m'
else
  HARNESS_C_RESET=''
  HARNESS_C_DIM=''
  HARNESS_C_RED=''
  HARNESS_C_GREEN=''
  HARNESS_C_YELLOW=''
fi

# --- 로그 --------------------------------------------------------------------
log_info() { printf '%s[info]%s %s\n' "${HARNESS_C_DIM}" "${HARNESS_C_RESET}" "$*" >&2; }
log_warn() { printf '%s[warn]%s %s\n' "${HARNESS_C_YELLOW}" "${HARNESS_C_RESET}" "$*" >&2; }
log_error() { printf '%s[error]%s %s\n' "${HARNESS_C_RED}" "${HARNESS_C_RESET}" "$*" >&2; }
log_ok() { printf '%s[ok]%s %s\n' "${HARNESS_C_GREEN}" "${HARNESS_C_RESET}" "$*" >&2; }

# die <메시지> [종료코드]
die() {
  local msg="${1:-실패했습니다.}"
  local code="${2:-1}"
  log_error "$msg"
  exit "$code"
}

# --- 명령 존재 확인 -----------------------------------------------------------
have_cmd() { command -v "$1" >/dev/null 2>&1; }

require_cmd() {
  local cmd
  for cmd in "$@"; do
    have_cmd "$cmd" || die "필수 명령을 찾을 수 없습니다: ${cmd}" 3
  done
}

# --- JSON ---------------------------------------------------------------------
# json_escape <문자열> — JSON 문자열 리터럴 내부에 넣을 수 있게 이스케이프합니다.
json_escape() {
  local s="${1-}"
  s="${s//\\/\\\\}"
  s="${s//\"/\\\"}"
  s="${s//$'\n'/\\n}"
  s="${s//$'\r'/\\r}"
  s="${s//$'\t'/\\t}"
  s="$(printf '%s' "$s" | tr -d '\000-\010\013\014\016-\037')"
  printf '%s' "$s"
}

# json_str_field <json-조각> <키> — 문자열 값을 꺼냅니다. 없으면 빈 문자열입니다.
# 파이프 조기 종료(SIGPIPE)로 pipefail 이 걸리지 않도록 변수로 받아 첫 줄만 씁니다.
json_str_field() {
  local out
  out="$(printf '%s' "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p")"
  printf '%s' "${out%%$'\n'*}"
}

# json_num_field <json-조각> <키> — 숫자/불리언/null 값을 꺼냅니다.
json_num_field() {
  local out
  out="$(printf '%s' "$1" | sed -n "s/.*\"$2\"[[:space:]]*:[[:space:]]*\([-0-9.a-z]*\).*/\1/p")"
  printf '%s' "${out%%$'\n'*}"
}

# --- 프로젝트 루트 -------------------------------------------------------------
# find_project_root [시작경로]
# .git 또는 harness.config 를 위로 탐색합니다. 어느 것도 없으면 harness/ 의 부모를 씁니다.
find_project_root() {
  if [[ -n "${HARNESS_PROJECT_ROOT:-}" ]]; then
    printf '%s\n' "${HARNESS_PROJECT_ROOT}"
    return 0
  fi
  local start="${1:-$PWD}"
  local dir
  dir="$(cd "$start" 2>/dev/null && pwd -P)" || dir="$PWD"
  while [[ -n "$dir" && "$dir" != "/" ]]; do
    if [[ -f "$dir/harness.config" || -e "$dir/.git" ]]; then
      printf '%s\n' "$dir"
      return 0
    fi
    dir="$(dirname "$dir")"
  done
  printf '%s\n' "${HARNESS_PARENT_DIR}"
}

# --- 시간 ---------------------------------------------------------------------
# now_ms — 밀리초 epoch. date +%s%3N 이 없는 환경에서는 초 단위로 폴백합니다.
now_ms() {
  local t
  t="$(date +%s%3N 2>/dev/null || true)"
  if [[ "$t" =~ ^[0-9]+$ ]]; then
    printf '%s' "$t"
  else
    printf '%s' "$(( $(date +%s) * 1000 ))"
  fi
}

now_iso() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# harness_tree_fingerprint <프로젝트루트> — HEAD 와 더티 목록의 해시입니다.
#
# verify 결과가 "지금 이 트리"의 것인지 판정하는 데 씁니다. 시각만으로는 검증한 뒤
# 파일을 고치고 종료하는 경우를 잡을 수 없고, 시각이 없으면 며칠 지난 pass 가
# 오늘의 종료를 통과시킵니다. 두 값을 함께 기록해야 게이트가 성립합니다.
# git 저장소가 아니거나 해시 도구가 없으면 빈 문자열을 냅니다. 그 환경에서는
# 신선도를 판정하지 않습니다(판정할 근거가 없는 것을 통과로도 실패로도 쓰지 않습니다).
harness_tree_fingerprint() {
  local root="${1:-$PWD}" hasher="" h=""
  git -C "$root" rev-parse --is-inside-work-tree >/dev/null 2>&1 || return 0
  for h in sha1sum shasum md5sum cksum; do
    if command -v "$h" >/dev/null 2>&1; then hasher="$h"; break; fi
  done
  [[ -n "$hasher" ]] || return 0
  {
    git -C "$root" rev-parse HEAD 2>/dev/null || printf 'no-head\n'
    git -C "$root" status --porcelain 2>/dev/null || true
  } | "$hasher" | awk '{print $1}'
}

# --- 설정 ---------------------------------------------------------------------
# load_config [프로젝트루트] — 루트에 harness.config 가 있으면 source 합니다.
# 로드한 파일 경로는 HARNESS_CONFIG_FILE 에 담기고, 없으면 빈 문자열입니다.
load_config() {
  local root="${1:-}"
  [[ -n "$root" ]] || root="$(find_project_root)"
  HARNESS_CONFIG_FILE=""
  if [[ -f "$root/harness.config" ]]; then
    # shellcheck disable=SC1090,SC1091
    source "$root/harness.config"
    HARNESS_CONFIG_FILE="$root/harness.config"
  fi
  export HARNESS_CONFIG_FILE
}

# harness_ensure_state_dir <프로젝트루트> — .harness/ 와 .harness/logs/ 를 만듭니다.
harness_ensure_state_dir() {
  local root="${1:-$PWD}"
  mkdir -p "$root/$HARNESS_LOG_DIR"
}

# harness_layer_is_valid <layer>
harness_layer_is_valid() {
  local l
  for l in "${HARNESS_LAYERS[@]}"; do
    [[ "$l" == "$1" ]] && return 0
  done
  return 1
}

# harness_slug <문자열> — 파일명으로 쓸 수 있게 정규화합니다.
harness_slug() {
  printf '%s' "$1" | tr '/:[:space:]' '---' | tr -cd '[:alnum:]._-'
}
