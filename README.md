# OPC Agents — Claude Code 版

一人公司（One Person Company）的 AI Agent 团队系统。

基于 Claude Code 构建，总指挥 Director + 9 个子 Agent 的调度式协作架构。

## 架构

1 个总指挥 + 9 个子 Agent：

| 角色 | 文件 | 中文名 | 职责 |
|------|------|--------|------|
| **Director** | `prompts/director.md` | 总指挥 | 调度决策、信息汇总、质量把关 |
| **Advisor** | `prompts/advisor.md` | 智囊 | 分析质疑、决策辅助、翻译桥梁 |
| **Dev** | `prompts/dev.md` | 工程师 | 代码实现、技术方案、部署运维 |
| **Product** | `prompts/product.md` | 产品经理 | 需求澄清、PRD 输出、竞品分析 |
| **UI-UX** | `prompts/ui-ux.md` | 设计师 | 界面设计、用户体验、设计系统 |
| **Guardian** | `prompts/guardian.md` | 哨兵 | 安全审查、技术债识别、风险巡检 |
| **Growth** | `prompts/growth.md` | 增长 | 增长运营、内容策略、市场调研 |
| **QA** | `prompts/qa.md` | 测试 | 测试验证、质量把关、Bug 管理 |
| **Finance** | `prompts/finance.md` | 财务 | 记账合规、定价、成本控制 |
| **AgentManager** | `prompts/agent-manager.md` | 管理者 | Agent 生命周期管理、质量评估 |

## 工作方式

1. 创始人发布任务 → **Director (总指挥)** 自动接收
2. Director 查归属表 → 读取 `prompts/{role}.md` 获取子 Agent 提示词
3. Director 通过 **Claude Code Agent tool** 派生子 Agent（`subagent_type: "general-purpose"`）
4. 子 Agent 独立运行完成任务 → Director 审查产出 → 汇总报告给创始人

**你只需要说需求，Director 自动调度。每个子 Agent 独立运行，有独立的上下文。**

## 快速开始

1. Clone 本仓库
2. 在目录下启动 Claude Code
3. Director 自动运行，执行每日自检
4. 直接发任务，Director 会自动调度子 Agent

## 任务分级

| 级别 | 场景 | 调用谁 |
|------|------|--------|
| L0 | 格式调整、简单问答 | Director 自己搞定 |
| L1 | 代码小改、需求分析 | 调 1 个子 Agent |
| L2 | 功能开发、技术方案 | 调 2-3 个，走流水线 |
| L3 | 架构决策、产品方向 | 全员 + 创始人确认 |

## 开发流水线

需求澄清(Product) → 设计(UI-UX) → 技术方案(Dev+Advisor) → 实现(Dev) → 验证(QA) → 归档(Director)

## 文件结构

```
CLAUDE.md                   总指挥系统提示词（Claude Code 入口）
prompts/
├── director.md              完整 Director 提示词参考
├── advisor.md               9 个子 Agent 提示词
├── dev.md
├── product.md
├── ui-ux.md
├── qa.md
├── guardian.md
├── growth.md
├── finance.md
└── agent-manager.md
scripts/
├── auto-check.sh            每日自检
├── quality-gate.sh          质量门禁
└── state-manager.py         状态管理（含中断恢复）
templates/                   项目模板
```

## 环境变量

```bash
# 可选（默认 ~/code/opc/opc-knowledge）
export OPC_KNOWLEDGE_PATH="/path/to/opc-knowledge"
```

## 中断恢复

长任务中断后，新会话启动时 Director 自动检测未完成的任务并从中断点继续。

## 知识库

通过 MCP 接入 Obsidian，详见 CLAUDE.md 中的知识库配置。

## 原则

- Director 负责调度决策，子 Agent 负责执行
- QA 和 Guardian 的首要职责是质疑，不是配合
- 文档是交付物的一部分
- 不读取上下文就开工 = 返工
- 知识有保质期，超过 180 天需复审
