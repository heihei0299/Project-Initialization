# 配置外部化 + 步骤函数解耦

## Goal

在模块化拆分基础上，进一步消除步骤函数中的硬编码和配置内联，提升可维护性。

## Requirements

1. **配置外部化** — steps.sh 中所有模板路径、文件映射统一引用常量，消除重复字符串
2. **步骤函数解耦** — step3_templates 中的模板条目（条件→目标→源映射）提取为独立配置，不再内联在函数体中
3. **模块边界澄清** — TEMPLATES_DIR 等常量归口到单一模块管理

## Acceptance Criteria

- [ ] step2_gitignore 使用 `$TEMPLATES_DIR` 而非裸路径
- [ ] step3_templates 的模板映射提取为 `lib/config.sh` 或 `plan.sh` 中的可配置数组
- [ ] 所有模板路径引用统一通过变量而非字面量
- [ ] `bash -n` 对全部 .sh 文件通过
- [ ] bats 测试全部通过
- [ ] 交互流程不变

## Out of Scope

- 不改变模板文件内容
- 不改变步骤数量或执行顺序
- 不改动已存在的 ADR 文档

## Decisions Made

- **配置归属**: 新增 `lib/config.sh` 存放所有配置常量和映射数据
- **映射格式**: 保持 `IFS='|'` 分割的行格式，集中定义在 config.sh 的数组变量中
