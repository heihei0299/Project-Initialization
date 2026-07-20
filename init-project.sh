#!/usr/bin/env bash
set -euo pipefail

if ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
  echo "错误：需要 bash 4.3 或更高版本（nameref 支持）" >&2
  exit 1
fi

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

source "$ROOT_DIR/lib/utils.sh"
source "$ROOT_DIR/lib/config.sh"
source "$ROOT_DIR/lib/plan.sh"
source "$ROOT_DIR/lib/steps.sh"

# shellcheck disable=SC2034 # PLAN is used via nameref in collect_plan and step functions
declare -A PLAN

collect_plan || exit

# ── Seam: execution ──

step1_git_init
echo ""
step2_templates PLAN
echo ""
step3_skills PLAN
echo ""
step4_aliases PLAN
echo ""
step5_codegraph
echo ""

print_plan_summary PLAN
