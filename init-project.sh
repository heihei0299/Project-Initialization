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

# ── 入口：检测初始化状态 ──

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

# ── 选择目标工具 ──

echo "请选择要初始化的目标工具："
echo "  [1] OpenCode"
echo "  [2] Claude"
echo "  [3] 两者都选"
read -r -p "请输入选项 (1/2/3): " tool_choice
echo ""

# ── 选择技能组 ──

echo "请选择技能组框架："
echo "  [1] Matt Pocock Skills (npx skills@latest add mattpocock/skills)"
echo "  [2] Trellis (npx @mindfoldhq/trellis init)"
read -r -p "请输入选项 (1/2): " skill_choice
echo ""

# ── 解析选择 ──

use_opencode=false
use_claude=false

case "$tool_choice" in
  1) use_opencode=true  ;;
  2) use_claude=true    ;;
  3) use_opencode=true; use_claude=true ;;
  *) echo "❌ 无效选项，退出。"; exit 1 ;;
esac

use_trellis=false
use_mpskills=false

case "$skill_choice" in
  1) use_mpskills=true ;;
  2) use_trellis=true  ;;
  *) echo "❌ 无效选项，退出。"; exit 1 ;;
esac

# ── 汇总 ──

echo "准备初始化："
if $use_opencode; then echo "  • OpenCode 配置"; fi
if $use_claude;   then echo "  • Claude 配置"; fi
if $use_mpskills; then echo "  • Matt Pocock Skills"; fi
if $use_trellis;  then echo "  • Trellis"; fi
echo ""

# ── Step 1/8: git init ──

echo "[Step 1/8] 初始化 Git 仓库"
if [ -d ".git" ]; then
  echo "  ✔ .git/ 已存在，跳过"
else
  git init
  echo "  ✔ git init 完成"
fi
echo ""

# ── Step 2/8: .gitignore ──

echo "[Step 2/8] 写入 .gitignore"
ensure_file ".gitignore" "$SCRIPT_DIR/templates/gitignore" ".gitignore"
echo ""

# ── Step 3/8: OpenCode 配置 ──

if $use_opencode; then
  echo "[Step 3/8] 写入 OpenCode 配置 (opencode.json)"
  ensure_file "opencode.json" "$SCRIPT_DIR/templates/opencode.json" "opencode.json"
  echo ""
fi

# ── Step 4/8: Claude MCP 配置 ──

if $use_claude; then
  echo "[Step 4/8] 写入 Claude MCP 配置 (.claude/settings.json)"
  ensure_dir ".claude" ".claude"
  ensure_file ".claude/settings.json" "$SCRIPT_DIR/templates/claude-settings.json" ".claude/settings.json"
  echo ""
fi

# ── Step 5/8: 技能组 ──

echo "[Step 5/8] 安装技能组"

if $use_mpskills; then
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
fi

if $use_trellis; then
  echo "  → 正在安装 Trellis..."
  if ! npx @mindfoldhq/trellis init; then
    echo "  ⚠ 安装失败，请检查网络或手动重试"
  else
    echo "  ✔ Trellis 已安装"
  fi
fi

echo ""

# ── Step 6/8: OpenCode 命令别名（仅 OpenCode + Matt's Skills） ──

if $use_opencode && $use_mpskills; then
  echo "[Step 6/8] 注入 OpenCode 命令别名"
  if [ -f "opencode.json" ]; then
    if command -v python3 &>/dev/null; then
      python3 -c "
import json
with open('opencode.json') as f:
    cfg = json.load(f)
aliases = {
    'grw': {'template': 'Run the grill-with-docs skill workflow.', 'description': 'Run grill-with-docs'},
    'gm': {'template': 'Run the grill-me skill workflow.', 'description': 'Run grill-me'},
    'tp': {'template': 'Run the to-spec skill workflow.', 'description': 'Run to-spec'},
    'tc': {'template': 'Run the to-tickets skill workflow.', 'description': 'Run to-tickets'},
    'cw': {'template': 'Run the code-review skill workflow.', 'description': 'Run code-review'},
    'implement': {'template': 'Run the implement skill workflow.', 'description': 'Run implement'}
}
cfg.setdefault('command', {}).update(aliases)
with open('opencode.json', 'w') as f:
    json.dump(cfg, f, indent=2)
    f.write('\n')
"
      echo "  ✔ 命令别名已注入"
    else
      echo "  - python3 未安装，跳过命令别名注入"
    fi
  else
    echo "  - opencode.json 不存在，跳过"
  fi
  echo ""
fi

# ── Step 7/8: 项目指令文件 ──

if $use_opencode; then
  echo "[Step 7/8] 写入 AGENTS.md"
  ensure_file "AGENTS.md" "$SCRIPT_DIR/templates/AGENTS.md" "AGENTS.md"
  echo ""
fi

if $use_claude; then
  echo "[Step 7/8] 写入 CLAUDE.md"
  ensure_file "CLAUDE.md" "$SCRIPT_DIR/templates/AGENTS.md" "CLAUDE.md"
  echo ""
fi

# ── Step 8/8: CodeGraph 索引 ──

echo "[Step 8/8] CodeGraph 索引"

detect_codebase() {
  [ -d "src" ] && return 0
  for ext in py js ts rs go java c cpp h rb php cs; do
    if find . -maxdepth 1 -name "*.${ext}" -print -quit 2>/dev/null | grep -q .; then
      return 0
    fi
  done
  for build_file in Cargo.toml go.mod pom.xml build.gradle; do
    [ -f "$build_file" ] && return 0
  done
  return 1
}

if detect_codebase; then
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
else
  echo "  - 未检测到源文件，跳过 CodeGraph init"
fi
echo ""

# ── 完成 ──

echo "========================"
echo " 初始化完成！"
echo " 目录: $CURRENT_DIR"
printf " 工具: "
if $use_opencode; then printf 'OpenCode '; fi
if $use_claude;   then printf 'Claude '; fi
echo ""
printf " 技能: "
if $use_mpskills; then printf 'Matt Pocock Skills '; fi
if $use_trellis;  then printf 'Trellis '; fi
echo ""
echo "========================"
