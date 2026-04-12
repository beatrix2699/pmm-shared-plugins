# Lark Task Creator Skill — Design Spec

**Date:** 2026-04-12
**Status:** Approved

---

## Overview

A single skill (`lark-task-creator`) that creates tasks in Lark Suite via the `lark-openapi-mcp` MCP server. Handles three modes — quick (single task from a sentence), bulk (from a free-form plan or markdown doc), and pipeline (triggered at the end of an upstream skill). All tasks are always assigned to the current user (self). Every mode requires a preview of the full task structure before any Lark API call is made.

---

## Architecture

### Single SKILL.md — Auto Mode Detection

Mode is inferred from invocation context. No explicit flag needed.

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Quick** | Short natural language: *"create a Lark task: X"* | Build 1-task structure → preview → execute |
| **Bulk** | Free-form plan or markdown doc provided in message | AI extracts all tasks → build full structure → preview → execute |
| **Pipeline** | Upstream skill output already in conversation context | Parse structured output → build full structure → preview → execute |

**Upstream skills that can trigger pipeline mode:**
- `video-planner` — production milestone tables (episode × phase)
- `gtm-deck-planner` — asset tables with owners and due dates
- `event-planner` — staff assignments, communication plan, contest rules
- `sales-enablement` — asset tables with owner/due columns
- `launch-strategy` — phased milestone timelines
- `content-strategy` — content pillar/topic cluster outlines
- Any other skill that produces structured task/deliverable output — user confirms before treating as input

---

## 4-Level Hierarchy

| Level | Lark Term | Meaning | API Object | Pre-existing or Created |
|-------|-----------|---------|------------|------------------------|
| 1 | **Group** | Product area container — holds multiple Tasklists | Lark Tasklist Group (UI grouping) | Pre-existing — IDs stored in skill config |
| 2 | **Tasklist** | Campaign name | `task.v2.tasklist` | **Created per run** |
| 3 | **Task** | Individual deliverable | `task.v2.task` | Created |
| 4 | **Sub-task** | To-do item | `task.v2.task` with `parent_id` | Created |

**Product Groups (pre-configured in skill):**

| Group Name | Product Area |
|-----------|-------------|
| AI AgentBase | AgentBase platform tasks |
| GreenNode IDP | GreenNode identity platform tasks |
| AI Cloud | AI cloud infrastructure tasks |
| Others | Mixed/cross-product non-related tasks |

When input spans multiple products, the skill splits tasks across the appropriate Groups. If a task doesn't clearly belong to a product, it goes into **Others**.

---

## Workflow

### Step 1 — Parse Input
- **Quick:** Extract task title, description, due date from the sentence
- **Bulk:** Read full plan/doc, identify all tasks, infer product groupings and campaign name
- **Pipeline:** Read structured output already in context (tables, sections, milestones), map to hierarchy

### Step 2 — Build Task Structure in Memory
Construct the full 4-level hierarchy before touching any API:

```
Group: AI AgentBase
  └── Tasklist: [Campaign Name] — Apr 2026
        └── Task: Write landing page copy
              ├── Sub-task: Draft hero section
              └── Sub-task: Review with designer

Group: GreenNode IDP
  └── Tasklist: [Campaign Name] — Apr 2026
        └── Task: Create onboarding email sequence
              └── Sub-task: Write welcome email
```

### Step 3 — Preview
Display the full structure as a markdown outline. Ask:
> "Does this task structure look right? Reply **confirm** to create in Lark, or tell me what to change."

Do NOT call any Lark API until the user confirms.

### Step 4 — Execute (in order)
1. Create each Tasklist under the appropriate Group
2. Create Tasks inside each Tasklist, assigned to self (OAuth user token = implicit self, no ID lookup needed)
3. Create Sub-tasks with `parent_id` pointing to their parent Task, assigned to self

### Step 5 — Report
Output a summary table:

| Task | Sub-tasks | Tasklist | Link |
|------|-----------|---------|------|
| Write landing page copy | 2 | AI AgentBase / GTM Apr 2026 | [Open in Lark](lark://...) |

Flag any failures with the specific task name and error reason.

### Step 6 — Lark Deep-Link
Provide a clickable deep-link to each newly created Tasklist:
```
lark://applink.feishu.cn/client/todo/tasklist_detail?tasklistId=<id>
```
User opens manually in the Lark app. No auto-open via browser automation.

---

## MCP Setup

### Server: `lark-openapi-mcp`
**Source:** `/Users/lap15291/Documents/GitHub/lark-openapi-mcp`

**Authentication: OAuth + User Access Token**
Use `--oauth` and `--token-mode user_access_token` so the MCP server authenticates as the user directly. This means:
- No org admin approval needed for personal task operations
- "Self" is implicit — no need to look up or store a user ID
- Tasklist IDs are discovered dynamically on first run via `task.v2.tasklist.list`

**One-time login (run once in terminal):**
```bash
npx @larksuiteoapi/lark-mcp login \
  -a cli_a950d41d2f61de18 \
  -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E \
  --domain https://open.larksuite.com
```
This opens a browser OAuth flow and caches your user token locally.

**Registration in Claude config:**
```json
{
  "mcpServers": {
    "lark-mcp": {
      "command": "npx",
      "args": [
        "-y", "@larksuiteoapi/lark-mcp", "mcp",
        "-a", "cli_a950d41d2f61de18",
        "-s", "9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E",
        "--domain", "https://open.larksuite.com",
        "--oauth",
        "--token-mode", "user_access_token",
        "-t", "preset.task.default,task.v2.tasklist.create,task.v2.tasklist.list"
      ]
    }
  }
}
```

**Tools used:**

| Tool | Purpose |
|------|---------|
| `task.v2.tasklist.list` | Discover Group → Tasklist ID mapping on first run |
| `task.v2.tasklist.create` | Create Tasklist (campaign) under a Group |
| `task.v2.task.create` | Create Task or Sub-task |
| `task.v2.task.list` | Optional: check for duplicate tasks |

> `contact.v3.user.batchGetId` is **not needed** — OAuth user token identifies self implicitly.

### Skill Config Block (inside SKILL.md)
```yaml
# No user ID needed — OAuth token = self
# Group IDs discovered on first run via task.v2.tasklist.list
groups:
  AI AgentBase:  <discovered_on_first_run>
  GreenNode IDP: <discovered_on_first_run>
  AI Cloud:      <discovered_on_first_run>
  Others:        <discovered_on_first_run>
```

**First-run bootstrap:** If any Group ID is blank, the skill calls `task.v2.tasklist.list`, displays the results, asks the user to confirm which Tasklist Group corresponds to each product area, then saves the IDs into the config block.

---

## Error Handling

| Scenario | Behavior |
|----------|---------|
| Group ID not found | Stop, ask user to verify group config in skill |
| Tasklist creation fails | Report error, do not proceed to task creation |
| Task creation fails | Log failed task name, continue with remaining tasks, report all failures at end |
| Sub-task creation fails | Log and report, parent task still considered created |
| OAuth token expired | Prompt user to re-run `npx @larksuiteoapi/lark-mcp login` to refresh token |

---

## Skill Trigger Phrases

The skill activates on:
- "create Lark task"
- "add to Lark tasks"
- "create tasks in Lark"
- "push to Lark"
- "save to Lark"
- Implicit: when upstream skill (video-planner, gtm-deck-planner, event-planner, etc.) completes and user says "create tasks" or "add to Lark"

---

## Out of Scope

- Editing or deleting existing Lark tasks (read-only after creation)
- Assigning tasks to other users (always self)
- Calendar or reminder creation
- Lark Docs or Bitable integration
