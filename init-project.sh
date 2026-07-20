#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/plan.sh"
source "$SCRIPT_DIR/lib/steps.sh"

declare -A PLAN

collect_plan

# ── Seam: execution ──

step1_git_init
echo ""
step2_gitignore
echo ""
step3_templates PLAN
echo ""
step4_skills PLAN
echo ""
step5_aliases PLAN
echo ""
step6_codegraph
echo ""

print_plan_summary
