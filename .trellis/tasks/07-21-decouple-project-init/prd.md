# project-init 低耦合重构

## Goal

降低 `project-init` 项目各模块间的耦合度，提高可维护性、可测试性和可扩展性。

## Background / 现状

通过代码分析确认以下事实：

- 核心代码为单个 `init-project.sh`（278 行 bash），包含输入决策、Plan 构造、6 个 Step 执行全部逻辑
- ADR-0002 已引入 `declare -A PLAN` + Decision/Execution seam，将步骤封装为函数
- 模板文件已分离到 `templates/` 目录（opencode.json, claude-settings.json, AGENTS.md, gitignore）
- Step 5（aliases）嵌入了多行 Python 代码作为 bash heredoc
- 没有测试覆盖（bash 脚本不可单独测试）
- Plan 构造逻辑（case 模式）在摘要和完成两处重复（ADR-0002 已知 smell）
- 项目包含其他非核心目录（niri/, noctalia/, Aur/, python/），这些是模板附带的外部项目

## Requirements

1. **脚本模块化** — 将 `init-project.sh` 拆分为多个独立职责的文件
2. **消除嵌入式代码** — Step 5 的嵌入式 Python 提取为独立文件
3. **明确模块边界** — 每个模块有清晰职责和接口
4. **可测试性** — 核心逻辑可以独立测试（至少 Plan 决策逻辑）
5. **向前兼容** — 重构后功能和 CLI 交互流程不变
6. **配置外部化** — 模板路径等常量集中管理

## Acceptance Criteria

- [ ] `init-project.sh` 拆分为 ≤100 行的入口文件，职责为解析参数 + 调用子模块
- [ ] Plan 决策逻辑提取为独立模块，可被单独断言测试
- [ ] 嵌入式 Python 提取为独立 `.py` 文件
- [ ] Step 函数拆分到独立文件（如 `steps/` 目录）
- [ ] `bash -n` 对所有 shell 脚本通过
- [ ] 交互流程与重构前一致（手动测试验证）
- [ ] template 路径等常量集中到配置文件或变量

## Out of Scope

- 非核心目录（niri/, noctalia/, Aur/, python/）不在重构范围内
- 不改动 templates/ 目录的内容格式
- 不改动 opencode.json 的 MCP 配置结构
- 不改动 .trellis/ 的技能体系

## Spec Update

本次重构无需更新 .trellis/spec/。产出架构模式（4 文件拆分、嵌入式代码提取、bats 测试）是项目特定的结构决策，不属于通用工程规范。

## Decisions Made

- **模块化方案**: 拆分为 4 个文件：入口脚本 + utils.sh + plan.sh + steps.sh
- **测试框架**: 引入 bats 覆盖 Plan 决策 + 辅助函数
- **Step 调度**: 保持函数直接调用，不引入调度器
