TEMPLATES_DIR="$SCRIPT_DIR/templates"

STEP_LABELS=(
  "初始化 Git 仓库"
  "写入配置文件"
  "安装技能组"
  "注入 OpenCode 命令别名"
  "CodeGraph 索引"
)

step_echo() {
  local num=$1
  echo "[Step $num/${#STEP_LABELS[@]}] ${STEP_LABELS[$((num-1))]}"
}

step_label() {
  local num=$1
  echo "${STEP_LABELS[$((num-1))]}"
}

TEMPLATE_MAP=(
  "always|.gitignore|gitignore"
  "opencode|opencode.json|opencode.json"
  "claude|.claude/settings.json|claude-settings.json"
  "opencode|AGENTS.md|AGENTS.md"
  "claude|CLAUDE.md|AGENTS.md"
)

INSTALL_MAP=(
  "mpskills|.agents/skills|Matt Pocock Skills|npx skills@latest add mattpocock/skills"
  "trellis||Trellis|npx @mindfoldhq/trellis init"
)

ALIASES_TOOL="opencode"
ALIASES_SKILL="mpskills"
ALIASES_CONFIG="opencode.json"

TOOL_CHOICES=(
  "1|opencode|OpenCode"
  "2|claude|Claude"
  "3|both|两者都选"
)

SKILL_CHOICES=(
  "1|mpskills|Matt Pocock Skills (npx skills@latest add mattpocock/skills)"
  "2|trellis|Trellis (npx @mindfoldhq/trellis init)"
)
