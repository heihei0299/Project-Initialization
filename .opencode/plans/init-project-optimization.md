# init-project.sh 优化计划

## 改动清单

对 `/home/shial/Project/Project-Initialization/init-project.sh` 实施以下 6 项优化：

### 1. Step 编号平铺 1-8

```
[Step 1/6] → [Step 1/8]  git init
[Step 2/6] → [Step 2/8]  .gitignore
[Step 3A/6] → [Step 3/8]  opencode.json（条件）
[Step 3B/6] → [Step 4/8]  .claude/settings.json（条件）
[Step 4/6]  → [Step 5/8]  安装技能组（条件）
[Step 4B/6] → [Step 6/8]  命令别名注入（条件）
[Step 5A/6] → [Step 7/8]  AGENTS.md / CLAUDE.md（条件）
[Step 6/6]  → [Step 8/8]  CodeGraph 索引
```

### 2. `$use_x && echo` → `if $use_x; then echo; fi`

**行 106-109：**
```bash
# 改前
$use_opencode && echo "  • OpenCode 配置"
$use_claude   && echo "  • Claude 配置"
$use_mpskills && echo "  • Matt Pocock Skills"
$use_trellis  && echo "  • Trellis"
# 改后
if $use_opencode; then echo "  • OpenCode 配置"; fi
if $use_claude;   then echo "  • Claude 配置"; fi
if $use_mpskills; then echo "  • Matt Pocock Skills"; fi
if $use_trellis;  then echo "  • Trellis"; fi
```

**行 243-244：**
```bash
# 改前
echo " 工具: $($use_opencode && echo -n 'OpenCode ')$($use_claude && echo -n 'Claude')"
echo " 技能: $($use_mpskills && echo -n 'Matt Pocock Skills ')$($use_trellis && echo -n 'Trellis')"
# 改后
printf " 工具: "
if $use_opencode; then printf 'OpenCode '; fi
if $use_claude;   then printf 'Claude '; fi
echo ""
printf " 技能: "
if $use_mpskills; then printf 'Matt Pocock Skills '; fi
if $use_trellis;  then printf 'Trellis '; fi
echo ""
```

### 3. npx 包裹 `if ! npx ...`

**行 153：**
```bash
# 改前
npx skills@latest add mattpocock/skills
echo "  ✔ Matt Pocock Skills 已安装"
# 改后
if ! npx skills@latest add mattpocock/skills; then
  echo "  ⚠ 安装失败，请检查网络或手动重试"
else
  echo "  ✔ Matt Pocock Skills 已安装"
fi
```

**行 160：**
```bash
# 改前
npx @mindfoldhq/trellis init
echo "  ✔ Trellis 已安装"
# 改后
if ! npx @mindfoldhq/trellis init; then
  echo "  ⚠ 安装失败，请检查网络或手动重试"
else
  echo "  ✔ Trellis 已安装"
fi
```

### 4. Step 4B (新 Step 6/8): python3 包裹

```bash
if command -v python3 &>/dev/null; then
  python3 -c "..."
  echo "  ✔ 命令别名已注入"
else
  echo "  - python3 未安装，跳过命令别名注入"
fi
```

### 5. 模板去重：CLAUDE.md 使用 AGENTS.md 作为源

```bash
# 改前
ensure_file "CLAUDE.md" "$SCRIPT_DIR/templates/CLAUDE.md" "CLAUDE.md"
# 改后
ensure_file "CLAUDE.md" "$SCRIPT_DIR/templates/AGENTS.md" "CLAUDE.md"
```

### 6. Step 6 (新 Step 8/8): codegraph 包裹

```bash
if command -v codegraph &>/dev/null; then
  echo "  → 正在初始化 CodeGraph..."
  codegraph init
  echo "  ✔ CodeGraph 索引已创建"
else
  echo "  - codegraph CLI 未安装，跳过"
fi
```

## 后续步骤

- 创建 `CONTEXT.md`（领域术语表）
- 创建 `docs/adr/0001-init-script-optimization.md`（架构决策记录）

## 验证

- `bash -n init-project.sh` 检查语法
- 手动运行一次确认行为正确
