# Superpowers for OpenClaw

Bring [superpowers](https://github.com/obra/superpowers) development workflow skills to [OpenClaw](https://openclaw.ai).

## Why

Superpowers gives coding agents a complete development workflow: brainstorming, planning, TDD, debugging, code review, and more. It works with Claude Code, Cursor, Codex, and OpenCode — but not OpenClaw.

**superpowers-openclaw** installs all 14 superpowers skills into OpenClaw's native skill system. Whether you run a single agent or a fleet of specialists, every agent gets access to battle-tested development workflows out of the box.

For multi-agent setups, role-based templates help you map the right skills to the right agents — coders get TDD and debugging, orchestrators get planning and delegation, reviewers get systematic investigation.

## What You Get

- **14 development workflow skills** available to your agents
- **Role-based templates** for common agent roles (coder, orchestrator, reviewer, researcher, writer)
- **One-command installer** with selective install, dry-run, and idempotent updates
- **Clean uninstaller** that never touches your custom skills
- **PR-ready adapter** (`.openclaw/`) for contributing OpenClaw support back to superpowers

## Quick Start

```bash
git clone https://github.com/maloqab/superpowers-openclaw.git
cd superpowers-openclaw
./install.sh
openclaw gateway restart
```

Verify:
```bash
openclaw skills list | grep openclaw-managed
```

## Skills Reference

| Skill | What It Does | Best For |
|-------|-------------|----------|
| **test-driven-development** | RED-GREEN-REFACTOR cycle enforcement | Coder |
| **systematic-debugging** | 4-phase root cause investigation | Coder, Reviewer |
| **verification-before-completion** | Evidence before claims of "done" | All agents |
| **brainstorming** | Design exploration before implementation | Coder, Orchestrator, Writer |
| **writing-plans** | Break projects into bite-sized tasks | Coder, Orchestrator |
| **executing-plans** | Batch execution with review checkpoints | Coder |
| **dispatching-parallel-agents** | Coordinate concurrent independent work | Coder, Orchestrator |
| **subagent-driven-development** | Per-task subagent dispatch with review | Coder, Orchestrator |
| **requesting-code-review** | Structured review requests | Orchestrator, Reviewer |
| **receiving-code-review** | Handle feedback without blind agreement | Coder, Reviewer |
| **using-git-worktrees** | Isolated workspace for feature branches | Coder |
| **finishing-a-development-branch** | Merge/PR/cleanup decision workflow | Coder |
| **writing-skills** | Create and test new skills | Writer |
| **using-superpowers** | How agents discover and use skills | All agents |

## Agent Role Templates

If you run multiple agents with different roles, copy the relevant template into each agent's SOUL.md:

| Role | Template | Key Skills |
|------|----------|-----------|
| **Coder** | [`templates/coder.md`](templates/coder.md) | TDD, debugging, verification, git worktrees |
| **Orchestrator** | [`templates/orchestrator.md`](templates/orchestrator.md) | Brainstorming, planning, parallel dispatch |
| **Reviewer** | [`templates/reviewer.md`](templates/reviewer.md) | Debugging, verification, code review |
| **Researcher** | [`templates/researcher.md`](templates/researcher.md) | Brainstorming, debugging, verification |
| **Writer** | [`templates/writer.md`](templates/writer.md) | Brainstorming, planning, writing skills |

Running a single agent? The **coder** template covers the broadest set of skills. See [`docs/agent-roles.md`](docs/agent-roles.md) for the complete mapping table and rationale.

## Customization

### Install only specific skills

```bash
./install.sh --skills brainstorming,test-driven-development,systematic-debugging
```

### Exclude specific skills

```bash
./install.sh --exclude writing-skills,using-superpowers
```

### Preview before installing

```bash
./install.sh --dry-run
```

### Filter skills per agent

Add a `skills` array to your agent config in `~/.openclaw/openclaw.json`:

```json
{
  "agents": {
    "list": [
      {
        "name": "coder",
        "skills": ["test-driven-development", "systematic-debugging", "verification-before-completion"]
      }
    ]
  }
}
```

## Updating

Skills update through symlinks — just pull:

```bash
cd ~/.openclaw/superpowers && git pull
```

If upstream adds new skills, re-run the installer to create symlinks for them.

## Uninstalling

```bash
./uninstall.sh
```

Options:
- `--yes` — skip confirmation
- `--purge` — also remove the superpowers clone
- `--skills LIST` — remove only specific skills

## How It Works

OpenClaw has native skill discovery: it scans `~/.openclaw/skills/` for directories containing `SKILL.md` files and injects them into agent sessions at boot. Superpowers skills use the same `SKILL.md` format with YAML frontmatter.

This project:
1. Clones superpowers to `~/.openclaw/superpowers/`
2. Creates individual symlinks from each skill into `~/.openclaw/skills/`
3. OpenClaw discovers them as `openclaw-managed` skills automatically

No plugins, hooks, or adapters needed. Native compatibility.

## Contributing to Superpowers

The `.openclaw/` directory in this repo is designed to be submitted as a PR to [obra/superpowers](https://github.com/obra/superpowers), adding OpenClaw as a supported platform alongside Claude Code, Cursor, Codex, and OpenCode.

## Docs

- [Detailed platform guide](docs/README.openclaw.md) — installation, architecture, troubleshooting
- [Agent role mapping](docs/agent-roles.md) — which skills for which agent roles

## License

MIT — see [LICENSE](LICENSE)

## Credits

- [Superpowers](https://github.com/obra/superpowers) by Jesse Vincent ([@obra](https://github.com/obra))
- [OpenClaw](https://openclaw.ai)
