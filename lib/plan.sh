tool_label() {
  case "${PLAN[tool]}" in
    opencode) echo "OpenCode" ;;
    claude)   echo "Claude" ;;
    both)     echo "OpenCode Claude" ;;
  esac
}

skills_label() {
  case "${PLAN[skills]}" in
    mpskills) echo "Matt Pocock Skills" ;;
    trellis)  echo "Trellis" ;;
  esac
}

collect_plan() {
  echo "=== 项目初始化: $(pwd) ==="
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

  case "$tool_choice" in
    1) PLAN[tool]="opencode" ;;
    2) PLAN[tool]="claude"   ;;
    3) PLAN[tool]="both"     ;;
    *) echo "❌ 无效选项，退出。"; exit 1 ;;
  esac

  case "$skill_choice" in
    1) PLAN[skills]="mpskills" ;;
    2) PLAN[skills]="trellis"  ;;
    *) echo "❌ 无效选项，退出。"; exit 1 ;;
  esac

  echo "准备初始化："
  echo "  • $(tool_label)"
  echo "  • $(skills_label)"
  echo ""
}

print_plan_summary() {
  echo "========================"
  echo " 初始化完成！"
  echo " 目录: $(pwd)"
  echo " 工具: $(tool_label)"
  echo " 技能: $(skills_label)"
  echo "========================"
}
