setup() {
  load '../lib/utils.sh'
  TEST_DIR=$(mktemp -d)
  cd "$TEST_DIR" || exit 1
}

teardown() {
  rm -rf "$TEST_DIR"
}

# ── ensure_file ──

@test "ensure_file: 源文件不存在时报错" {
  run ensure_file "target.txt" "/nonexistent/source.txt" "test"
  [ "$status" -eq 1 ]
}

@test "ensure_file: 目标已存在时跳过" {
  echo "existing" > "target.txt"
  echo "source" > "source.txt"
  run ensure_file "target.txt" "source.txt" "test"
  [[ "$output" == *"已存在"* ]]
  [[ "$(cat target.txt)" == "existing" ]]
}

@test "ensure_file: 目标不存在时复制" {
  echo "source content" > "source.txt"
  run ensure_file "target.txt" "source.txt" "test"
  [[ "$output" == *"已写入"* ]]
  [[ "$(cat target.txt)" == "source content" ]]
}

# ── ensure_dir ──

@test "ensure_dir: 目录已存在时跳过" {
  mkdir -p "mydir"
  run ensure_dir "mydir" "mydir"
  [[ "$output" == *"已存在"* ]]
}

@test "ensure_dir: 目录不存在时创建" {
  run ensure_dir "newdir" "newdir"
  [[ "$output" == *"已创建"* ]]
  [ -d "newdir" ]
}

# ── yes_no ──

@test "yes_no: 默认 Y 返回 0" {
  run bash -c 'source "$0/lib/utils.sh"; yes_no "继续？" "Y" <<< ""' "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
}

@test "yes_no: y 返回 0" {
  run bash -c 'source "$0/lib/utils.sh"; yes_no "继续？" <<< "y"' "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 0 ]
}

@test "yes_no: n 返回 1" {
  run bash -c 'source "$0/lib/utils.sh"; yes_no "继续？" <<< "n"' "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 1 ]
}

# ── print_plan_summary ──

@test "print_plan_summary: OpenCode + Trellis" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[tool]=opencode
PLAN[skills]=trellis
print_plan_summary
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"OpenCode"* ]]
  [[ "$output" == *"Trellis"* ]]
}

@test "print_plan_summary: Claude + MPSkills" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[tool]=claude
PLAN[skills]=mpskills
print_plan_summary
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"Claude"* ]]
  [[ "$output" == *"Matt Pocock Skills"* ]]
}

@test "print_plan_summary: both" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[tool]=both
PLAN[skills]=trellis
print_plan_summary
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"OpenCode"* ]]
  [[ "$output" == *"Claude"* ]]
  [[ "$output" == *"Trellis"* ]]
}

# ── cmd_available ──

@test "cmd_available: 存在命令返回 0" {
  run bash -c 'source "$0/lib/utils.sh"; cmd_available bash && echo "found" || echo "not found"' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"found"* ]]
}

@test "cmd_available: 不存在命令返回 1" {
  run bash -c 'source "$0/lib/utils.sh"; cmd_available nonexistent_cmd_xyz && echo "found" || echo "not found"' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"not found"* ]]
}

# ── tool_label / skills_label ──

@test "tool_label: opencode" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[tool]=opencode
tool_label
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == "OpenCode" ]]
}

@test "tool_label: both" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[tool]=both
tool_label
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == "OpenCode Claude" ]]
}

@test "skills_label: mpskills" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[skills]=mpskills
skills_label
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == "Matt Pocock Skills" ]]
}

@test "skills_label: trellis" {
  run bash -c '
source "$0/lib/plan.sh"
declare -A PLAN
PLAN[skills]=trellis
skills_label
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == "Trellis" ]]
}

# ── prompt_choice ──

@test "prompt_choice: 选择有效选项" {
  run bash -c '
source "$0/lib/config.sh"
source "$0/lib/utils.sh"
prompt_choice "选择工具：" TOOL_CHOICES <<< "1"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"opencode" ]]
}

@test "prompt_choice: 无效选项返回 1" {
  run bash -c '
source "$0/lib/config.sh"
source "$0/lib/utils.sh"
prompt_choice "选择工具：" TOOL_CHOICES <<< "9" 2>/dev/null
' "$BATS_TEST_DIRNAME/.."
  [ "$status" -eq 1 ]
}

# ── step2_gitignore ──

@test "step2_gitignore: 从模板写入 .gitignore" {
  run bash -c '
SCRIPT_DIR="$0"
source "$0/lib/config.sh"
source "$0/lib/utils.sh"
source "$0/lib/steps.sh"
cd "$(mktemp -d)"
step2_gitignore
[[ -f .gitignore ]] && echo "created" || echo "missing"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"created"* ]]
}

# ── step3_templates ──

@test "step3_templates: opencode 写入 opencode.json + AGENTS.md" {
  run bash -c '
SCRIPT_DIR="$0"
source "$0/lib/config.sh"
source "$0/lib/utils.sh"
source "$0/lib/steps.sh"
declare -A PLAN
PLAN[tool]=opencode
cd "$(mktemp -d)"
step3_templates PLAN
echo "---"
ls opencode.json 2>/dev/null && echo "opencode:found"
ls AGENTS.md 2>/dev/null && echo "agents:found"
ls .claude/settings.json 2>/dev/null && echo "claude:found"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"opencode:found"* ]]
  [[ "$output" == *"agents:found"* ]]
  [[ "$output" != *"claude:found"* ]]
}

@test "step3_templates: claude 写入 .claude + CLAUDE.md" {
  run bash -c '
SCRIPT_DIR="$0"
source "$0/lib/config.sh"
source "$0/lib/utils.sh"
source "$0/lib/steps.sh"
declare -A PLAN
PLAN[tool]=claude
cd "$(mktemp -d)"
step3_templates PLAN
echo "---"
ls opencode.json 2>/dev/null && echo "opencode:found"
ls CLAUDE.md 2>/dev/null && echo "claude-md:found"
ls .claude/settings.json 2>/dev/null && echo "claude-json:found"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" != *"opencode:found"* ]]
  [[ "$output" == *"claude-md:found"* ]]
  [[ "$output" == *"claude-json:found"* ]]
}

# ── confirm_and_run ──

@test "confirm_and_run: yes + 存在命令时执行" {
  run bash -c '
source "$0/lib/utils.sh"
confirm_and_run "测试" "继续？" "y" bash -c "echo executed"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"executed"* ]]
  [[ "$output" == *"已创建"* ]]
}

@test "confirm_and_run: CLI 不存在时跳��" {
  run bash -c '
source "$0/lib/utils.sh"
confirm_and_run "测试" "继续？" "y" nonexistent_cli_xyz
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"未安装"* ]]
}

@test "confirm_and_run: 拒绝时跳过" {
  run bash -c '
source "$0/lib/utils.sh"
confirm_and_run "测试" "继续？" "n" bash -c "echo should_not_run" <<< "n"
' "$BATS_TEST_DIRNAME/.."
  [[ "$output" == *"跳过"* ]]
  [[ "$output" != *"should_not_run"* ]]
}
