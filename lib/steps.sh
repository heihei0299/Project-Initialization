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
  ensure_file ".gitignore" "$TEMPLATES_DIR/gitignore" ".gitignore"
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
        python3 "$SCRIPT_DIR/scripts/inject-aliases.py"
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
