#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")" && pwd)

source "$ROOT_DIR/lib/utils.sh"
source "$ROOT_DIR/lib/config.sh"
source "$ROOT_DIR/lib/plan.sh"
source "$ROOT_DIR/lib/steps.sh"

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
