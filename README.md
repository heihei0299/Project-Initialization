# project-init

个人项目初始化模板。支持 OpenCode / Claude 双工具选择，可选安装 Matt Pocock Skills 或 Trellis 技能组。

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
| 3 | 写入 `opencode.json`（MCP 配置） | 选 OpenCode 时 |
| 4 | 写入 `.claude/settings.json`（MCP 配置） | 选 Claude 时 |
| 5 | 安装技能组（Matt Pocock Skills / Trellis） | 按选择 |
| 6 | 注入 OpenCode 命令别名 (`grw`/`gm`/`tp`/`tc`/`cw`/`implement`) | OpenCode + Matt's Skills 时 |
| 7 | 写入 `AGENTS.md` / `CLAUDE.md`（CodeGraph 指令） | 按工具选择 |
| 8 | CodeGraph 索引（可选，始终询问用户） | 共用 |

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
├── gitignore              → 新项目的 .gitignore
├── opencode.json          → 新项目的 opencode.json
├── claude-settings.json   → 新项目的 .claude/settings.json
├── AGENTS.md              → 新项目的 AGENTS.md / CLAUDE.md
└── CLAUDE.md              → （已弃用，从 AGENTS.md 拷贝）
```

修改对应文件即可，无需改动 `init-project.sh` 本身。

---

### 结构说明

```
├── init-project.sh            — 入口脚本（source + 编排，29 行）
├── lib/
│   ├── config.sh              — 常量、模板映射、选项数据
│   ├── utils.sh               — 辅助函数（ensure_file, cmd_available, try_install 等）
│   ├── plan.sh                — 决策模块（用户交互、PLAN 构造、格式化函数）
│   └── steps.sh               — 执行模块（step1~6，从 config 读取配置）
├── scripts/
│   └── inject-aliases.py      — 命令别名注入脚本
├── tests/
│   └── plan.bats              — bats 测试套件
├── templates/
│   ├── gitignore              — 覆盖全场景的 .gitignore
│   ├── opencode.json          — MCP 服务器配置 + 命令别名
│   ├── claude-settings.json   — Claude MCP 服务器配置
│   └── AGENTS.md              — CodeGraph 指令文档
├── docs/
│   └── adr/                   — 架构决策记录
├── opencode.json              — opencode MCP 配置
├── CONTEXT.md                 — 领域术语表
├── skills-lock.json           — skills 版本锁定
├── package.json               — devDependencies（bats）
└── .agents/skills/            — Matt Pocock Skills（预安装）
```

### 相关技巧

- **skills 更新**: `.agents/skills/` 和 `skills-lock.json` 由 `npx skills@latest add mattpocock/skills` 管理
- **新增步骤**: 编辑 `init-project.sh`，在对应位置添加新步骤，使用 `ensure_file` 保持幂等
- **opencode.json**: 编辑 `templates/opencode.json` 即可，别名在 Step 6 自动注入
