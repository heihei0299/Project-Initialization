# ADR-0003: 模块化架构拆分

## 决定

将 `init-project.sh`（278 行单体）拆分为 5 个模块文件 + 1 个 Python 脚本 + 测试套件。

## 理由

ADR-0002 的 Plan/Execution seam 已将逻辑分层，但 278 行单文件仍是维护痛点：任何改动都需要全文阅读，嵌入式 Python heredoc 不可单独测试，无测试覆盖。

## 结构

```
init-project.sh       — 入口（29 行）：source + 编排
lib/config.sh         — 配置常量（TEMPLATES_DIR、TEMPLATE_MAP）
lib/utils.sh          — 辅助函数（ensure_file、ensure_dir、yes_no、try_install）
lib/plan.sh           — 决策模块（用户交互、PLAN 构造、格式化函数）
lib/steps.sh          — 执行模块（step1~6，从 config.sh 读取配置）
scripts/inject-aliases.py  — 从 step5 heredoc 提取的独立 Python 脚本
tests/plan.bats       — bats 测试套件（11 tests）
```

## 关键决策

### 1. 4 文件拆分（而非每个 step 一个文件）

考虑过每个 step 独立文件（`steps/step1.sh` ~ `step6.sh`），但当前 6 个 step 总计仅 ~100 行，独立文件反而增加导航开销。4 个模块（utils/config/plan/steps）的粒度在可维护性和文件数之间取得平衡。

### 2. 嵌入式 Python 提取

step5（aliases 注入）的 24 行 Python heredoc 提取为 `scripts/inject-aliases.py`，使 Python 代码可获得 IDE 支持、语法检查和独立测试。

### 3. `tool_label` / `skills_label` 消除 case 重复

ADR-0002 已知 smell：`case "${PLAN[tool]}"` 和 `case "${PLAN[skills]}"` 模式在"准备初始化"预览和"初始化完成"摘要两处重复。通过提取 `tool_label()` 和 `skills_label()` 函数消除，新增工具/技能时只需改一处。

### 4. `try_install` 提取

step4 两条分支的 `if ! npx ...` 安装守卫模式相同，提取为 `try_install()`，函数签名 `try_install <label> <cmd> [args...]`。

### 5. bats 测试

选择 bats 作为 shell 测试框架（而非 shunit2），因为 bats 在退出码断言和 `run` 模式上对嵌套函数调用更友好。

## 状态

已接受。

## Consequences

- 新增模块化功能：在 lib/ 创建新文件，入口加一行 source 即可
- 新增工具选项（如 VSCode）：在 config.sh 加一条 TEMPLATE_MAP 条目 + plan.sh 的 case 加一项
- 新增技能组：config.sh 不需要改，plan.sh 的 case 加一项 + step4_skills 的 case 加分支
- 每次结构变更需更新本 ADR 的模块清单
