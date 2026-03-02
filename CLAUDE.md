# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

A collection of AI workflow configurations implementing a **Research → Plan → Implement** pipeline for both Cursor and Claude Code. The repo contains command/agent definitions (in `configuration/`) and accumulates output artifacts (in `research/` and `planning/`, both gitignored).

## Installation

```bash
# Install agents, commands, and skills for Claude Code
./install.sh claude

# Install for Cursor
./install.sh cursor
```

After installing for Claude Code, set in your shell profile:
```bash
export RPI_DOCS_DIR="/path/to/this/repo"
```

This env var is how commands locate the `research/` and `planning/` output directories from any project.

## Repository Structure

```
configuration/
├── claude/
│   ├── agents/      # Sub-agent definitions (installed to ~/.claude/agents/)
│   └── commands/    # Slash command definitions (installed to ~/.claude/commands/)
├── cursor/
│   ├── agents/      # Cursor sub-agent definitions
│   └── commands/    # Cursor slash command definitions
├── skills/
│   └── fix-pr-review/SKILL.md   # Shared Agent Skill (both tools)
└── mcp/
    └── github.md    # GitHub MCP server setup guide

research/    # Output from /research-codebase (gitignored)
planning/    # Output from /create-plan (gitignored)
```

## The Three Commands

All three commands are installed as slash commands and reference the docs root (`$RPI_DOCS_DIR` for Claude Code, relative `rpi/` for Cursor).

### `/research-codebase`
Spawns parallel sub-agents (codebase-locator, codebase-analyzer, codebase-pattern-finder, research-locator) to research a question and writes output to `{docs_root}/research/YYYY-MM-DD[-TICKET]-description.md` with YAML frontmatter.

### `/create-plan`
Interactive, iterative plan creation. Reads ticket/context files first, then spawns research sub-agents, presents design options, and writes a phased implementation plan to `{docs_root}/planning/YYYY-MM-DD[-TICKET]-description.md`. Plans must have zero open questions before being finalized.

### `/implement-plan`
Takes a plan file path, reads it fully, implements phases sequentially, uses the `verifier` sub-agent after each phase, updates checkboxes in the plan file, and pauses for manual verification before proceeding to the next phase.

## Sub-agents

Seven named sub-agents live in `configuration/claude/agents/` (and mirrored in `configuration/cursor/agents/`):

| Agent | Model | Role |
|-------|-------|------|
| `codebase-locator` | haiku | Find WHERE files/components live |
| `codebase-analyzer` | sonnet | Understand HOW code works (with file:line refs) |
| `codebase-pattern-finder` | haiku | Find existing patterns to follow |
| `research-locator` | haiku | Find prior research/plans in the docs root |
| `research-analyzer` | sonnet | Extract insights from prior research docs |
| `verifier` | sonnet | Validate completed implementation work |
| `web-search-researcher` | haiku | Search web for docs/best practices |

In Claude Code commands, sub-agents are invoked via `Task(subagent_type="agent-name", ...)`. Never use `subagent_type: "explore"` — always use the named agents.

## The `/fix-pr-review` Skill

Defined in `configuration/skills/fix-pr-review/SKILL.md`. Fetches unresolved PR review comments via GitHub MCP (falls back to `gh` CLI), assesses each comment with a stance (Fix/Discuss/Push back/Skip), presents the full assessment before making any changes, then applies confirmed fixes.

Requires GitHub MCP server — setup documented in `configuration/mcp/github.md`.

## File Naming Convention

Research and planning output files follow:
```
YYYY-MM-DD-TICKET-description.md    # e.g., 2025-01-08-TEC-1478-oauth2-support.md
YYYY-MM-DD-description.md           # e.g., 2025-01-08-authentication-flow.md (no ticket)
```

## Key Architectural Notes

- Commands explicitly resolve the docs root at runtime (via `$RPI_DOCS_DIR` or conversation context) — they are not tied to the repo directory itself.
- The `configuration/claude/` and `configuration/cursor/` trees are parallel but not identical: model aliases differ (`haiku`/`sonnet` vs `fast`/`opus`) and sub-agent invocation syntax differs.
- Skills in `configuration/skills/` are tool-agnostic and installed to both `~/.claude/skills/` and `~/.cursor/skills/`.
- `research/` and `planning/` are gitignored — they contain project-specific output from the workflow, not repo source files.
