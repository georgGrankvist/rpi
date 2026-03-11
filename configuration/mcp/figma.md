# Figma MCP Server

Figma's official MCP server. Provides tools for extracting design context, variables/tokens, component mappings, and screenshots from Figma files.

**Endpoint**: `https://mcp.figma.com/mcp`
**Auth**: OAuth (browser flow on first use)

## Plans & Seats

The remote server works on **all Figma plans including free**. You do not need a Dev or Full seat — a viewer account is sufficient for read operations.

The desktop server (`localhost:3845`) adds design creation tools but requires a paid Dev/Full seat and the Figma desktop app. Not covered here.

## Claude Code Setup

Run once to register the server:

```bash
claude mcp add --scope user --transport http figma https://mcp.figma.com/mcp
```

Then authenticate:

1. Start a new Claude Code session
2. Run `/mcp`
3. Select **figma** from the list
4. Choose **Authenticate**
5. Complete the OAuth flow in your browser
6. Verify with `/mcp` — figma should show as connected

**Management commands:**

```bash
claude mcp list          # Show all connected servers
claude mcp get figma     # View figma server details
claude mcp remove figma  # Disconnect
```

## Cursor Setup

1. Cursor → Settings → Cursor Settings → MCP
2. Click **+ Add new global MCP server**
3. Paste:

```json
{
  "mcpServers": {
    "figma": {
      "type": "http",
      "url": "https://mcp.figma.com/mcp"
    }
  }
}
```

4. Click **Connect** and complete the OAuth flow in your browser

## Auto-approve Figma tool calls

By default Claude Code prompts for approval on every MCP tool call. To allow Figma tools to run without prompting, add this to `~/.claude/settings.json`:

```json
{
  "permissions": {
    "allow": [
      "mcp__figma__*"
    ]
  }
}
```

If the file already has a `permissions` block, just add `"mcp__figma__*"` to the existing `allow` array.

## Verify the Setup

In a Claude Code or Cursor session, ask:

> What Figma MCP tools are available?

You should see tools like `get_design_context`, `get_variable_defs`, `get_code_connect_map`, `get_screenshot`, `get_metadata`, etc.

## Tools Available

| Tool | What it returns |
|------|----------------|
| `get_design_context` | Layout, spacing, typography, colors for a selection — framework-specific code context |
| `get_variable_defs` | Design tokens: colors, spacing, typography defined as Figma variables |
| `get_code_connect_map` | Mappings between Figma component node IDs and codebase components |
| `get_screenshot` | Visual screenshot of the selection for layout fidelity |
| `get_metadata` | Sparse XML of node IDs, names, types, positions |
| `get_figjam` | FigJam diagram content as XML + screenshots |
| `whoami` | Authenticated user identity and plan info |

## Getting a Figma Node URL

To target a specific frame or component, right-click it in Figma → **Copy link to selection**. This gives a URL like:

```
https://www.figma.com/design/{file_id}/...?node-id={node_id}
```

Pass this URL directly to `/pull-figma-design`.
