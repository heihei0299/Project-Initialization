step1_git_init() {
  step_echo 1
  if [ -d ".git" ]; then
    echo "  ✔ .git/ 已存在，跳过"
  elif cmd_available git; then
    git init
    echo "  ✔ git init 完成"
  else
    echo "  - git 未安装，跳过"
  fi
}

step2_gitignore() {
  step_echo 2
  ensure_file ".gitignore" "$TEMPLATES_DIR/gitignore" ".gitignore"
}

step3_templates() {
  local -n plan_ref=$1
  step_echo 3

  for entry in "${TEMPLATE_MAP[@]}"; do
    IFS='|' read -r cond target src <<< "$entry"
    if [[ ${plan_ref[tool]} == "$cond" || ${plan_ref[tool]} == "both" ]]; then
      local dir
      dir=$(dirname "$target")
      if [[ "$dir" != "." ]]; then
        ensure_dir "$dir" "$dir"
      fi
      ensure_file "$target" "$TEMPLATES_DIR/$src" "$target"
    fi
  done
}

step4_skills() {
  local -n plan_ref=$1
  step_echo 4

  local s="${plan_ref[skills]}"
  for entry in "${INSTALL_MAP[@]}"; do
    IFS='|' read -r key check_dir label cmd <<< "$entry"
    [[ "$s" != "$key" ]] && continue
    [[ -n "$check_dir" && -d "$check_dir" ]] && { echo "  ✔ $check_dir/ 已存在，跳过"; return; }
    try_install "$label" $cmd
    return
  done
}

step5_aliases() {
  local -n plan_ref=$1
  step_echo 5

  if [[ ${plan_ref[tool]} != opencode && ${plan_ref[tool]} != both ]] || [[ ${plan_ref[skills]} != mpskills ]]; then
    echo "  - 跳过（仅 OpenCode + Matt's Skills 时注入）"
    return
  fi

  if [ ! -f "opencode.json" ]; then
    echo "  - opencode.json 不存在，跳过"
    return
  fi

  if cmd_available python3; then
    python3 "$SCRIPT_DIR/scripts/inject-aliases.py"
    echo "  ✔ 命令别名已注入"
  else
    echo "  - python3 未安装，跳过命令别名注入"
  fi
}

step6_codegraph() {
  step_echo 6
  confirm_and_run "CodeGraph 索引" "  是否初始化 CodeGraph 索引？" "n" codegraph init
}
