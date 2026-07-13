# Project Initialization

个人项目初始化模板。包含一键初始化脚本和预配置的 Matt Pocock Skills。

## 使用方式

### 从模板创建新项目

```bash
# 克隆或从 GitHub 创建后将目录切换到新项目
cd my-new-project

# 运行初始化脚本
init-project.sh
```

脚本会先检测当前目录是否已初始化（检测 `.git/`），询问确认后进入选择流程。然后自动执行：

| Step | 操作 | 条件 |
|------|------|------|
| 1 | `git init` | 共用 |
| 2 | 写入 `.gitignore`（覆盖全场景） | 共用 |
| 3A | 写入 `opencode.json`（MCP 配置） | 选 OpenCode 时 |
| 3B | 写入 `.claude/settings.json`（MCP 配置） | 选 Claude 时 |
| 4 | 安装技能组（Matt Pocock Skills / Trellis） | 按选择 |
| 5A | 写入 `AGENTS.md`（CodeGraph 指令） | 选 OpenCode 时 |
| 5B | 写入 `CLAUDE.md`（CodeGraph 指令） | 选 Claude 时 |

所有步骤保持幂等，已存在则跳过。

### 安装到 PATH

```bash
cp init-project.sh ~/bin/init-project.sh
```

确保 `~/bin` 已在 `$PATH` 中。之后在任意空目录运行 `init-project.sh` 即可。

### 自定义模板内容

模板内容存储在 `templates/` 目录下：

```
templates/
├── gitignore          → 新项目的 .gitignore
├── opencode.json      → 新项目的 opencode.json
└── AGENTS.md          → 新项目的 AGENTS.md
```

修改对应文件即可，无需改动 `init-project.sh` 本身。

---

### 结构说明

```
├── init-project.sh      — 初始化脚本（五步走）
├── opencode.json        — opencode MCP 配置（symlink → templates/）
├── skills-lock.json     — skills 版本锁定
├── templates/
│   ├── gitignore        — 覆盖全场景的 .gitignore
│   ├── opencode.json    — MCP 服务器配置
│   └── AGENTS.md        — CodeGraph 指令文档
└── .agents/skills/      — Matt Pocock Skills（预安装）
```

### 相关技巧

- **skills 更新**: `.agents/skills/` 和 `skills-lock.json` 由 `npx skills@latest add mattpocock/skills` 管理
- **新增步骤**: 编辑 `init-project.sh`，在对应位置添加新步骤，使用 `ensure_file` 保持幂等
- **opencode.json**: 根目录为 symlink，编辑 `templates/opencode.json` 即可
