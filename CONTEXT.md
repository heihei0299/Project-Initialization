# 领域术语表

## init-project.sh

项目初始化脚本，拉取模板、配置工具（OpenCode/Claude）、安装技能组（Matt Pocock Skills / Trellis）、初始化 CodeGraph。

_避免：_ 安装脚本、bootstrap

## Step

初始化流程中的逻辑步骤，平铺编号，不含字母后缀。

_避免：_ 步骤、phase

## Plan

Decision phase 的输出，Execution phase 的输入。结构化数据，携带用户的初始化选择：目标工具和技能组。

_避免：_ 配置、选择结果、参数

## Template

`templates/` 目录中的源文件，初始化时按条件复制到目标项目。包括 `.gitignore`、`opencode.json`、`claude-settings.json`、`AGENTS.md`。

_避免：_ 模板文件、配置模板
