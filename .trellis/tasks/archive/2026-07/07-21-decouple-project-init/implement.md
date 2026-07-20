# project-init 低耦合重构 — 执行计划

## 前置条件

- [x] GitHub API token 或 bats 本地安装（`npm install -g bats` 或 `apt install bats`）

## 执行步骤

### Step 1: 备份原有脚本

```bash
cp init-project.sh init-project.sh.bak
```

### Step 2: 创建目录结构

```bash
mkdir -p lib scripts tests
```

### Step 3: 提取 lib/utils.sh

- 从 `init-project.sh` 提取 `ensure_file`, `ensure_dir`, `yes_no` 三个函数
- 保持函数签名不变
- **验证**: `bash -n lib/utils.sh` 通过

### Step 4: 提取 lib/plan.sh

- 从 `init-project.sh` 提取用户交互逻辑（tool_choice / skill_choice 输入）
- 提取 `collect_plan` 函数封装所有 stdin 读取
- 添加 `print_plan_summary` 函数消除 Plan 输出重复
- 定义 `TEMPLATES_DIR` 常量和 Step 配置
- **验证**: `bash -n lib/plan.sh` 通过

### Step 5: 提取 lib/steps.sh

- 从 `init-project.sh` 提取 step1~step6 六个函数
- step5_aliases 改为调用 `$SCRIPT_DIR/scripts/inject-aliases.py` 替代 heredoc
- **验证**: `bash -n lib/steps.sh` 通过

### Step 6: 提取 scripts/inject-aliases.py

- 将 step5 的 Python heredoc 内容写为独立 `.py` 文件
- 通过参数或环境变量接收 PLAN 信息
- **验证**: `python3 -m py_compile scripts/inject-aliases.py` 通过

### Step 7: 重写 init-project.sh（入口）

- source 三个 lib 模块
- 调用 `collect_plan` → 执行 Step → `print_plan_summary`
- ≤30 行，职责单一
- **验证**: `bash -n init-project.sh` 通过，且 `diff <(bash -n init-project.sh.bak) <(bash -n init-project.sh)` 无差异

### Step 8: 安装 bats 并编写测试

```bash
npm install -D bats  # 或 apt install bats
```

- 创建 `tests/plan.bats` 覆盖 plan.sh 和 utils.sh
- **验证**: `bats tests/` 全部通过

### Step 9: 手动验证交互流程

- 执行 `./init-project.sh` 在临时目录
- 测试 OpenCode + Trellis 路径
- 测试 Claude + MPSkills 路径
- 验证每个 Step 的输出与原来一致

### Step 10: 清理

- 确认新脚本工作正常后删除 `init-project.sh.bak`

## 验证命令汇总

```bash
# 语法验证
bash -n init-project.sh
bash -n lib/utils.sh
bash -n lib/plan.sh
bash -n lib/steps.sh
python3 -m py_compile scripts/inject-aliases.py

# 测试
bats tests/

# 功能验证（手动）
cd /tmp/test-init && /path/to/init-project.sh
```

## 风险文件

| 文件 | 风险 | 回滚操作 |
|------|------|----------|
| `init-project.sh` | 入口脚本重构 | `mv init-project.sh.bak init-project.sh` |

## 检查点

- [ ] 所有 `.sh` 文件 `bash -n` 通过
- [ ] `.py` 文件 `py_compile` 通过
- [ ] bats 测试全部通过
- [ ] 交互流程保持与原来一致
- [ ] Plan 输出格式保持与原来一致
