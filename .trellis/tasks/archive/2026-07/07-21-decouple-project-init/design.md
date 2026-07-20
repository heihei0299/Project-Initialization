# project-init 低耦合重构 — 技术设计

## 目标目录结构

```
project-init/
├── init-project.sh          ← 入口：~30 行，只做 source + 编排
├── lib/
│   ├── utils.sh             ← 辅助函数：ensure_file, ensure_dir, yes_no
│   ├── plan.sh              ← 决策模块：收集用户输入 → 构造 PLAN
│   └── steps.sh             ← 执行模块：step1 ~ step6
├── scripts/
│   └── inject-aliases.py    ← 从 step5 heredoc 提取的 Python 脚本
├── templates/               ← 不变
└── tests/
    └── plan.bats            ← bats 测试 plan.sh 决策逻辑
```

## 模块边界与接口

### lib/utils.sh

```bash
ensure_file <path> <source> [label]
ensure_dir  <path> [label]
yes_no      <prompt> [default]  → returns 0/1
```

纯函数，不读写全局变量，仅依赖 stdin/stdout / 文件系统。

### lib/plan.sh

```bash
collect_plan   → 设置全局 PLAN (associative array)
print_plan_summary   → 输出 Plan 摘要到 stdout
```

- `PLAN[tool]`: `opencode` | `claude` | `both`
- `PLAN[skills]`: `mpskills` | `trellis`
- `PLAN` 是模块间唯一契约接口

### lib/steps.sh

```bash
step1_git_init
step2_gitignore
step3_templates  PLAN
step4_skills     PLAN
step5_aliases    PLAN
step6_codegraph
```

- 每个 step 读取 `PLAN` 来决定行为
- step5_aliases 调用 `scripts/inject-aliases.py` 代替 heredoc
- step6_codegraph 调用 `codegraph init`

### scripts/inject-aliases.py

当前 step5 中的 heredoc Python 代码提取为独立文件：
- 接受 `PLAN[tool]` 和 `PLAN[skills]` 作为参数（通过环境变量或参数传递）
- 职责不变：在 `.opencode/commands/` 下创建 `*.md` 文件

### init-project.sh（入口）

```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

source "$SCRIPT_DIR/lib/utils.sh"
source "$SCRIPT_DIR/lib/plan.sh"
source "$SCRIPT_DIR/lib/steps.sh"

collect_plan

# ── Seam ──

step1_git_init
step2_gitignore
step3_templates PLAN
step4_skills PLAN
step5_aliases PLAN
step6_codegraph

print_plan_summary
```

## 关键解耦决策

### 1. Python 嵌入代码 → 独立脚本

```bash
# BEFORE (step5_aliases):
python3 -c "
import os, pathlib
cmd_entries = {...}
for name, info in cmd_entries.items():
    ...
"

# AFTER:
python3 "$SCRIPT_DIR/scripts/inject-aliases.py"
```

同时保留 `if command -v python3` 守卫，python3 不安装时跳过。

### 2. Plan 重复模式消除

当前 "摘要" 和 "完成" 两段重复的 case 模式：
- 摘要部分：入口中的 `echo` 输出
- 完成部分：脚本末尾的 `echo -n "工具: "` ...

统一为 `print_plan_summary` 函数，两处都调用它。

### 3. 模板路径常量化

```bash
# BEFORE: 路径硬编码
ensure_file ".gitignore" "$SCRIPT_DIR/templates/gitignore" ".gitignore"

# AFTER: 变量定义在 plan.sh 顶部
TEMPLATES_DIR="$SCRIPT_DIR/templates"
ensure_file ".gitignore" "$TEMPLATES_DIR/gitignore" ".gitignore"
```

## 测试策略

### bats 测试（tests/plan.bats）

```
plan.bats
├── 辅助函数测试
│   ├── yes_no 默认值 Y 返回 0
│   ├── yes_no 默认值 n 返回 1
│   ├── ensure_file 已有文件跳过
│   └── ensure_file 不存在则复制
├── Plan 决策测试
│   ├── 选 OpenCode + Trellis → PLAN[tool]=opencode, PLAN[skills]=trellis
│   ├── 选 Claude + MPSkills → PLAN[tool]=claude, PLAN[skills]=mpskills
│   └── 选 both + Trellis → PLAN[tool]=both, PLAN[skills]=trellis
```

### 手动验证

- 运行重构后的 `init-project.sh`，交互流程和输出与原来一致
- 新建空目录，全选项组合执行一次（至少 OpenCode+Trellis 和 Claude+MPSkills 两条路径）

## 兼容性与迁移

- 重构前后 `init-project.sh` 对外接口不变（命令行用法、交互提示、退出码）
- `templates/` 目录内容不变
- 对已初始化的项目无影响（此重构只影响初始化流程本身）
- 无数据迁移需求

## Rollback

- 重构期间保留 `init-project.sh.bak` 直到测试通过
- 如交互或功能异常，恢复备份即可
