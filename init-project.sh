#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/config.sh"
source "$SCRIPT_DIR/lib/plan.sh"
source "$SCRIPT_DIR/lib/steps.sh"

declare -A PLAN

collect_plan

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

print_plan_summary
