#!/usr/bin/env bash
# eval.sh — verify 결과를 6개 평가 계층으로 집계해 가중 점수를 냅니다.
# 결과는 .harness/latest-eval.json (사양 6.4) 에 기록합니다.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck disable=SC1090,SC1091
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
사용법: eval.sh [옵션]

verify.sh 를 실행하고 그 결과를 correctness, architecture, quality, behavior,
performance, subjective 6개 계층으로 집계해 .harness/latest-eval.json 을 씁니다.

옵션:
  --reuse              verify.sh 를 다시 실행하지 않고 기존 .harness/verify.json 을 씁니다.
  --threshold <N>      합격선을 재정의합니다. 기본값은 harness.config 의 HARNESS_THRESHOLD 입니다.
  --json               사람용 출력을 억제하고 결과 JSON 만 표준출력으로 냅니다.
  -h, --help           이 도움말을 출력합니다.

점수 계산:
  계층 점수 = (그 계층의 통과 단계 수 / 그 계층의 단계 수) * 100
  단계가 하나도 없는 계층은 score 가 null 이고, 그 가중치는 나머지 계층에 비례 재분배합니다.
  최종 score 는 계층 점수의 가중 평균을 반올림한 0~100 정수입니다.

종료 코드:
  0  계산에 성공했습니다. (합격 여부는 pass 필드와 pass-threshold.sh 로 판정합니다)
  2  --reuse 인데 .harness/verify.json 이 없습니다.
  3  집계할 단계가 없습니다.
USAGE
}

OPT_REUSE=0
OPT_JSON=0
OPT_THRESHOLD=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --reuse) OPT_REUSE=1; shift ;;
    --json) OPT_JSON=1; shift ;;
    --threshold)
      [[ $# -ge 2 ]] || die "--threshold 에는 숫자가 필요합니다." 3
      OPT_THRESHOLD="$2"; shift 2 ;;
    --threshold=*) OPT_THRESHOLD="${1#*=}"; shift ;;
    *) die "알 수 없는 옵션입니다: $1 (--help 를 보십시오)" 3 ;;
  esac
done

say() { [[ "$OPT_JSON" -eq 1 ]] || printf '%s\n' "$*"; }

ROOT="$(find_project_root "$PWD")"
cd "$ROOT"
load_config "$ROOT"

VERIFY_FILE="${ROOT}/${HARNESS_VERIFY_JSON}"

if [[ "$OPT_REUSE" -eq 1 ]]; then
  [[ -f "$VERIFY_FILE" ]] || die "재사용할 ${HARNESS_VERIFY_JSON} 이 없습니다. --reuse 없이 다시 실행하십시오." 2
  say "기존 ${HARNESS_VERIFY_JSON} 을 재사용합니다."
else
  say "verify.sh 를 실행합니다."
  if [[ "$OPT_JSON" -eq 1 ]]; then
    "${SCRIPT_DIR}/verify.sh" >/dev/null 2>&1 || true
  else
    "${SCRIPT_DIR}/verify.sh" || true
  fi
  [[ -f "$VERIFY_FILE" ]] || die "verify.sh 가 ${HARNESS_VERIFY_JSON} 을 만들지 못했습니다." 3
fi

# --- verify.json 의 단계 읽기 ---------------------------------------------------
STEP_IDS=(); STEP_LAYERS=(); STEP_STATUS=(); STEP_LOGS=()
while IFS= read -r line; do
  [[ "$line" == *'"id":'* ]] || continue
  sid="$(json_str_field "$line" id)"
  slayer="$(json_str_field "$line" layer)"
  sstatus="$(json_str_field "$line" status)"
  slog="$(json_str_field "$line" log)"
  [[ -n "$sid" && -n "$slayer" ]] || continue
  STEP_IDS+=("$sid"); STEP_LAYERS+=("$slayer"); STEP_STATUS+=("$sstatus"); STEP_LOGS+=("$slog")
done < "$VERIFY_FILE"

STEP_COUNT=${#STEP_IDS[@]}
if [[ "$STEP_COUNT" -eq 0 ]]; then
  log_error "집계할 단계가 없습니다. verify.sh 가 단계를 하나도 실행하지 못했습니다."
  log_error "harness.config 의 HARNESS_STEPS 를 정의하거나 감지 가능한 스택에서 실행하십시오."
  exit 3
fi

# --- 가중치 ---------------------------------------------------------------------
# weight_to_milli <십진수> — 0.30 → 300 (정수 산술을 위해 1000배 합니다)
weight_to_milli() {
  local w="${1:-0}" int frac
  w="${w#+}"
  if [[ "$w" == *.* ]]; then
    int="${w%%.*}"; frac="${w#*.}"
  else
    int="$w"; frac=""
  fi
  [[ "$int" =~ ^[0-9]+$ ]] || int=0
  frac="${frac//[^0-9]/}"
  frac="${frac}000"; frac="${frac:0:3}"
  printf '%s' "$(( 10#$int * 1000 + 10#$frac ))"
}

milli_to_weight() {
  local m="$1"
  if [[ $((m % 10)) -eq 0 ]]; then
    printf '%d.%02d' "$((m / 1000))" "$(((m % 1000) / 10))"
  else
    printf '%d.%03d' "$((m / 1000))" "$((m % 1000))"
  fi
}

declare -A W_MILLI=(
  [correctness]=300 [architecture]=200 [quality]=200
  [behavior]=150 [performance]=100 [subjective]=50
)
WEIGHT_SOURCE="기본값"
_weight_count=0
if declare -p HARNESS_EVAL_WEIGHTS >/dev/null 2>&1; then
  _weight_count=${#HARNESS_EVAL_WEIGHTS[@]}
fi
if [[ "$_weight_count" -gt 0 ]]; then
  for entry in "${HARNESS_EVAL_WEIGHTS[@]}"; do
    [[ -z "$entry" ]] && continue
    IFS='|' read -r wlayer wvalue <<<"$entry"
    wlayer="${wlayer//[[:space:]]/}"
    wvalue="${wvalue//[[:space:]]/}"
    harness_layer_is_valid "$wlayer" || die "HARNESS_EVAL_WEIGHTS 에 알 수 없는 layer 가 있습니다: ${wlayer}" 3
    W_MILLI["$wlayer"]="$(weight_to_milli "$wvalue")"
  done
  WEIGHT_SOURCE="harness.config"
fi

# --- 계층 집계 -------------------------------------------------------------------
declare -A L_TOTAL L_PASS L_EVIDENCE L_FAILED
for layer in "${HARNESS_LAYERS[@]}"; do
  L_TOTAL["$layer"]=0; L_PASS["$layer"]=0; L_EVIDENCE["$layer"]=""; L_FAILED["$layer"]=""
done

for ((i = 0; i < STEP_COUNT; i++)); do
  layer="${STEP_LAYERS[$i]}"
  harness_layer_is_valid "$layer" || continue
  L_TOTAL["$layer"]=$(( L_TOTAL["$layer"] + 1 ))
  if [[ "${STEP_STATUS[$i]}" == "pass" ]]; then
    L_PASS["$layer"]=$(( L_PASS["$layer"] + 1 ))
    [[ -n "${L_EVIDENCE[$layer]}" ]] || L_EVIDENCE["$layer"]="${STEP_LOGS[$i]}"
  else
    L_FAILED["$layer"]="${L_FAILED[$layer]}${STEP_IDS[$i]} "
    [[ -n "${STEP_LOGS[$i]}" ]] && L_EVIDENCE["$layer"]="${STEP_LOGS[$i]}"
  fi
done

# 점수가 있는 계층의 원래 가중치 합을 구해 재분배 분모로 씁니다.
ACTIVE_MILLI=0
for layer in "${HARNESS_LAYERS[@]}"; do
  [[ "${L_TOTAL[$layer]}" -gt 0 ]] || continue
  ACTIVE_MILLI=$(( ACTIVE_MILLI + W_MILLI[$layer] ))
done
[[ "$ACTIVE_MILLI" -gt 0 ]] || die "가중치 합이 0 입니다. HARNESS_EVAL_WEIGHTS 를 확인하십시오." 3

WEIGHTED_SUM=0
LAYERS_JSON=""
LARGEST_LAYER=""
LARGEST_DEFICIT=-1
for layer in "${HARNESS_LAYERS[@]}"; do
  total="${L_TOTAL[$layer]}"
  base_milli="${W_MILLI[$layer]}"
  if [[ "$total" -gt 0 ]]; then
    eff_milli=$(( base_milli * 1000 / ACTIVE_MILLI ))
    score=$(( (L_PASS[$layer] * 100 * 2 + total) / (total * 2) ))
    WEIGHTED_SUM=$(( WEIGHTED_SUM + eff_milli * score ))
    score_json="$score"
    notes="${L_PASS[$layer]}/${total} 단계 통과"
    deficit=$(( eff_milli * (100 - score) ))
    if [[ "$deficit" -gt 0 && "$deficit" -gt "$LARGEST_DEFICIT" ]]; then
      LARGEST_DEFICIT="$deficit"; LARGEST_LAYER="$layer"
    fi
  else
    eff_milli=0
    score_json="null"
    notes="단계 없음: 가중치를 다른 계층에 재분배했습니다"
  fi
  if [[ "$layer" == "subjective" ]]; then deterministic="false"; else deterministic="true"; fi
  [[ -n "$LAYERS_JSON" ]] && LAYERS_JSON="${LAYERS_JSON},"$'\n'
  LAYERS_JSON="${LAYERS_JSON}    {\"layer\": \"${layer}\", \"weight\": $(milli_to_weight "$eff_milli"), \"score\": ${score_json}, \"deterministic\": ${deterministic}, \"evidence\": \"$(json_escape "${L_EVIDENCE[$layer]}")\", \"notes\": \"$(json_escape "$notes")\"}"
done
[[ -n "$LAYERS_JSON" ]] && LAYERS_JSON="${LAYERS_JSON}"$'\n'

SCORE=$(( (WEIGHTED_SUM + 500) / 1000 ))
[[ "$SCORE" -le 100 ]] || SCORE=100
[[ "$SCORE" -ge 0 ]] || SCORE=0

THRESHOLD="${OPT_THRESHOLD:-${HARNESS_THRESHOLD:-80}}"
[[ "$THRESHOLD" =~ ^[0-9]+$ ]] || die "threshold 가 정수가 아닙니다: ${THRESHOLD}" 3

if [[ "$SCORE" -ge "$THRESHOLD" ]]; then PASS="true"; else PASS="false"; fi

if [[ -n "$LARGEST_LAYER" ]]; then
  failed_list="${L_FAILED[$LARGEST_LAYER]}"
  failed_list="${failed_list% }"
  [[ -n "$failed_list" ]] || failed_list="(실패 단계 없음)"
  LARGEST_JSON="{\"layer\": \"${LARGEST_LAYER}\", \"detail\": \"$(json_escape "가중치 결손이 가장 큰 계층입니다. 실패 단계: ${failed_list}. 증거 로그: ${L_EVIDENCE[$LARGEST_LAYER]}")\"}"
else
  LARGEST_JSON="null"
fi

{
  printf '{\n'
  printf '  "schema": "harness.eval/1",\n'
  printf '  "layers": [\n'
  printf '%s' "$LAYERS_JSON"
  printf '  ],\n'
  printf '  "score": %s,\n' "$SCORE"
  printf '  "threshold": %s,\n' "$THRESHOLD"
  printf '  "pass": %s,\n' "$PASS"
  printf '  "largest_failure": %s\n' "$LARGEST_JSON"
  printf '}\n'
} > "${ROOT}/${HARNESS_EVAL_JSON}"

if [[ "$OPT_JSON" -eq 1 ]]; then
  cat "${ROOT}/${HARNESS_EVAL_JSON}"
  exit 0
fi

say ""
say "가중치 출처: ${WEIGHT_SOURCE}"
say "| layer | weight | score | 비고 |"
say "| --- | --- | --- | --- |"
for layer in "${HARNESS_LAYERS[@]}"; do
  total="${L_TOTAL[$layer]}"
  if [[ "$total" -gt 0 ]]; then
    eff_milli=$(( W_MILLI[$layer] * 1000 / ACTIVE_MILLI ))
    score=$(( (L_PASS[$layer] * 100 * 2 + total) / (total * 2) ))
    say "| ${layer} | $(milli_to_weight "$eff_milli") | ${score} | ${L_PASS[$layer]}/${total} 단계 통과 |"
  else
    say "| ${layer} | 0.00 | null | 단계 없음 (가중치 재분배) |"
  fi
done
say ""
say "총점: ${SCORE} / 합격선: ${THRESHOLD} / 합격 여부: ${PASS}"
if [[ -n "$LARGEST_LAYER" ]]; then
  say "가장 큰 실패 계층: ${LARGEST_LAYER} (실패 단계: ${L_FAILED[$LARGEST_LAYER]:-없음})"
fi
say "결과 파일: ${HARNESS_EVAL_JSON}"
exit 0
