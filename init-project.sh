#!/usr/bin/env bash
set -euo pipefail

# init-project.sh — 项目初始化脚本
# 入口检测 → 选择工具 → 选择技能组 → 条件执行
# Templates live in templates/ — edit those, not the heredocs.

CURRENT_DIR=$(pwd)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

# ── 辅助函数 ──

ensure_file() {
  local path="$1" src="$2" label="${3:-$path}"
  if [ -f "$path" ]; then
    echo "  ✔ $label 已存在，跳过"
  else
    cp "$src" "$path"
    echo "  ✔ $label 已写入"
  fi
}

ensure_dir() {
  local path="$1" label="${2:-$path}"
  if [ -d "$path" ]; then
    echo "  ✔ $label/ 已存在，跳过"
  else
    mkdir -p "$path"
    echo "  ✔ $label/ 已创建"
  fi
}

yes_no() {
  local prompt="$1" default="${2:-Y}"
  while true; do
    read -r -p "$prompt [$default] " response
    case "${response:-$default}" in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *) echo "  请输入 y 或 n" ;;
    esac
  done
}

# ── Decision phase: 收集用户选择，构造 Plan ──

echo "=== 项目初始化: $CURRENT_DIR ==="
echo ""

if [ -d ".git" ]; then
  echo "→ 当前目录已是一个 Git 仓库。"
  if ! yes_no "  是否仍要运行初始化？" "n"; then
    echo "  已取消。"
    exit 0
  fi
else
  echo "→ 当前目录尚未初始化。"
  if ! yes_no "  是否开始初始化？" "Y"; then
    echo "  已取消。"
    exit 0
  fi
fi
echo ""

echo "请选择要初始化的目标工具："
echo "  [1] OpenCode"
echo "  [2] Claude"
echo "  [3] 两者都选"
read -r -p "请输入选项 (1/2/3): " tool_choice
echo ""

echo "请选择技能组框架："
echo "  [1] Matt Pocock Skills (npx skills@latest add mattpocock/skills)"
echo "  [2] Trellis (npx @mindfoldhq/trellis init)"
read -r -p "请输入选项 (1/2): " skill_choice
echo ""

declare -A PLAN

case "$tool_choice" in
  1) PLAN[tool]="opencode"  ;;
  2) PLAN[tool]="claude"    ;;
  3) PLAN[tool]="both"      ;;
  *) echo "❌ 无效选项，退出。"; exit 1 ;;
esac

case "$skill_choice" in
  1) PLAN[skills]="mpskills" ;;
  2) PLAN[skills]="trellis"  ;;
  *) echo "❌ 无效选项，退出。"; exit 1 ;;
esac

echo "准备初始化："
case "${PLAN[tool]}" in
  opencode) echo "  • OpenCode 配置" ;;
  claude)   echo "  • Claude 配置" ;;
  both)     echo "  • OpenCode 配置"; echo "  • Claude 配置" ;;
esac
case "${PLAN[skills]}" in
  mpskills) echo "  • Matt Pocock Skills" ;;
  trellis)  echo "  • Trellis" ;;
esac
echo ""

# ── Seam ──
# Plan 已就绪。以下 Execution phase 只读 PLAN，不接触输入逻辑。

# ── Step 函数 ──

step1_git_init() {
  echo "[Step 1/6] 初始化 Git 仓库"
  if [ -d ".git" ]; then
    echo "  ✔ .git/ 已存在，跳过"
  else
    git init
    echo "  ✔ git init 完成"
  fi
}

step2_gitignore() {
  echo "[Step 2/6] 写入 .gitignore"
  ensure_file ".gitignore" "$SCRIPT_DIR/templates/gitignore" ".gitignore"
}

step3_templates() {
  local -n plan_ref=$1
  echo "[Step 3/6] 写入配置文件"

  local TEMPLATES=(
    "opencode|opencode.json|templates/opencode.json"
    "claude|.claude/settings.json|templates/claude-settings.json"
    "opencode|AGENTS.md|templates/AGENTS.md"
    "claude|CLAUDE.md|templates/AGENTS.md"
  )

  for entry in "${TEMPLATES[@]}"; do
    IFS='|' read -r cond target src <<< "$entry"
    local should_run=false
    case "$cond" in
      opencode) [[ ${plan_ref[tool]} == opencode || ${plan_ref[tool]} == both ]] && should_run=true ;;
      claude)   [[ ${plan_ref[tool]} == claude || ${plan_ref[tool]} == both ]] && should_run=true ;;
    esac
    if $should_run; then
      local dir
      dir=$(dirname "$target")
      if [[ "$dir" != "." ]]; then
        ensure_dir "$dir" "$dir"
      fi
      ensure_file "$target" "$SCRIPT_DIR/$src" "$target"
    fi
  done
}

step4_skills() {
  local -n plan_ref=$1
  echo "[Step 4/6] 安装技能组"

  case "${plan_ref[skills]}" in
    mpskills)
      if [ -d ".agents/skills" ]; then
        echo "  ✔ .agents/skills/ 已存在，跳过"
      else
        echo "  → 正在安装 Matt Pocock Skills..."
        if ! npx skills@latest add mattpocock/skills; then
          echo "  ⚠ 安装失败，请检查网络或手动重试"
        else
          echo "  ✔ Matt Pocock Skills 已安装"
        fi
      fi
      ;;
    trellis)
      echo "  → 正在安装 Trellis..."
      if ! npx @mindfoldhq/trellis init; then
        echo "  ⚠ 安装失败，请检查网络或手动重试"
      else
        echo "  ✔ Trellis 已安装"
      fi
      ;;
  esac
}

step5_aliases() {
  local -n plan_ref=$1
  echo "[Step 5/6] 注入 OpenCode 命令别名"

  local tool_ok=false
  [[ ${plan_ref[tool]} == opencode || ${plan_ref[tool]} == both ]] && tool_ok=true

  if $tool_ok && [[ ${plan_ref[skills]} == mpskills ]]; then
    if [ -f "opencode.json" ]; then
      if command -v python3 &>/dev/null; then
        python3 -c "
import os, pathlib

cmds_dir = '.opencode/commands'
pathlib.Path(cmds_dir).mkdir(parents=True, exist_ok=True)

cmd_entries = {
    'gwd': {'desc': 'Run grill-with-docs',              'template': 'Run the grill-with-docs skill workflow.'},
    'ica': {'desc': 'Run improve-codebase-architecture', 'template': 'Run the improve-codebase-architecture skill workflow.'},
    'gm':  {'desc': 'Run grill-me',                      'template': 'Run the grill-me skill workflow.'},
    'tp':  {'desc': 'Run to-spec',                       'template': 'Run the to-spec skill workflow.'},
    'tc':  {'desc': 'Run to-tickets',                    'template': 'Run the to-tickets skill workflow.'},
    'cw':  {'desc': 'Run code-review',                   'template': 'Run the code-review skill workflow.'},
    'implement': {'desc': 'Run implement',               'template': 'Run the implement skill workflow.'},
}

for name, info in cmd_entries.items():
    md_path = os.path.join(cmds_dir, f'{name}.md')
    with open(md_path, 'w') as f:
        f.write('---\n')
        f.write(f'description: {info[\"desc\"]}\n')
        f.write('---\n')
        f.write('\n')
        f.write(f'{info[\"template\"]}\n')
"
        echo "  ✔ 命令别名已注入"
      else
        echo "  - python3 未安装，跳过命令别名注入"
      fi
    else
      echo "  - opencode.json 不存在，跳过"
    fi
  else
    echo "  - 跳过（仅 OpenCode + Matt's Skills 时注入）"
  fi
}

step6_codegraph() {
  echo "[Step 6/6] CodeGraph 索引"

  if yes_no "  是否初始化 CodeGraph 索引？" "n"; then
    if command -v codegraph &>/dev/null; then
      echo "  → 正在初始化 CodeGraph..."
      codegraph init
      echo "  ✔ CodeGraph 索引已创建"
    else
      echo "  - codegraph CLI 未安装，跳过"
    fi
  else
    echo "  - 跳过 CodeGraph 初始化"
  fi
}

# ── Execution phase ──

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

# ── 完成 ──

echo "========================"
echo " 初始化完成！"
echo " 目录: $CURRENT_DIR"
echo -n " 工具: "
case "${PLAN[tool]}" in
  opencode) echo -n 'OpenCode ' ;;
  claude)   echo -n 'Claude ' ;;
  both)     echo -n 'OpenCode Claude ' ;;
esac
echo ""
echo -n " 技能: "
case "${PLAN[skills]}" in
  mpskills) echo -n 'Matt Pocock Skills ' ;;
  trellis)  echo -n 'Trellis ' ;;
esac
echo ""
echo "========================"
