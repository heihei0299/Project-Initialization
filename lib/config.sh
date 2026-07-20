TEMPLATES_DIR="$SCRIPT_DIR/templates"

TEMPLATE_MAP=(
  "opencode|opencode.json|opencode.json"
  "claude|.claude/settings.json|claude-settings.json"
  "opencode|AGENTS.md|AGENTS.md"
  "claude|CLAUDE.md|AGENTS.md"
)

INSTALL_MAP=(
  "mpskills|.agents/skills|Matt Pocock Skills|npx skills@latest add mattpocock/skills"
  "trellis||Trellis|npx @mindfoldhq/trellis init"
)

TOOL_CHOICES=(
  "1|opencode|OpenCode"
  "2|claude|Claude"
  "3|both|两者都选"
)

SKILL_CHOICES=(
  "1|mpskills|Matt Pocock Skills (npx skills@latest add mattpocock/skills)"
  "2|trellis|Trellis (npx @mindfoldhq/trellis init)"
)
