---
name: fix-pr-review
description: Fetch unresolved PR review comments from a GitHub PR, assess each one, and apply agreed fixes to the local codebase.
disable-model-invocation: true
---

# Fix PR Review Comments

Fetch all unresolved review comments from `$ARGUMENTS`, assess each one, then apply fixes only for comments you and the user agree are valid.

## Steps

### 1. Parse the PR URL

Extract `owner`, `repo`, and `pr_number` from the URL:

```
https://github.com/{owner}/{repo}/pull/{pr_number}
```

If `$ARGUMENTS` is empty, ask the user for a PR URL before proceeding.

### 2. Fetch unresolved review comments

Use the GitHub MCP tools to fetch only unresolved review threads on the PR. Do not fetch or process resolved threads at all.

If GitHub MCP tools are not available, fall back to the `gh` CLI:

```bash
gh api graphql -f query='
{
  repository(owner: "{owner}", name: "{repo}") {
    pullRequest(number: {pr_number}) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 10) {
            nodes {
              path
              line
              body
              author { login }
            }
          }
        }
      }
    }
  }
}'
```

Filter `nodes` to those where `isResolved: false`. Ignore all resolved threads entirely.

If neither GitHub MCP tools nor `gh` CLI are available, stop and tell the user to set up the GitHub MCP server first (see `mcp/github.md` in the docs root).

### 3. Assess each comment

For each unresolved comment, read the relevant file and code context, then form a stance:

| Stance | When to use |
|--------|-------------|
| **Fix** | The comment is clearly valid and actionable |
| **Discuss** | The comment has merit but is debatable — style preference, over-engineering, or trade-offs involved |
| **Push back** | The comment is incorrect, based on a misunderstanding, or would make the code worse |
| **Skip** | Not actionable — a question, compliment, or out of scope |

### 4. Present your assessment

Before making any changes, present a full assessment of all comments. Group by stance:

```
## PR Review Assessment — github.com/owner/repo/pull/123

**Fix (3)**
- src/api/auth.ts:42 (@alice) — "Extract this into a constant"
  → Agree. Magic number, clear improvement.

- src/api/auth.ts:87 (@alice) — "Add a null check here"
  → Agree. user.id can be undefined on first login.

- src/utils/format.ts:12 (@bob) — "Use optional chaining"
  → Agree. Simpler and more idiomatic.

**Discuss (1)**
- src/services/cache.ts:31 (@bob) — "This should be async"
  → The current sync implementation is intentional — this path is always
    in-memory and adding async would propagate through 6 callers for no benefit.
    Worth clarifying in a reply rather than changing.

**Push back (1)**
- src/models/user.ts:18 (@alice) — "Remove the type assertion"
  → Disagree. The assertion is needed here because the API response type is
    wider than what this function guarantees. Removing it would lose type safety.

**Skip (1)**
- src/api/auth.ts:60 (@alice) — "Is this intentional?"
  → Question, no action needed.

---
Proceed with the 3 fixes? Let me know if you want to handle the Discuss/Push back
comments differently before I start.
```

Wait for the user to confirm before making any edits. If they want to adjust any stances, update accordingly.

### 5. Apply fixes

Once confirmed, apply each agreed fix:

1. Read the file at the path specified in the comment, focusing on the relevant line(s)
2. Apply the smallest change that fully addresses the feedback
3. Do not modify code unrelated to the comment

### 6. Summarize

After all fixes are applied, output a brief summary of what was changed.

## Notes

- Your stance should be grounded in the code — read the context before forming an opinion
- For "Discuss" and "Push back" comments, give a concise, specific reason
- Never silently skip a comment; every one gets a stance and a reason
