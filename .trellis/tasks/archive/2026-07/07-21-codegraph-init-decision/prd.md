# codegraph：由用户决定是否初始化

## Goal

`init-project.sh` 初始化项目时，codegraph 索引的创建应由用户自主决定，不受源码检测结果影响。

## Background

当前 `step6_codegraph()` 的行为：
1. 通过 `detect_codebase()` 检测是否存在 `src/` 目录、源码文件或构建文件
2. **检测到源码** → 询问用户"是否初始化 CodeGraph 索引？"
3. **未检测到源码** → 直接跳过，不询问用户

AGENTS.md 的 CodeGraph 章节和 codegraph_explore MCP 工具的 instructions 均已正确声明"indexing is the user's decision"，无需修改。

## Requirements

- [ ] 移除 `init-project.sh` 中 `step6_codegraph()` 的 `detect_codebase` 守卫
- [ ] 无论是否检测到源码，均向用户询问"是否初始化 CodeGraph 索引？"
- [ ] 如果用户选择是且 `codegraph` CLI 已安装，则执行 `codegraph init`；否则跳过

## Out of Scope

- AGENTS.md / templates 中的 CodeGraph 描述文本
- codegraph MCP 工具的行为或描述
- `codegraph serve --mcp` 的配置

## Acceptance Criteria

- [ ] 在空目录（无任何源码文件）运行 `init-project.sh`，会询问"是否初始化 CodeGraph 索引？"
- [ ] 有源码文件的目录运行 `init-project.sh`，行为与之前相同（询问用户）
- [ ] 用户回答 n → 跳过；回答 y（且 codegraph 已安装）→ 执行 `codegraph init`
