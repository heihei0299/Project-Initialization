#!/usr/bin/env bash
set -euo pipefail

# init-project.sh — 个人项目初始化脚本
# 五步走：git init → .gitignore → opencode.json → Matt Pocock Skills → AGENTS.md
# Templates live in templates/ — edit those, not the heredocs.

CURRENT_DIR=$(pwd)
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

ensure_file() {
  local path="$1" src="$2" label="${3:-$path}"
  if [ -f "$path" ]; then
    echo "✔ $label 已存在，跳过"
  else
    cp "$src" "$path"
    echo "✔ $label 已写入"
  fi
}

echo "=== 初始化项目: $CURRENT_DIR ==="
echo ""

# ── Step 1: git init ──
if [ -d ".git" ]; then
  echo "✔ .git/ 已存在，跳过 git init"
else
  git init
  echo "✔ git init 完成"
fi

# ── Step 2: .gitignore ──
ensure_file ".gitignore" "$SCRIPT_DIR/templates/gitignore" ".gitignore"

# ── Step 3: opencode.json ──
ensure_file "opencode.json" "$SCRIPT_DIR/templates/opencode.json" "opencode.json"

# ── Step 4: Matt Pocock Skills ──
if [ -d ".agents/skills" ]; then
  echo "✔ .agents/skills/ 已存在，跳过安装"
else
  echo "→ 正在安装 Matt Pocock Skills..."
  npx skills@latest add mattpocock/skills
  echo "✔ Matt Pocock Skills 已安装"
fi

# ── Step 5: AGENTS.md ──
ensure_file "AGENTS.md" "$SCRIPT_DIR/templates/AGENTS.md" "AGENTS.md"

echo ""
echo "========================"
echo " 五步初始化完成！"
echo " 当前目录: $CURRENT_DIR"
echo "========================"
echo ""
echo "提示: 将 ~/bin 加入 PATH 以便全局调用此脚本"
