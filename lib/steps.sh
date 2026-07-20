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

step2_templates() {
  local -n plan_ref=$1
  step_echo 2

  for entry in "${TEMPLATE_MAP[@]}"; do
    IFS='|' read -r cond target src <<< "$entry"
    if [[ "$cond" == "always" || ${plan_ref[tool]} == "$cond" || ${plan_ref[tool]} == "both" ]]; then
      local dir
      dir=$(dirname "$target")
      if [[ "$dir" != "." ]]; then
        ensure_dir "$dir" "$dir"
      fi
      ensure_file "$target" "$TEMPLATES_DIR/$src" "$target"
    fi
  done
}

step3_skills() {
  local -n plan_ref=$1
  step_echo 3

  local s="${plan_ref[skills]}"
  for entry in "${INSTALL_MAP[@]}"; do
    IFS='|' read -r key check_dir label cmd <<< "$entry"
    [[ "$s" != "$key" ]] && continue
    [[ -n "$check_dir" && -d "$check_dir" ]] && { echo "  ✔ $check_dir/ 已存在，跳过"; return; }
    try_install "$label" $cmd
    return
  done
}

step4_aliases() {
  local -n plan_ref=$1
  step_echo 4

  if [[ ${plan_ref[tool]} != "$ALIASES_TOOL" && ${plan_ref[tool]} != "both" ]] || [[ ${plan_ref[skills]} != "$ALIASES_SKILL" ]]; then
    echo "  - 跳过（仅 ${ALIASES_TOOL} + ${ALIASES_SKILL} 时注入）"
    return
  fi

  if [ ! -f "$ALIASES_CONFIG" ]; then
    echo "  - $ALIASES_CONFIG 不存在，跳过"
    return
  fi

  if cmd_available python3; then
    python3 "$SCRIPT_DIR/scripts/inject-aliases.py"
    echo "  ✔ 命令别名已注入"
  else
    echo "  - python3 未安装，跳过命令别名注入"
  fi
}

step5_codegraph() {
  step_echo 5
  local step_name
  step_name=$(step_label 5)
  confirm_and_run "$step_name" "  是否初始化 $step_name？" "n" codegraph init
}
