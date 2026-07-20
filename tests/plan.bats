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
