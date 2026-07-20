# ADR-0001: init-project.sh 优化方案

## 决定

对 `init-project.sh` 实施 6 项优化，聚焦健壮性和可维护性。

## 理由

消除对 `python3` 的不必要硬依赖、规范 Step 编号、防止 `npx`/`codegraph` 命令失败导致脚本崩溃、去除模板重复。

## 具体改动

1. **Step 编号平铺 1-8** — 消除字母后缀（3A/3B/4B/5A/5B），改为平铺编号
2. **`$use_x &&` → `if then fi`** — 提高可读性，消除 `set -e` 交互隐患
3. **npx 包裹 `if ! npx ...`** — 安装失败时不退出脚本，给出清晰提示
4. **Python 依赖可选** — `if command -v python3` 检查，未安装时跳过别名注入
5. **模板去重** — CLAUDE.md 使用 templates/AGENTS.md 作为源，消除重复维护
6. **codegraph 可选** — `if command -v codegraph` 检查，未安装时跳过

## 状态

已接受。

## 后续变更

- **ADR-0002**: Step 编号从 1-8 压缩为 1-6（Plan/Execution seam，模板合并）
- **ADR-0004**: Step 编号进一步压缩为 1-5（.gitignore 合并到 templates）

当前 Step 编号为 1-5，定义在 `$STEP_LABELS` 数组中，修改时只需更新数组。
