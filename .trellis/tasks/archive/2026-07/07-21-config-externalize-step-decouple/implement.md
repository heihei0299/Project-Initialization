# 执行计划

## 步骤

### Step 1: 创建 lib/config.sh

- 从 plan.sh 迁移 `TEMPLATES_DIR` 常量
- 定义 `TEMPLATE_MAP` 数组（替换 step3_templates 的内联数组）
- 任何其他可配置常量

### Step 2: 更新 plan.sh

- 移除 `TEMPLATES_DIR` 定义（迁移到 config.sh）
- source config.sh

### Step 3: 更新 init-project.sh

- source config.sh 在 steps.sh 之前

### Step 4: 更新 steps.sh

- step2_gitignore 确认使用 `$TEMPLATES_DIR`
- step3_templates 读取 `$TEMPLATE_MAP` 替代内联数组

### Step 5: 验证

```bash
bash -n init-project.sh lib/*.sh
bats tests/
# 手动运行确认交互不变
```

## 验证命令

```bash
bash -n init-project.sh lib/config.sh lib/utils.sh lib/plan.sh lib/steps.sh
bats tests/
```
