## Problem Statement

`init-project.sh` 最初是一个 278 行的单体 bash 脚本，包含输入交互、决策逻辑、步骤执行全部混在一起。修改一处需要理解整个文件，添加新工具或技能组需要修改多处硬编码 case 分支，且无法进行自动化测试。

## Solution

将单体脚本拆分为职责独立的模块化架构，通过数据驱动消除内联条件逻辑，引入 bats 测试框架保障可回归性。

## User Stories

1. 作为开发者，我希望新增一个工具选项（如 VSCode）时只需在配置数组加一项，不需要改条件分支，从而降低改动的认知负荷
2. 作为开发者，我希望新增一个技能组时只需在配置数组加一项 + 安装命令，不需要改步骤函数，从而降低改动的认知负荷
3. 作为开发者，我希望每个模块有明确的输入输出契约，不依赖全局变量，从而可以独立测试和维护
4. 作为开发者，我希望修改步骤标题/数量时只需改一个数组，不需要修改 6 个 step 函数，从而避免遗漏
5. 作为开发者，我希望核心逻辑有自动化测试覆盖，从而在重构时获得快速反馈
6. 作为开发者，我希望配置数据（模板映射、选项列表、安装命令）集中管理，不分散在业务逻辑中，从而一眼看清所有可配置项
7. 作为开发者，我希望 Python 嵌入代码是独立的可测试文件，而不是 bash heredoc，从而获得 IDE 支持和语法检查

## Implementation Decisions

### 模块拆分

将 `init-project.sh` 拆分为 6 个文件：

- **init-project.sh** (~30 行)：纯入口，只做 source 模块 + 编排调用序列
- **lib/config.sh**：所有配置数据集中管理（STEP_LABELS、TEMPLATE_MAP、INSTALL_MAP、TOOL_CHOICES、SKILL_CHOICES、ALIASES_*、CONFIG_DELIM）
- **lib/utils.sh**：通用辅助函数（ensure_file、ensure_dir、cmd_available、try_install、confirm_and_run、prompt_choice、yes_no）
- **lib/plan.sh**：用户交互与决策，PLAN 构造 + 格式化输出（tool_label、skills_label、collect_plan、print_plan_summary）
- **lib/steps.sh**：5 个步骤函数，全部数据驱动，无内联条件
- **scripts/inject-aliases.py**：从 bash heredoc 提取为独立 Python 文件

### 数据驱动

- TEMPLATE_MAP 定义了所有模板文件的复制规则（条件→目标→源），step2_templates 遍历该数组执行
- INSTALL_MAP 定义了所有技能组的安装规则（值→目录检查→标签→命令），step3_skills 遍历匹配
- CONFIG_DELIM 作为配置数据的分隔符集中定义，解析函数引用该变量而非硬编码

### 参数化替代全局变量

- tool_label/skills_label/print_plan_summary 通过参数接收 PLAN 关联数组，不读取全局变量
- steps.sh 所有函数通过 nameref 参数接收 PLAN
- config.sh 通过 BASH_SOURCE[0] 自计算 PROJECT_ROOT，不依赖入口脚本设置路径变量

### 控制流

- collect_plan 使用 return 代替 exit，让入口脚本决定是否退出
- set -euo pipefail 在入口脚本设置，保障错误安全性

### 模块间依赖关系（单向）

```
init-project.sh → utils.sh → config.sh → plan.sh
                                      ↘ steps.sh
```

无循环依赖，每个模块只依赖在它之前被 source 的模块。

## Testing Decisions

### 好的测试的特征

- 只测试模块的外部行为（函数输入→输出），不测试内部实现细节
- 每个测试覆盖一个明确的场景，Assert 具体的输出内容
- 使用 bats 的 run + assert 模式，隔离文件系统副作用

### 测试层次

| 层次 | seam | 覆盖模块 | 测试数 |
|------|------|---------|--------|
| 单元测试 | 函数调用 | utils.sh（ensure_file、ensure_dir、yes_no、cmd_available、prompt_choice、confirm_and_run、try_install） | 15 |
| 单元测试 | 函数调用 | plan.sh（tool_label、skills_label、print_plan_summary） | 7 |
| 集成测试 | 模块联调 | steps.sh（step1~5，依赖 config + utils） | 13 |

### Pre-existing tests 参考

`tests/plan.bats` 中的现有测试定义了命名惯例和风格：
- 测试描述格式：`"function_name: scenario description"`
- setup() 中 load 所需模块 + 创建临时目录
- teardown() 中清理临时目录
- 使用 `run` 捕获 stdout 和 status
- 使用 `[[ "$output" == *"expected"* ]]` assert 输出

## Out of Scope

- 不改动 templates/ 目录的内容格式
- 不改动 opencode.json 的 MCP 配置
- 不改动 .trellis/ 技能体系
- 不引入 CI/CD 配置
- UI 消息字符串（"✔"、"⚠"等）保持在各自模块内，不抽取到 config

## Further Notes

- 架构决策记录在 `docs/adr/0001` ~ `0004` 中
- 术语表在 `CONTEXT.md` 中
- 项目 README 包含了更新后的结构和配置指南
