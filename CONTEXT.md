# Project Initialization

定义项目模板化初始化的过程、条件和产出物。

## Language

**项目初始化 (Project Init)**:
将当前目录变为一个可按技能组工作的开发环境的入口脚本。
_Avoid_: 项目创建（不创建项目，只配置已有目录）

**代码库 (Codebase)**:
包含 `src/` 目录或常见源代码文件（`*.py`, `*.js`, `*.ts`, `*.rs`, `*.go`, `*.java`, `*.c`, `*.cpp`, `*.h`, `*.rb`, `*.php`, `*.cs`）或构建文件（`Cargo.toml`, `go.mod`, `pom.xml`, `build.gradle`）的项目。
_Avoid_: 项目、仓库（这些范围更宽）

**CodeGraph 索引**:
对项目代码进行静态分析并构建知识图谱的后置步骤。仅对检测到的代码库以用户确认后执行。
_Avoid_: 自动索引（必须用户确认）
