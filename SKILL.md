---
name: super-power
description: 超能力开发工作流技能集合，为AI Agent提供完整的软件开发超能力：TDD测试驱动开发、系统化调试、头脑风暴、项目规划、并行子agent调度、代码评审等14项核心开发能力。激活当用户需要高效软件开发、多agent协作、项目管理等开发相关工作时。
---

# Super Power 超能力开发技能集合

> Reference-only note: 本文件用于汇总开发工作流技能集合与使用导览；系统级规则与运行约定以 `SOUL.md`、`AGENTS.md`、`HEARTBEAT.md` 的分层定义为准，其中长期硬规则以 `SOUL.md` 为准。本技能解决的是开发工作流 how，不并列定义系统母规则。

为OpenClaw Agent提供经过实战验证的完整软件开发工作流能力，覆盖从需求到上线的全流程。

## 🚀 核心技能清单

### 1. 开发类技能
| 技能名称 | 功能描述 | 适用场景 |
|---------|---------|---------|
| **test-driven-development** | RED-GREEN-REFACTOR测试驱动开发流程强制 | 编写代码、功能开发 |
| **systematic-debugging** | 四阶段根因问题定位方法论 | 排查bug、性能问题、系统故障 |
| **using-git-worktrees** | 多分支并行开发的隔离工作区管理 | 同时开发多个功能、快速切换分支 |
| **finishing-a-development-branch** | 分支合并、PR提交、代码清理工作流 | 功能开发完成后上线流程 |

### 2. 规划类技能
| 技能名称 | 功能描述 | 适用场景 |
|---------|---------|---------|
| **brainstorming** | 结构化头脑风暴与方案探索 | 项目初期设计、技术选型 |
| **writing-plans** | 项目拆解为可执行的小任务 | 复杂项目规划、工作量评估 |
| **executing-plans** | 带评审检查点的批量任务执行 | 按计划推进项目、阶段验收 |

### 3. 协作类技能
| 技能名称 | 功能描述 | 适用场景 |
|---------|---------|---------|
| **dispatching-parallel-agents** | 并发调度多个独立子agent工作 | 大型项目并行开发、多任务同时处理 |
| **subagent-driven-development** | 按任务派发子agent并自动评审结果 | 复杂任务拆分、降低主agent复杂度 |
| **requesting-code-review** | 结构化代码评审请求生成 | 代码提交前评审、质量把控 |
| **receiving-code-review** | 代码评审反馈处理与改进 | 响应评审意见、代码优化 |

### 4. 通用类技能
| 技能名称 | 功能描述 | 适用场景 |
|---------|---------|---------|
| **verification-before-completion** | 任务完成前的证据校验机制 | 确保交付物质量、避免"假完成" |
| **writing-skills** | 新Agent技能的创建与测试流程 | 扩展Agent能力、开发自定义技能 |
| **using-superpowers** | 超能力技能的发现与使用指南 | 了解所有可用能力、最佳实践 |

## 🎯 Agent角色模板

根据不同的Agent角色，可以选择不同的技能组合：

### 👨💻 Coder（开发工程师）
适用技能：`test-driven-development`, `systematic-debugging`, `verification-before-completion`, `using-git-worktrees`, `executing-plans`
> 适合编写代码、调试问题、实现功能的Agent

### 🎬 Orchestrator（协调者）
适用技能：`brainstorming`, `writing-plans`, `dispatching-parallel-agents`, `subagent-driven-development`, `requesting-code-review`
> 适合项目管理、任务分配、多agent协调的Agent

### 🔍 Reviewer（评审者）
适用技能：`systematic-debugging`, `verification-before-completion`, `receiving-code-review`, `finishing-a-development-branch`
> 适合代码评审、质量把控、验收交付的Agent

### 📚 Researcher（研究者）
适用技能：`brainstorming`, `systematic-debugging`, `verification-before-completion`, `writing-plans`
> 适合技术调研、方案探索、可行性分析的Agent

### ✍️ Writer（创作者）
适用技能：`brainstorming`, `writing-plans`, `writing-skills`, `verification-before-completion`
> 适合文档编写、技能开发、内容创作的Agent

## 💡 使用示例

### 场景1：开发新功能
```
用户：帮我开发一个待办事项管理系统
Agent自动触发技能链：
1. brainstorming → 设计系统功能架构和技术栈
2. writing-plans → 拆解为数据库设计、API开发、前端开发三个任务
3. dispatching-parallel-agents → 派发给三个子agent并行开发
4. receiving-code-review → 汇总子agent的代码并进行评审
5. verification-before-completion → 验证功能完整性和正确性
6. finishing-a-development-branch → 提交PR并准备上线
```

### 场景2：排查线上bug
```
用户：线上支付功能报错，帮忙定位问题
Agent自动触发技能链：
1. systematic-debugging → 收集日志、复现问题、定位根因
2. test-driven-development → 编写测试用例修复问题
3. verification-before-completion → 验证修复效果，确保没有回归
4. finishing-a-development-branch → 提交hotfix上线
```

## 📦 安装使用

### 手动安装步骤
1. 克隆superpowers仓库：
   ```bash
   git clone https://github.com/obra/superpowers.git ~/.openclaw/superpowers
   ```

2. 创建技能软链接：
   ```bash
   mkdir -p ~/.openclaw/skills
   for skill in ~/.openclaw/superpowers/skills/*/; do
     name=$(basename "$skill")
     [ ! -e ~/.openclaw/skills/"$name" ] && ln -s "$skill" ~/.openclaw/skills/"$name"
   done
   ```

3. 重启OpenClaw网关：
   ```bash
   openclaw gateway restart
   ```

### 验证安装
```bash
openclaw skills list | grep -E "(test-driven|debugging|brainstorming)"
```

## 🔄 更新维护
```bash
# 更新技能到最新版本
cd ~/.openclaw/superpowers && git pull

# 重启网关生效
openclaw gateway restart
```

## 📚 参考资源
- `templates/`目录：各角色Agent的配置模板
- `docs/agent-roles.md`：完整的角色-技能映射表
- `docs/README.openclaw.md`：平台安装详细指南
