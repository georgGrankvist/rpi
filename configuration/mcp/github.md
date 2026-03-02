# GitHub MCP Server

GitHub's official MCP server, accessed via the GitHub Copilot HTTP endpoint. Provides tools for reading PRs, issues, files, and repository metadata.

**Endpoint**: `https://api.githubcopilot.com/mcp/`
**Auth**: GitHub Personal Access Token (PAT)

## PAT Scopes Required

For the tools used by `/fix-pr-review`:

- `repo` — read access to pull requests and code (classic PAT)
- Or fine-grained: **Pull requests** (read) + **Contents** (read)

Generate at: **GitHub → Settings → Developer settings → Personal access tokens**

## Cursor Setup

Add to `~/.cursor/mcp.json` (or `.cursor/mcp.json` in your project):

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer ${input:github_mcp_pat}"
      }
    }
  },
  "inputs": [
    {
      "type": "promptString",
      "id": "github_mcp_pat",
      "description": "GitHub Personal Access Token",
      "password": true
    }
  ]
}
```

Cursor will prompt for your PAT on first use and cache it securely.

## Claude Code Setup

Run once to register the server globally:

```bash
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
```

Then edit `~/.claude/mcp.json` to add the Authorization header (Claude Code's CLI does not yet support header flags directly):

```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/",
      "headers": {
        "Authorization": "Bearer YOUR_PAT_HERE"
      }
    }
  }
}
```

Replace `YOUR_PAT_HERE` with your PAT. For security, consider using a shell expansion via your shell profile instead of storing the token in plain text — set `GITHUB_MCP_PAT` in your `.zshrc` / `.bashrc` and reference it as `$GITHUB_MCP_PAT`. Some Claude Code versions support env var substitution in MCP config; check your version's docs.

## Verify the Setup

In a Claude Code or Cursor session, ask:

> What GitHub MCP tools are available?

You should see tools like `list_pull_request_review_comments`, `get_pull_request`, `get_file_contents`, etc.
