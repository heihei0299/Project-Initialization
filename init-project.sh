#!/usr/bin/env bash
set -euo pipefail

# init-project.sh — 个人项目初始化脚本
# 严格五步走：git init → .gitignore → opencode.json → Matt Pocock Skills → AGENTS.md

CURRENT_DIR=$(pwd)

echo "=== 初始化项目: $CURRENT_DIR ==="
echo ""

# ── Step 1: git init ──
if [ -d ".git" ]; then
  echo "✔ .git/ 已存在，跳过 git init"
else
  git init
  echo "✔ git init 完成"
fi

# ── Step 2: 覆盖全场景的 .gitignore ──
cat > .gitignore << 'GITIGNORE_EOF'
# === 操作系统 ===
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
Desktop.ini
$RECYCLE.BIN/

# === 编辑器 / IDE ===
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
!.vscode/extensions.json
*.swp
*.swo
*~
.idea/
*.iml
*.ipr
*.iws
.project
.classpath
.settings/
.nbproject/
*.sublime-*
.ropeproject/
.ensime_cache/

# === Node.js ===
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.pnpm-debug.log*
lerna-debug.log*
.yarn/
.yarn-integrity
package-lock.json
yarn.lock
pnpm-lock.yaml

# === Python ===
__pycache__/
*.py[cod]
*.pyo
*.egg-info/
.eggs/
dist/
build/
*.egg
.venv/
venv/
env/
.Python
pip-log.txt
pip-delete-this-directory.txt
.tox/
.coverage
.coverage.*
*.cover
.mypy_cache/
.ruff_cache/
.pytest_cache/

# === Rust ===
target/
**/*.rs.bk
Cargo.lock

# === Go ===
*.exe
*.exe~
*.dll
*.so
*.dylib
*.test
*.out

# === Java / JVM ===
*.class
*.jar
*.war
*.ear
.gradle/
build/
!gradle/wrapper/gradle-wrapper.jar
out/
*.log

# === Docker ===
.docker/

# === 敏感信息 ===
.env
.env.local
.env.*.local
*.pem
*.key
*.cert
config/credentials.yml.enc

# === 构建产物 ===
dist/
build/
*.tsbuildinfo
.next/
.nuxt/
.cache/
coverage/
.nyc_output/
.eslintcache
.stylelintcache

# === 其他通用 ===
*.log
*.tmp
*.bak
*.orig
*.patch
*.diff
scratch/
tmp/
temp/
uploads/
media/
GITIGNORE_EOF
echo "✔ .gitignore 已写入（覆盖全场景）"

# ── Step 3: opencode.json ──
if [ -f "opencode.json" ]; then
  echo "✔ opencode.json 已存在，跳过"
else
  cat > opencode.json << 'OPENCODE_EOF'
{
  "$schema": "https://opencode.ai/config.json",

  "mcp": {
    "context7": {
      "command": ["npx", "-y", "@upstash/context7-mcp"],
      "enabled": true,
      "type": "local"
    },
    "fetch": {
      "command": ["uvx", "mcp-server-fetch"],
      "enabled": true,
      "type": "local"
    },
    "playwright": {
      "command": ["npx", "-y", "@playwright/mcp@0.0.50"],
      "enabled": true,
      "type": "local"
    },
    "codegraph": {
      "command": ["codegraph", "serve", "--mcp"],
      "enabled": true,
      "type": "local"
    }
  }
}
OPENCODE_EOF
  echo "✔ opencode.json 已写入"
fi

# ── Step 4: 安装 Matt Pocock Skills ──
if [ -d ".agents/skills" ]; then
  echo "✔ .agents/skills/ 已存在，跳过安装"
else
  echo "→ 正在安装 Matt Pocock Skills..."
  npx skills@latest add mattpocock/skills
  echo "✔ Matt Pocock Skills 已安装"
fi

# ── Step 5: AGENTS.md (CodeGraph 指令) ──
if [ -f "AGENTS.md" ]; then
  echo "✔ AGENTS.md 已存在，跳过"
else
  cat > AGENTS.md << 'AGENTS_EOF'
<!-- CODEGRAPH_START -->
## CodeGraph

In repositories indexed by CodeGraph (a `.codegraph/` directory exists at the repo root), reach for it BEFORE grep/find or reading files when you need to understand or locate code:

- **MCP tool** (when available): `codegraph_explore` answers most code questions in one call — the relevant symbols' verbatim source plus the call paths between them, including dynamic-dispatch hops grep can't follow. Name a file or symbol in the query to read its current line-numbered source. If it's listed but deferred, load it by name via tool search.
- **Shell** (always works): `codegraph explore "<symbol names or question>"` prints the same output.

If there is no `.codegraph/` directory, skip CodeGraph entirely — indexing is the user's decision.
<!-- CODEGRAPH_END -->
AGENTS_EOF
  echo "✔ AGENTS.md 已写入"
fi

echo ""
echo "========================"
echo " 五步初始化完成！"
echo " 当前目录: $CURRENT_DIR"
echo "========================"
echo ""
echo "提示: 将 ~/bin 加入 PATH 以便全局调用此脚本"
