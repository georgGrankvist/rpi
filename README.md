# rpi

Configuration and sub-agents for a **Research → Plan → Implement** workflow, supporting both Cursor and Claude Code.

## Directory Structure

```
rpi/
├── configuration/
│   ├── cursor/
│   │   ├── agents/       # Cursor sub-agents (model: fast/opus aliases)
│   │   └── commands/     # Cursor slash commands
│   ├── claude/
│   │   ├── agents/       # Claude Code sub-agents (model: haiku/sonnet)
│   │   └── commands/     # Claude Code slash commands (subagent_type-aware)
│   ├── skills/           # Shared Agent Skills (works in both Cursor and Claude Code)
│   │   └── fix-pr-review/
│   │       └── SKILL.md
│   └── mcp/              # MCP server setup guides
├── research/         # Research output from /research-codebase
├── planning/         # Implementation plans from /create-plan
└── install.sh        # Install script
```

## Installation

```bash
# Install for Cursor
./install.sh cursor

# Install for Claude Code
./install.sh claude
```

Each command installs tool-specific agents and commands, plus the shared skills from `configuration/skills/`.

For Claude Code, set `RPI_DOCS_DIR` in your shell profile so commands can locate the docs root from any project:

```bash
export RPI_DOCS_DIR="/path/to/rpi"
```

## Commands

### `/research-codebase`

Conducts comprehensive codebase research using parallel sub-agents.

- **Output**: `{docs_root}/research/YYYY-MM-DD-TICKET-description.md`
- **Usage**: `/research-codebase` then describe what you want to research
- **Sub-agents used**: codebase-locator, codebase-analyzer, codebase-pattern-finder, research-locator

### `/create-plan`

Creates detailed implementation plans through interactive research and iteration.

- **Output**: `{docs_root}/planning/YYYY-MM-DD-TICKET-description.md`
- **Usage**: `/create-plan` or `/create-plan path/to/ticket.md`
- **Sub-agents used**: codebase-locator, codebase-analyzer, codebase-pattern-finder, research-locator, research-analyzer

### `/implement-plan`

Implements approved technical plans with verification checkpoints.

- **Usage**: `/implement-plan path/to/plan.md`
- **Sub-agents used**: verifier

## Skills

Skills follow the [Agent Skills](https://agentskills.io) open standard and work in both Cursor and Claude Code.

### `/fix-pr-review`

Fetches unresolved review comments from a GitHub PR and applies fixes to the local codebase.

- **Usage**: `/fix-pr-review https://github.com/owner/repo/pull/123`
- **Requires**: GitHub MCP server (see `configuration/mcp/github.md`)

## MCP Servers

Some commands require MCP servers. Setup guides live in `configuration/mcp/`:

| Server | Guide                         | Used by          |
| ------ | ----------------------------- | ---------------- |
| GitHub | `configuration/mcp/github.md` | `/fix-pr-review` |

## Sub-agents

| Agent                     | Model  | Description                                             |
| ------------------------- | ------ | ------------------------------------------------------- |
| `codebase-locator`        | haiku  | Finds WHERE files and components live                   |
| `codebase-analyzer`       | sonnet | Understands HOW specific code works with file:line refs |
| `codebase-pattern-finder` | haiku  | Finds similar implementations and patterns to follow    |
| `research-locator`        | haiku  | Discovers existing research/plans in the docs root      |
| `research-analyzer`       | sonnet | Extracts insights from prior research/plans             |
| `verifier`                | sonnet | Independently validates completed work                  |
| `web-search-researcher`   | haiku  | Searches web for documentation and best practices       |

## Workflow Example

```
1. Research the codebase
   > /research-codebase
   > How does user authentication work in the mono repo?

   Output: rpi/research/2025-01-26-authentication-flow.md

2. Create implementation plan
   > /create-plan rpi/research/2025-01-26-authentication-flow.md
   > Add OAuth2 support for external providers

   Output: rpi/planning/2025-01-26-TEC-1234-oauth2-support.md

3. Implement the plan
   > /implement-plan rpi/planning/2025-01-26-TEC-1234-oauth2-support.md
```

## Key Differences: Cursor vs Claude Code

|                      | Cursor                            | Claude Code                               |
| -------------------- | --------------------------------- | ----------------------------------------- |
| Model aliases        | `fast`, `opus`                    | `haiku`, `sonnet`, `claude-opus-4-6`      |
| Sub-agent invocation | `/agent-name` in prompt           | `subagent_type="agent-name"` in Task call |
| File referencing     | `@path/to/file`                   | Full path or `/add-dir`                   |
| Docs root            | Relative `rpi/` via workspace | `$RPI_DOCS_DIR` env var                    |

## File Naming Convention

Research and planning documents follow the format:

```
YYYY-MM-DD-TICKET-description.md
```

Examples:

- `2025-01-26-TEC-1234-add-oauth2-support.md`
- `2025-01-26-authentication-flow.md` (no ticket)
