---
description: Create detailed implementation plans through interactive research and iteration
model: opus
---

# Implementation Plan

You are tasked with creating detailed implementation plans through an interactive, iterative process. You should be skeptical, thorough, and work collaboratively with the user to produce high-quality technical specifications.

## Initial Response

When this command is invoked:

1. **Check if parameters were provided**:
   - If a file path or ticket reference was provided as a parameter, skip the default message
   - Immediately read any provided files FULLY
   - Begin the research process

2. **If no parameters provided**, respond with:

```
I'll help you create a detailed implementation plan. Let me start by understanding what we're building.

Please provide:
1. The task/ticket description (or reference to a ticket/doc file)
2. Any relevant context, constraints, or specific requirements
3. Links to related research or previous implementations

I'll analyze this information and work with you to create a comprehensive plan.

Tip: You can also invoke this command with a file directly: `/create-plan docs/tickets/TEC-1234.md`
```

Then wait for the user's input.

## Process Steps

### Step 1: Context Gathering & Initial Analysis

1. **Read all mentioned files immediately and FULLY**:
   - Ticket files or task descriptions
   - Research documents
   - Related implementation plans
   - Any JSON/data files mentioned
   - **IMPORTANT**: Use the Read tool WITHOUT limit/offset parameters to read entire files
   - **CRITICAL**: DO NOT spawn sub-agents before reading these files yourself in the main context
   - **NEVER** read files partially - if a file is mentioned, read it completely

2. **Spawn initial research sub-agents to gather context**:
   Before asking the user any questions, use specialized sub-agents to research in parallel:
   - Delegate to **/codebase-locator** to find all files related to the ticket/task
   - Delegate to **/codebase-analyzer** to understand how the current implementation works
   - Delegate to **/research-locator** to find any existing research or plans about this feature

   Invoke these sub-agents in parallel using the Task tool:

   ```
   Task(prompt="Use /codebase-locator to find all files related to [feature/component]")
   Task(prompt="Use /codebase-analyzer to analyze how [system] currently works")
   Task(prompt="Use /research-locator to find existing research or plans in rpi/ related to [feature/topic]")
   ```

   These sub-agents will:
   - Find relevant source files, configs, and tests
   - Identify the specific directories to focus on
   - Trace data flow and key functions
   - Return detailed explanations with file:line references

3. **Read all files identified by research sub-agents**:
   - After research sub-agents complete, read ALL files they identified as relevant
   - Read them FULLY into the main context
   - This ensures you have complete understanding before proceeding

4. **Analyze and verify understanding**:
   - Cross-reference the ticket requirements with actual code
   - Identify any discrepancies or misunderstandings
   - Note assumptions that need verification
   - Determine true scope based on codebase reality

5. **Present informed understanding and focused questions**:

   ```
   Based on the ticket and my research of the codebase, I understand we need to [accurate summary].

   I've found that:
   - [Current implementation detail with file:line reference]
   - [Relevant pattern or constraint discovered]
   - [Potential complexity or edge case identified]

   Questions that my research couldn't answer:
   - [Specific technical question that requires human judgment]
   - [Business logic clarification]
   - [Design preference that affects implementation]
   ```

   Only ask questions that you genuinely cannot answer through code investigation.

### Step 2: Research & Discovery

After getting initial clarifications:

1. **If the user corrects any misunderstanding**:
   - DO NOT just accept the correction
   - Spawn new research sub-agents to verify the correct information
   - Read the specific files/directories they mention
   - Only proceed once you've verified the facts yourself

2. **Create a research todo list** using TodoWrite to track exploration tasks

3. **Spawn parallel sub-agents for comprehensive research**:
   Create multiple Task sub-agents to research different aspects concurrently.
   Use the right sub-agent for each type of research:

   **For deeper investigation:**
   - **/codebase-locator** - To find more specific files (e.g., "find all files that handle [specific component]")
   - **/codebase-analyzer** - To understand implementation details (e.g., "analyze how [system] works")
   - **/codebase-pattern-finder** - To find similar features we can model after

   **For historical context:**
   - **/research-locator** - To find existing research or plans about this area
   - **/research-analyzer** - To extract key insights from relevant prior research/plans

   Example of spawning multiple sub-agents in parallel:

   ```
   // Spawn these concurrently using multiple Task tool calls in one message:
   Task(prompt="Use /codebase-locator to find all files related to database schema for [feature]")
   Task(prompt="Use /codebase-analyzer to analyze API patterns in [service]")
   Task(prompt="Use /codebase-pattern-finder to find similar implementations of [pattern]")
   ```

   Each sub-agent knows how to:
   - Find the right files and code patterns
   - Identify conventions and patterns to follow
   - Look for integration points and dependencies
   - Return specific file:line references
   - Find tests and examples

4. **Wait for ALL sub-agents to complete** before proceeding

5. **Present findings and design options**:

   ```
   Based on my research, here's what I found:

   **Current State:**
   - [Key discovery about existing code]
   - [Pattern or convention to follow]

   **Design Options:**
   1. [Option A] - [pros/cons]
   2. [Option B] - [pros/cons]

   **Open Questions:**
   - [Technical uncertainty]
   - [Design decision needed]

   Which approach aligns best with your vision?
   ```

### Step 3: Plan Structure Development

Once aligned on approach:

1. **Create initial plan outline**:

   ```
   Here's my proposed plan structure:

   ## Overview
   [1-2 sentence summary]

   ## Implementation Phases:
   1. [Phase name] - [what it accomplishes]
   2. [Phase name] - [what it accomplishes]
   3. [Phase name] - [what it accomplishes]

   Does this phasing make sense? Should I adjust the order or granularity?
   ```

2. **Get feedback on structure** before writing details

### Step 4: Detailed Plan Writing

After structure approval:

1. **Write the plan** to `rpi/planning/YYYY-MM-DD-TICKET-description.md`
   - Format: `YYYY-MM-DD-TICKET-description.md` where:
     - YYYY-MM-DD is today's date
     - TICKET is the ticket number (omit if no ticket)
     - description is a brief kebab-case description
   - Examples:
     - With ticket: `2025-01-08-TEC-1478-parent-child-tracking.md`
     - Without ticket: `2025-01-08-improve-error-handling.md`

2. **Use this template structure**:

````markdown
# [Feature/Task Name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

## Desired End State

[A Specification of the desired end state after this plan is complete, and how to verify it]

### Key Discoveries:

- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## Implementation Approach

[High-level strategy and reasoning]

## Phase 1: [Descriptive Name]

### Overview

[What this phase accomplishes]

### Changes Required:

#### 1. [Component/File Group]

**File**: `path/to/file.ext`
**Changes**: [Summary of changes]

```[language]
// Specific code to add/modify
```

### Success Criteria:

#### Automated Verification:

- [ ] Tests pass: `npm test` / `./gradlew test`
- [ ] Type checking passes: `npm run typecheck`
- [ ] Linting passes: `npm run lint`
- [ ] Build succeeds: `npm run build`

#### Manual Verification:

- [ ] Feature works as expected when tested via UI
- [ ] Performance is acceptable
- [ ] Edge case handling verified manually
- [ ] No regressions in related features

**Implementation Note**: After completing this phase and all automated verification passes, pause here for manual confirmation before proceeding to the next phase.

---

## Phase 2: [Descriptive Name]

[Similar structure with both automated and manual success criteria...]

---

## Testing Strategy

### Unit Tests:

- [What to test]
- [Key edge cases]

### Integration Tests:

- [End-to-end scenarios]

### Manual Testing Steps:

1. [Specific step to verify feature]
2. [Another verification step]
3. [Edge case to test manually]

## Performance Considerations

[Any performance implications or optimizations needed]

## Migration Notes

[If applicable, how to handle existing data/systems]

## References

- Original ticket: [link or file reference]
- Related research: [relevant docs]
- Similar implementation: `[file:line]`
````

### Step 5: Review and Iterate

1. **Present the draft plan location**:

   ```
   I've created the initial implementation plan at:
   `rpi/planning/YYYY-MM-DD-TICKET-description.md`

   Please review it and let me know:
   - Are the phases properly scoped?
   - Are the success criteria specific enough?
   - Any technical details that need adjustment?
   - Missing edge cases or considerations?
   ```

2. **Iterate based on feedback** - be ready to:
   - Add missing phases
   - Adjust technical approach
   - Clarify success criteria (both automated and manual)
   - Add/remove scope items

3. **Continue refining** until the user is satisfied

## Important Guidelines

1. **Be Skeptical**:
   - Question vague requirements
   - Identify potential issues early
   - Ask "why" and "what about"
   - Don't assume - verify with code

2. **Be Interactive**:
   - Don't write the full plan in one shot
   - Get buy-in at each major step
   - Allow course corrections
   - Work collaboratively

3. **Be Thorough**:
   - Read all context files COMPLETELY before planning
   - Research actual code patterns using parallel sub-agents
   - Include specific file paths and line numbers
   - Write measurable success criteria with clear automated vs manual distinction

4. **Be Practical**:
   - Focus on incremental, testable changes
   - Consider migration and rollback
   - Think about edge cases
   - Include "what we're NOT doing"

5. **Track Progress**:
   - Use TodoWrite to track planning tasks
   - Update todos as you complete research
   - Mark planning tasks complete when done

6. **No Open Questions in Final Plan**:
   - If you encounter open questions during planning, STOP
   - Research or ask for clarification immediately
   - Do NOT write the plan with unresolved questions
   - The implementation plan must be complete and actionable
   - Every decision must be made before finalizing the plan

## Success Criteria Guidelines

**Always separate success criteria into two categories:**

1. **Automated Verification** (can be run automatically):
   - Commands that can be run: `npm test`, `./gradlew test`, etc.
   - Specific files that should exist
   - Code compilation/type checking
   - Automated test suites

2. **Manual Verification** (requires human testing):
   - UI/UX functionality
   - Performance under real conditions
   - Edge cases that are hard to automate
   - User acceptance criteria

**Format example:**

```markdown
### Success Criteria:

#### Automated Verification:

- [ ] Database migration runs successfully
- [ ] All unit tests pass: `npm test`
- [ ] No linting errors: `npm run lint`
- [ ] Build succeeds: `npm run build`

#### Manual Verification:

- [ ] New feature appears correctly in the UI
- [ ] Performance is acceptable with large datasets
- [ ] Error messages are user-friendly
- [ ] Feature works correctly on mobile devices
```

## Common Patterns

### For Database Changes:

- Start with schema/migration
- Add repository/store methods
- Update business logic
- Expose via API
- Update clients

### For New Features:

- Research existing patterns first
- Start with data model
- Build backend logic
- Add API endpoints
- Implement UI last

### For Refactoring:

- Document current behavior
- Plan incremental changes
- Maintain backwards compatibility
- Include migration strategy

## Sub-agent Spawning Best Practices

When spawning research sub-agents:

1. **Spawn multiple sub-agents in parallel** for efficiency - use multiple Task tool calls in a single message
2. **Each sub-agent should be focused** on a specific area
3. **Use the `model: "fast"` option** for quick exploration tasks
4. **Use `subagent_type: "explore"`** for codebase research tasks
5. **Provide clear instructions** including:
   - Which sub-agent type to invoke (e.g., `[codebase-locator]`, `[codebase-analyzer]`)
   - Exactly what to search for
   - Which directories to focus on
   - What information to extract
6. **Be EXTREMELY specific about directories**:
   - If the ticket mentions frontend, specify the frontend directory
   - If it mentions a specific service, specify that service's directory
   - Never use generic terms - include the full path context
7. **Request specific file:line references** in responses
8. **Wait for all sub-agents to complete** before synthesizing
9. **Verify sub-agent results**:
   - If a sub-agent returns unexpected results, spawn follow-up sub-agents
   - Cross-check findings against the actual codebase
   - Don't accept results that seem incorrect

## Example Interaction Flow

```
User: /create-plan
Assistant: I'll help you create a detailed implementation plan...

User: We need to add user activity logging. See docs/tickets/TEC-1478.md
Assistant: Let me read that ticket file completely first...

[Reads file fully]

Now spawning research sub-agents to understand the codebase...

[Spawns codebase-locator and codebase-analyzer in parallel]

Based on the ticket and my research, I understand we need to track user activity events. Before I start planning, I have some questions...

[Interactive process continues...]
```
