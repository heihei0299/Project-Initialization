tool_label() {
  local -n plan_ref=$1
  case "${plan_ref[tool]}" in
    opencode) echo "OpenCode" ;;
    claude)   echo "Claude" ;;
    both)     echo "OpenCode Claude" ;;
  esac
}

skills_label() {
  local -n plan_ref=$1
  case "${plan_ref[skills]}" in
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
      return 1
    fi
  else
    echo "→ 当前目录尚未初始化。"
    if ! yes_no "  是否开始初始化？" "Y"; then
      echo "  已取消。"
      return 1
    fi
  fi
  echo ""

  local tool_val skill_val

  tool_val=$(prompt_choice "请选择要初始化的目标工具：" TOOL_CHOICES) || {
    echo "❌ 无效选项，退出。"; return 1
  }
  echo ""

  skill_val=$(prompt_choice "请选择技能组框架：" SKILL_CHOICES) || {
    echo "❌ 无效选项，退出。"; return 1
  }
  echo ""

  PLAN[tool]="$tool_val"
  PLAN[skills]="$skill_val"

  echo "准备初始化："
  echo "  • $(tool_label PLAN)"
  echo "  • $(skills_label PLAN)"
  echo ""
}

print_plan_summary() {
  echo "========================"
  echo " 初始化完成！"
  echo " 目录: $(pwd)"
  echo " 工具: $(tool_label "$1")"
  echo " 技能: $(skills_label "$1")"
  echo "========================"
}
