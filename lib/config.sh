# shellcheck shell=bash

_LIB_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT="$_LIB_DIR/.."
export TEMPLATES_DIR="$PROJECT_ROOT/templates"
export CONFIG_DELIM='|'

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

# shellcheck disable=SC2034 # used by steps.sh via source
TEMPLATE_MAP=(
  "always|.gitignore|gitignore"
  "opencode|opencode.json|opencode.json"
  "claude|.claude/settings.json|claude-settings.json"
  "opencode|AGENTS.md|AGENTS.md"
  "claude|CLAUDE.md|AGENTS.md"
)

# shellcheck disable=SC2034 # used by steps.sh via source
INSTALL_MAP=(
  "mpskills|.agents/skills|Matt Pocock Skills|npx skills@latest add mattpocock/skills"
  "trellis||Trellis|npx @mindfoldhq/trellis init"
)

export ALIASES_TOOL="opencode"
export ALIASES_SKILL="mpskills"
export ALIASES_CONFIG="opencode.json"

# shellcheck disable=SC2034 # used by plan.sh via source
TOOL_CHOICES=(
  "1|opencode|OpenCode"
  "2|claude|Claude"
  "3|both|两者都选"
)

# shellcheck disable=SC2034 # used by plan.sh via source
SKILL_CHOICES=(
  "1|mpskills|Matt Pocock Skills (npx skills@latest add mattpocock/skills)"
  "2|trellis|Trellis (npx @mindfoldhq/trellis init)"
)
