# Lark Task Creator Skill — Design Spec

**Date:** 2026-04-12
**Status:** Approved

---

## Overview

A single skill (`lark-task-creator`) that manages tasks in Lark Suite via the `lark-openapi-mcp` MCP server. Handles three invocation modes — quick (single task from a sentence), bulk (from a free-form plan or markdown doc), and pipeline (triggered at the end of an upstream skill). Supports full task CRUD, assignment to self or teammates, and reminders. Every mode requires a preview of the full task structure before any Lark API call is made.

**Phased delivery:**
- **v1 (this spec):** Task CRUD + bulk/pipeline creation + assign self/others + reminders
- **v2 (future):** Calendar events linked to tasks and campaigns
- **v3 (future):** Lark Docs linking + Bitable record creation

---

## Skill Structure

The skill is split into a parent orchestrator and focused sub-skills to keep each file manageable:

```
skills/lark-task-creator/
├── SKILL.md                  ← parent: mode detection, routing, config, first-run bootstrap
├── sub-skills/
│   ├── create.md             ← bulk/quick/pipeline task creation (4-level hierarchy)
│   ├── edit.md               ← edit, delete, mark complete/incomplete
│   ├── assign.md             ← assignee resolution (name search + email fallback)
│   └── reminders.md          ← reminder creation on tasks with due dates
```

The parent `SKILL.md` handles mode detection and delegates to the relevant sub-skill. Sub-skills reference back to the parent for config values (Group IDs, OAuth token).

---

## Architecture

### Parent SKILL.md — Auto Mode Detection

Mode is inferred from invocation context. No explicit flag needed.

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Quick** | Short natural language: *"create a Lark task: X"* | Build 1-task structure → preview → execute |
| **Bulk** | Free-form plan or markdown doc provided in message | AI extracts all tasks → build full structure → preview → execute |
| **Pipeline** | Upstream skill output already in conversation context | Parse structured output → build full structure → preview → execute |
| **Edit** | *"update Lark task X"*, *"mark X as done"*, *"delete task X"* | Fetch task → show current state → confirm change → execute |

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

**Create mode:**
1. Create each Tasklist under the appropriate Group
2. Create Tasks inside each Tasklist, assigned to self or specified teammates
3. Create Sub-tasks with `parent_id` pointing to their parent Task
4. Add reminders if due dates are present (via `task.v2.task.addReminders`)

**Edit mode:**
1. Fetch task by ID or name search via `task.v2.task.list`
2. Show current state, confirm the change with the user
3. Apply update via `task.v2.task.patch` (title, description, due date, assignees, status)

**Delete mode:**
1. Fetch task, show task name + sub-task count for confirmation
2. Delete sub-tasks first, then parent task via `task.v2.task.delete`

**Mark complete/incomplete:**
1. Fetch task, call `task.v2.task.patch` with `completed_at` field set or cleared

**Assignee resolution (when assigning to others):**
- Try name search first via `contact.v3.user.list` or `search.v2`
- Fall back to email lookup via `contact.v3.user.batchGetId` if name search yields no match
- Show resolved name + confirm before assigning

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
| `task.v2.task.patch` | Edit task (title, description, due date, assignees, status, complete) |
| `task.v2.task.delete` | Delete task or sub-task |
| `task.v2.task.list` | Search tasks by name or list within a Tasklist |
| `task.v2.task.addMembers` | Add assignees to a task |
| `task.v2.task.addReminders` | Set reminders on tasks with due dates |
| `contact.v3.user.batchGetId` | Resolve teammate email → Lark user ID (may need admin approval) |

> Self-assignment uses OAuth user token implicitly — no user ID lookup needed for self.

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
- "create Lark task", "add to Lark tasks", "create tasks in Lark", "push to Lark", "save to Lark"
- "update Lark task", "edit Lark task", "change due date on", "mark as done", "complete task"
- "delete Lark task", "remove task from Lark"
- "assign task to [name/email]"
- "add reminder to task"
- Implicit: when upstream skill (video-planner, gtm-deck-planner, event-planner, etc.) completes and user says "create tasks" or "add to Lark"

---

## Out of Scope (v1)

- Calendar events linked to tasks (v2)
- Lark Docs linking + Bitable record creation (v3)
- Bulk editing or deleting multiple tasks at once
- Task dependencies or blocking relationships
