# Agent Role Skill Mapping

## Overview

Not every skill is relevant to every agent. This guide maps the right superpowers skills to common agent roles in OpenClaw multi-agent setups.

## Role Definitions

| Role | Responsibility |
|------|---------------|
| **Coder** | Writes code, runs tests, commits, pushes. The builder. |
| **Orchestrator** | Coordinates work across agents, delegates tasks, verifies deliverables. |
| **Reviewer** | Reviews code, runs builds/tests, provides evidence-based feedback. |
| **Researcher** | Investigates topics, verifies sources, synthesizes findings. |
| **Writer** | Writes articles, documentation, content. Edits and polishes. |

## Complete Mapping

| Skill | Coder | Orchestrator | Reviewer | Researcher | Writer |
|-------|:-----:|:------------:|:--------:|:----------:|:------:|
| using-superpowers | x | x | x | x | x |
| brainstorming | x | x | | x | x |
| writing-plans | x | x | | x | x |
| executing-plans | x | | | | |
| subagent-driven-development | x | x | | | |
| test-driven-development | x | | x | | |
| systematic-debugging | x | | x | x | |
| dispatching-parallel-agents | x | x | | | |
| requesting-code-review | | x | x | | |
| receiving-code-review | x | | x | | |
| verification-before-completion | x | x | x | x | x |
| using-git-worktrees | x | | | | |
| finishing-a-development-branch | x | | | | |
| writing-skills | | | | | x |

## Rationale

### Universal skills (all roles)
- **using-superpowers** — Every agent needs to know how to discover and use skills.
- **verification-before-completion** — Every agent should prove their work before claiming done.

### Coder-heavy skills
- **test-driven-development** — Core discipline for any code-writing agent.
- **systematic-debugging** — Structured root cause investigation before random fixes.
- **executing-plans** — Coders execute plans; orchestrators create them.
- **using-git-worktrees** — Isolation for feature work is a coder concern.
- **finishing-a-development-branch** — Merge/PR workflow is coder-initiated.
- **receiving-code-review** — Coders receive and act on review feedback.

### Orchestrator-heavy skills
- **brainstorming** — Design exploration before delegating work.
- **writing-plans** — Breaking projects into implementation plans.
- **dispatching-parallel-agents** — Coordinating concurrent work.
- **requesting-code-review** — Routing work to reviewers.

### Reviewer skills
- **systematic-debugging** — Reviewers investigate issues they find.
- **test-driven-development** — Reviewers check if TDD was followed.
- **requesting/receiving-code-review** — Both sides of the review workflow.

### Writer skills
- **writing-skills** — Writers may create process documentation or skills.
- **brainstorming** — Exploring article angles before writing.

## Customizing for Your Setup

### Custom roles

If you have agents with roles not listed above, combine the relevant skills from the mapping. For example, a "DevOps" agent might use coder + orchestrator skills.

### Filtering skills per agent in openclaw.json

You can restrict which skills each agent sees using the `agents.list[].skills` field:

```json
{
  "agents": {
    "list": [
      {
        "name": "coder",
        "skills": [
          "test-driven-development",
          "systematic-debugging",
          "verification-before-completion",
          "executing-plans",
          "finishing-a-development-branch",
          "using-git-worktrees",
          "receiving-code-review",
          "brainstorming",
          "writing-plans"
        ]
      },
      {
        "name": "reviewer",
        "skills": [
          "systematic-debugging",
          "verification-before-completion",
          "test-driven-development",
          "requesting-code-review",
          "receiving-code-review"
        ]
      }
    ]
  }
}
```

This is optional. By default, all agents see all installed skills.
