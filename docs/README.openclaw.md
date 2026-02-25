# Superpowers for OpenClaw

Complete guide for using Superpowers with OpenClaw's multi-agent platform.

## Quick Install

```bash
git clone https://github.com/maloqab/superpowers-openclaw.git /tmp/superpowers-openclaw
/tmp/superpowers-openclaw/install.sh
openclaw gateway restart
```

## Manual Installation

### Prerequisites

- Git
- OpenClaw installed and configured (`~/.openclaw/` directory exists)
- At least one agent configured

### macOS / Linux

1. **Clone superpowers:**
   ```bash
   git clone https://github.com/obra/superpowers.git ~/.openclaw/superpowers
   ```

2. **Create skill symlinks:**
   ```bash
   mkdir -p ~/.openclaw/skills
   for skill in ~/.openclaw/superpowers/skills/*/; do
     name=$(basename "$skill")
     [ ! -e ~/.openclaw/skills/"$name" ] && ln -s "$skill" ~/.openclaw/skills/"$name"
   done
   ```

3. **Restart gateway:**
   ```bash
   openclaw gateway restart
   ```

### Verify

```bash
openclaw skills list
```

Look for superpowers skills listed as `openclaw-managed`:
```
✓ ready   📦 brainstorming       openclaw-managed
✓ ready   📦 test-driven-        openclaw-managed
✓ ready   📦 systematic-         openclaw-managed
...
```

## How OpenClaw Discovers Skills

OpenClaw scans three locations for skills at session boot, in priority order:

1. **Workspace skills** (`<workspace>/skills/`) — highest priority, project-specific
2. **Managed skills** (`~/.openclaw/skills/`) — user-installed, where superpowers goes
3. **Bundled skills** (`<openclaw-install>/skills/`) — shipped with OpenClaw

Each skill is a directory containing a `SKILL.md` file with YAML frontmatter:

```yaml
---
name: skill-name
description: Use when [triggering conditions]
---

# Skill Content
...
```

When an agent session starts, OpenClaw:
1. Scans all three locations
2. Parses each `SKILL.md` frontmatter
3. Filters by requirements (binaries, env vars, config)
4. Applies per-agent skill allowlists (if configured)
5. Injects eligible skills into the agent's context

No hooks, plugins, or bootstrap scripts needed. Native discovery.

## Skill Sources

| Source | Location | Priority |
|--------|----------|----------|
| `openclaw-workspace` | `<workspace>/skills/` | Highest |
| `openclaw-managed` | `~/.openclaw/skills/` | Medium |
| `openclaw-bundled` | OpenClaw install dir | Lowest |

Superpowers skills appear as `openclaw-managed` since they're symlinked into `~/.openclaw/skills/`.

## Managing Skills

### List all skills
```bash
openclaw skills list
```

### Get skill details
```bash
openclaw skills info brainstorming
```

### Check readiness
```bash
openclaw skills check
```

## Filtering Skills Per Agent

By default, all agents see all installed skills. To restrict skills per agent, add a `skills` array to the agent config in `openclaw.json`:

```json
{
  "agents": {
    "list": [
      {
        "name": "coder",
        "skills": ["test-driven-development", "systematic-debugging", "verification-before-completion"]
      },
      {
        "name": "reviewer",
        "skills": ["systematic-debugging", "verification-before-completion"]
      }
    ]
  }
}
```

See [agent-roles.md](agent-roles.md) for recommended per-role mappings.

## Multi-Agent Integration

### Adding skill awareness to agents

Superpowers skills are discoverable, but agents perform best when their SOUL.md explicitly tells them which skills to use. Add a "Skills" section to each agent's SOUL.md:

```markdown
## Skills — Use Them

You have workflow skills available. Before starting any task, check
if a relevant skill applies. If a skill exists for what you're doing,
use it. No exceptions.

- **test-driven-development** — Before writing any feature or bugfix code.
- **systematic-debugging** — Before attempting any fix for a bug.
- **verification-before-completion** — Before claiming work is done.
```

Pre-built templates for common roles (coder, orchestrator, reviewer, researcher, writer) are available in the `templates/` directory.

### Orchestrator delegation pattern

When an orchestrator delegates to a coder:
1. Orchestrator uses **writing-plans** to create an implementation plan
2. Orchestrator delegates the plan to the coder agent
3. Coder uses **executing-plans** to work through it
4. Coder uses **test-driven-development** for each task
5. Coder uses **verification-before-completion** before reporting done
6. Orchestrator uses **requesting-code-review** to route to reviewer
7. Reviewer uses **systematic-debugging** to investigate issues

The skills compose naturally across agents in the workflow.

## Tool Mapping

Superpowers skills were written for Claude Code. When skills reference Claude Code tools, here are the OpenClaw equivalents:

| Superpowers Reference | OpenClaw Equivalent |
|----------------------|---------------------|
| `TodoWrite` | Agent's task tracking or plan tool |
| `Task` (subagents) | Delegate to another agent via Slack channel |
| `Skill` tool | `openclaw skills info <name>` or native skill discovery |
| `Read` / `Write` / `Edit` | Agent's native file tools |
| `Bash` | Agent's `exec` tool |
| `EnterPlanMode` | Agent's planning workflow |

## Architecture

```
~/.openclaw/
├── superpowers/                    # Git clone (source of truth)
│   └── skills/
│       ├── brainstorming/SKILL.md
│       ├── test-driven-development/SKILL.md
│       └── ...
├── skills/                         # Managed skills directory
│   ├── brainstorming -> ../superpowers/skills/brainstorming/
│   ├── test-driven-development -> ../superpowers/skills/test-driven-development/
│   ├── frontend-design/            # Your custom skills (untouched)
│   └── ...
└── openclaw.json                   # Main config
```

Individual symlinks (not a single directory symlink) because:
- OpenClaw expects flat skill directories directly under `skills/`
- Enables selective installation of specific skills
- Preserves existing custom skills without conflicts

## Updating

```bash
cd ~/.openclaw/superpowers && git pull
```

Existing skill content updates instantly through symlinks. If upstream adds new skills, re-run the installer to create symlinks for them:

```bash
/path/to/superpowers-openclaw/install.sh
```

## Troubleshooting

### Skills not showing up after install

1. Did you restart the gateway? `openclaw gateway restart`
2. Check symlinks: `ls -la ~/.openclaw/skills/ | grep superpowers`
3. Verify skill format: `openclaw skills check`

### Agent not using skills

Skills are discoverable but agents work best with explicit instructions. Add a "Skills" section to the agent's SOUL.md — see `templates/` for examples.

### Symlink points to wrong location

Use `--force` flag to override: `./install.sh --force`

### Existing skill conflict

If you have a custom skill with the same name as a superpowers skill, the installer skips it. To use the superpowers version instead, rename or remove your custom skill first.

### Checking what's installed

```bash
# List all superpowers symlinks
ls -la ~/.openclaw/skills/ | grep "^l" | grep superpowers

# Check via OpenClaw
openclaw skills list | grep "openclaw-managed"
```
