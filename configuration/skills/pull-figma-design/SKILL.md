---
name: pull-figma-design
description: Pull design context from a Figma frame or component URL and summarize it for implementation.
disable-model-invocation: true
---

# Pull Figma Design

Extract design context from a Figma URL and produce a structured implementation brief: layout, tokens, existing component mappings, and a screenshot for visual reference.

## Steps

### 1. Parse the URL

Extract the `file_id` and `node_id` from `$ARGUMENTS`:

```
https://www.figma.com/design/{file_id}/...?node-id={node_id}
```

If `$ARGUMENTS` is empty, ask the user for a Figma frame or component URL before proceeding.

If Figma MCP tools are not available, stop and tell the user to set up the Figma MCP server first (see `mcp/figma.md` in the docs root).

### 2. Fetch design data in parallel

Use Figma MCP tools to fetch these in parallel:

1. **`get_metadata`** — node structure: IDs, names, types, hierarchy
2. **`get_design_context`** — layout, spacing, typography, colors, component usage
3. **`get_variable_defs`** — design tokens (colors, spacing, typography) as Figma variables
4. **`get_code_connect_map`** — mappings from Figma node IDs to codebase components
5. **`get_screenshot`** — visual screenshot of the selection

### 3. Produce an implementation brief

Present a structured brief with these sections. Omit any section where no relevant data was returned.

```
## Design Brief — {frame or component name}

### Visual
[Embed or describe the screenshot. Note any complex layout regions.]

### Layout & Structure
[Key layout decisions: flex direction, grid, nesting, responsive breakpoints if specified.
Reference specific spacing values. Note anything non-obvious from the visual alone.]

### Design Tokens
[List variables in use: color, spacing, typography. Use the variable names from Figma,
not raw hex/px values, so the implementer knows what token to reach for.]

### Existing Components
[List any Figma components that have Code Connect mappings — these already exist in the
codebase and should be used rather than reimplemented. Include the node ID and mapped
component name/path.]

### Implementation Notes
[Anything that would trip up an implementer: interactive states, accessibility notes,
conditional rendering, data requirements visible in the design, layers that suggest
animation or transitions.]
```

### 4. Ask how to proceed

After presenting the brief, ask:

> Ready to implement this, or do you want to pull context for another frame first?

If the user wants to implement, proceed directly — the brief above is sufficient context to start writing code.

## Notes

- Prefer Figma variable names over raw values in the brief — they communicate design intent and map to code tokens
- If `get_code_connect_map` returns mappings, always highlight them prominently — using existing components is the most important thing to get right
- If the screenshot reveals states (hover, loading, error, empty) not visible in the node data, call them out explicitly
- For complex designs with multiple distinct regions, consider calling `get_design_context` separately on sub-frames for better granularity
