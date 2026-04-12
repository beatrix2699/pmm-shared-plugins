# Lark Task Creator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the `lark-task-creator` skill — a parent SKILL.md with 4 sub-skills that create, edit, delete, assign, and set reminders on Lark tasks via the `lark-openapi-mcp` MCP server.

**Architecture:** Single parent `SKILL.md` detects invocation mode (quick/bulk/pipeline/edit) and delegates to focused sub-skills. All creation flows enforce a 4-level hierarchy (Group → Tasklist → Task → Sub-task). OAuth user token authentication means self-assignment requires no user ID lookup.

**Tech Stack:** Lark OpenAPI MCP (`@larksuiteoapi/lark-mcp`), Lark Task API v2, OAuth 2.0 user access token, MCP protocol via Claude Code

---

## File Map

| File | Action | Responsibility |
|------|--------|---------------|
| `skills/lark-task-creator/SKILL.md` | Create | Parent orchestrator: mode detection, config block, first-run bootstrap, routing to sub-skills |
| `skills/lark-task-creator/sub-skills/create.md` | Create | Quick / bulk / pipeline task creation with 4-level hierarchy preview + execute |
| `skills/lark-task-creator/sub-skills/edit.md` | Create | Edit, delete, mark complete/incomplete on existing tasks |
| `skills/lark-task-creator/sub-skills/assign.md` | Create | Assignee resolution: name search → email fallback → confirm |
| `skills/lark-task-creator/sub-skills/reminders.md` | Create | Add reminders to tasks that have due dates |
| `~/.claude.json` (Claude config) | Modify | Register `lark-mcp` MCP server |

---

## Task 1: Register lark-openapi-mcp MCP Server

**Files:**
- Modify: `~/.claude.json`

- [ ] **Step 1: Run one-time OAuth login**

Open a terminal and run:
```bash
npx @larksuiteoapi/lark-mcp login \
  -a cli_a950d41d2f61de18 \
  -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E \
  --domain https://open.larksuite.com
```
A browser window opens → log in with your Lark account → token is cached locally at `~/.lark-mcp/token` (or similar path reported by the CLI).

Expected output: `Login successful. Token cached.`

- [ ] **Step 2: Add lark-mcp to Claude config**

Open `~/.claude.json` and add the `lark-mcp` entry to the `mcpServers` block:

```json
"lark-mcp": {
  "command": "npx",
  "args": [
    "-y", "@larksuiteoapi/lark-mcp", "mcp",
    "-a", "cli_a950d41d2f61de18",
    "-s", "9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E",
    "--domain", "https://open.larksuite.com",
    "--oauth",
    "--token-mode", "user_access_token",
    "-t", "preset.task.default,task.v2.tasklist.create,task.v2.tasklist.list,task.v2.task.delete,task.v2.task.addMembers,task.v2.task.addReminders,contact.v3.user.batchGetId"
  ]
}
```

- [ ] **Step 3: Verify MCP server connects**

Restart Claude Code. In a new conversation, check that `lark-mcp` appears in the MCP servers list. Run a test tool call:
```
task.v2.tasklist.list (page_size: 10)
```
Expected: returns a list of your Lark Tasklists (even if empty). If 401/403, re-run the login command from Step 1.

- [ ] **Step 4: Commit**
```bash
git add ~/.claude.json
git commit -m "feat(lark): register lark-mcp MCP server with OAuth user token"
```

---

## Task 2: Write Parent SKILL.md (Orchestrator)

**Files:**
- Create: `skills/lark-task-creator/SKILL.md`

- [ ] **Step 1: Create the directory**
```bash
mkdir -p /Users/lap15291/Documents/GitHub/pmm-shared-plugins/skills/lark-task-creator/sub-skills
```

- [ ] **Step 2: Write `skills/lark-task-creator/SKILL.md`**

```markdown
---
name: lark-task-creator
description: |
  Use when creating, editing, deleting, or managing tasks in Lark Suite.
  Triggers on: "create Lark task", "add to Lark tasks", "create tasks in Lark",
  "push to Lark", "save to Lark", "update Lark task", "edit Lark task",
  "mark as done", "complete task", "delete Lark task", "remove task from Lark",
  "assign task to [name/email]", "add reminder to task".
  Also triggers implicitly when an upstream skill (video-planner, gtm-deck-planner,
  event-planner, sales-enablement, launch-strategy, content-strategy) finishes
  and the user says "create tasks" or "add to Lark".
---

# Lark Task Creator

Create, edit, and manage Lark Suite tasks via the `lark-mcp` MCP server.
All tasks are previewed before any API call is made.

## Pipeline Position

This skill is the **final step** in any planning pipeline:

```
video-planner        ──┐
gtm-deck-planner     ──┤
event-planner        ──┼──▶  lark-task-creator  ──▶  Lark app (deep-link)
sales-enablement     ──┤
launch-strategy      ──┘
```

When an upstream skill finishes, offer to push tasks to Lark immediately.

---

## Config

These values are set once. If any Group ID is blank, run the First-Run Bootstrap below.

```yaml
groups:
  AI AgentBase:  ""   # fill after bootstrap
  GreenNode IDP: ""   # fill after bootstrap
  AI Cloud:      ""   # fill after bootstrap
  Others:        ""   # fill after bootstrap
```

---

## First-Run Bootstrap

If any Group ID in the config is blank, do this before any task creation:

1. Call `task.v2.tasklist.list` with `page_size: 50`
2. Display the results as a table:
   ```
   | # | Tasklist Name | ID |
   |---|---------------|----|
   | 1 | AI AgentBase  | tl_xxx |
   | 2 | GreenNode IDP | tl_yyy |
   ...
   ```
3. Ask: "Which of these correspond to your 4 product Groups? Map them:
   - AI AgentBase → #?
   - GreenNode IDP → #?
   - AI Cloud → #?
   - Others → #?"
4. User replies with numbers. Fill in the Group IDs in the config block above.
5. Confirm: "Config saved. Proceeding with task creation."

> If `task.v2.tasklist.list` returns 401: ask user to run `npx @larksuiteoapi/lark-mcp login -a cli_a950d41d2f61de18 -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E --domain https://open.larksuite.com` to refresh the OAuth token.

---

## Mode Detection

Detect mode from invocation context automatically — no flag needed:

| Mode | Signal | Sub-skill |
|------|--------|-----------|
| **Quick** | Short sentence: "create Lark task: X" | `sub-skills/create.md` |
| **Bulk** | Free-form plan or markdown doc in message | `sub-skills/create.md` |
| **Pipeline** | Upstream skill output already in conversation | `sub-skills/create.md` |
| **Edit** | "update", "edit", "change", "mark as done", "complete", "delete" | `sub-skills/edit.md` |

If mode is ambiguous, ask: "Do you want to create new tasks or edit an existing one?"

---

## Routing

- **Create / Bulk / Pipeline mode** → follow `sub-skills/create.md`
- **Edit / Delete / Complete mode** → follow `sub-skills/edit.md`
- **Assigning to others** → follow `sub-skills/assign.md` to resolve user IDs, then return to create or edit flow
- **Adding reminders** → follow `sub-skills/reminders.md` after tasks are created
```

- [ ] **Step 3: Commit**
```bash
git add skills/lark-task-creator/SKILL.md
git commit -m "feat(lark): add lark-task-creator parent skill with mode routing"
```

---

## Task 3: Write create.md Sub-Skill

**Files:**
- Create: `skills/lark-task-creator/sub-skills/create.md`

- [ ] **Step 1: Write `skills/lark-task-creator/sub-skills/create.md`**

```markdown
# Sub-skill: Create Tasks

Handles quick, bulk, and pipeline task creation.
Always builds the full task structure first, previews it, then executes.

---

## Step 1 — Parse Input by Mode

**Quick mode** (single sentence):
Extract: task title, description (optional), due date (optional).
Product group: infer from keywords (e.g., "AgentBase" → AI AgentBase) or default to **Others**.
Campaign name: ask if not obvious. Keep it short: `[Topic] [Mon YYYY]` e.g. `GTM Launch Apr 2026`.

**Bulk mode** (free-form plan or markdown doc):
- Read the full input
- Extract every action item, deliverable, or task
- Group by product (AgentBase → AI AgentBase, IDP/identity → GreenNode IDP, cloud/infra → AI Cloud, anything else → Others)
- Infer campaign name from the document title or ask
- Identify sub-tasks: bullet points under a task, or "includes:", "steps:", "to-do:" sections

**Pipeline mode** (upstream skill output in context):
Map upstream output to the hierarchy:

| Upstream skill | Tasks from | Sub-tasks from |
|---------------|-----------|----------------|
| video-planner | Episode rows (Episode Roadmap sheet) | Production milestones per episode |
| gtm-deck-planner | Asset table rows (Owner/Due columns) | Sub-items under each asset |
| event-planner | Staff assignment rows | Individual responsibilities per role |
| sales-enablement | Asset rows (pitch deck, one-pager, etc.) | Deliverable checklist per asset |
| launch-strategy | Phase actions | Steps within each phase action |
| content-strategy | Content pillars / topic clusters | Individual articles or subtopics |

If the upstream output has no clear task structure, ask:
> "Which sections of this output should become tasks?"

---

## Step 2 — Build Task Structure in Memory

Construct the full 4-level hierarchy. Do NOT call any API yet.

```
Group: AI AgentBase
  └── Tasklist: GTM Launch Apr 2026
        └── Task: Write landing page copy  [due: Apr 18]  [assignee: self]
              ├── Sub-task: Draft hero section
              └── Sub-task: Review with designer

Group: GreenNode IDP
  └── Tasklist: GTM Launch Apr 2026
        └── Task: Create onboarding email sequence  [due: Apr 20]  [assignee: self]
              └── Sub-task: Write welcome email
```

**Rules:**
- All tasks and sub-tasks assigned to self by default (OAuth implicit)
- If assignee is specified → note it next to the task for `sub-skills/assign.md` to resolve later
- If a due date is present → note it; reminders will be set in `sub-skills/reminders.md` after creation
- Tasklist name format: `[Campaign] [Mon YYYY]` — e.g. `AI Cluster GTM Apr 2026`
- If a task has no clear Group, put it in **Others**

---

## Step 3 — Preview

Display the full structure as a markdown outline (as built in Step 2).

Ask:
> "Does this task structure look right? Reply **confirm** to create in Lark, or tell me what to change."

Do NOT call any Lark API until the user replies **confirm**.

If the user requests changes, update the structure and re-display. Repeat until confirmed.

---

## Step 4 — Execute

Run in this exact order for each Group that has tasks:

**4a. Create Tasklist**
```
tool: task.v2.tasklist.create
args:
  name: "[Campaign] [Mon YYYY]"         # e.g. "AI Cluster GTM Apr 2026"
  members: [{ id: "self", role: "editor" }]
```
Save the returned `tasklist.guid` — needed for task creation.

> If the Tasklist already exists with the same name, ask: "A Tasklist named '[name]' already exists. Use it, or create a new one?"

**4b. Create each Task**
```
tool: task.v2.task.create
args:
  summary: "[Task title]"
  description: "[Task description if any]"
  due: { timestamp: "[ISO8601 due date]" }   # omit if no due date
  tasklists: [{ tasklist_guid: "[from 4a]", section_guid: "" }]
  # no members field — OAuth token = self
```
Save the returned `task.guid` — needed for sub-task creation.

**4c. Create each Sub-task**
```
tool: task.v2.task.create
args:
  summary: "[Sub-task title]"
  parent: { guid: "[parent task.guid from 4b]" }
  # no members field — OAuth token = self
```

**4d. Assign to others (if any)**
After all tasks are created, for each task with a non-self assignee:
→ Follow `sub-skills/assign.md` to resolve the user ID, then call:
```
tool: task.v2.task.addMembers
args:
  task_guid: "[task.guid]"
  members: [{ id: "[resolved_user_id]", role: "assignee" }]
```

**4e. Add reminders (if any due dates)**
After all tasks are created:
→ Follow `sub-skills/reminders.md` for each task with a due date.

---

## Step 5 — Report

Output a summary table:

```
| Task | Sub-tasks | Group / Tasklist | Link |
|------|-----------|-----------------|------|
| Write landing page copy | 2 | AI AgentBase / GTM Launch Apr 2026 | [Open](lark://applink.feishu.cn/client/todo/detail?taskId=xxx) |
| Create onboarding email | 1 | GreenNode IDP / GTM Launch Apr 2026 | [Open](lark://applink.feishu.cn/client/todo/detail?taskId=yyy) |
```

Also provide the Tasklist deep-link for each Group:
```
📋 AI AgentBase Tasklist: lark://applink.feishu.cn/client/todo/tasklist_detail?tasklistId=tl_xxx
📋 GreenNode IDP Tasklist: lark://applink.feishu.cn/client/todo/tasklist_detail?tasklistId=tl_yyy
```

If any task failed, show:
```
⚠️ Failed: [Task title] — [error reason]
```
Continue with remaining tasks — do not stop on a single failure.

---

## Error Reference

| Error | Action |
|-------|--------|
| 401 on any call | Ask user to re-run `npx @larksuiteoapi/lark-mcp login` |
| Tasklist creation fails | Report error, skip tasks for that Group, continue with others |
| Task creation fails | Log task name + error, continue with remaining tasks |
| Sub-task creation fails | Log sub-task name + error, parent task still counts as created |
```

- [ ] **Step 2: Commit**
```bash
git add skills/lark-task-creator/sub-skills/create.md
git commit -m "feat(lark): add create sub-skill with 4-level hierarchy workflow"
```

---

## Task 4: Write edit.md Sub-Skill

**Files:**
- Create: `skills/lark-task-creator/sub-skills/edit.md`

- [ ] **Step 1: Write `skills/lark-task-creator/sub-skills/edit.md`**

```markdown
# Sub-skill: Edit Tasks

Handles editing, deleting, and marking tasks complete or incomplete.
Always shows current state and confirms before making any change.

---

## Step 1 — Find the Task

If the user provided a task name (not an ID), search for it:
```
tool: task.v2.task.list
args:
  tasklist_guid: "[relevant tasklist guid, if known]"
  # or leave empty to search across all tasks
```

If multiple tasks match the name, list them and ask the user to pick:
```
Found multiple tasks named "Write landing page":
1. AI AgentBase / GTM Launch Apr 2026 — due Apr 18
2. Others / Content Q2 — due May 1
Which one? (reply 1 or 2)
```

---

## Step 2 — Show Current State

Display the task before any change:
```
Current state of "Write landing page copy":
- Status: In progress
- Due: Apr 18, 2026
- Assignees: You
- Sub-tasks: Draft hero section (open), Review with designer (open)
- Description: [description if any]
```

Ask for confirmation of the specific change:
> "Confirm: [describe the change]? (yes / no)"

Do NOT call any API until the user confirms.

---

## Step 3 — Execute the Change

**Edit (title, description, due date, assignees):**
```
tool: task.v2.task.patch
args:
  task_guid: "[task.guid]"
  summary: "[new title]"              # omit if not changing
  description: "[new description]"    # omit if not changing
  due: { timestamp: "[ISO8601]" }     # omit if not changing
```

**Mark complete:**
```
tool: task.v2.task.patch
args:
  task_guid: "[task.guid]"
  completed_at: { timestamp: "[current ISO8601 datetime]" }
```

**Mark incomplete:**
```
tool: task.v2.task.patch
args:
  task_guid: "[task.guid]"
  completed_at: null
```

**Delete task:**
First delete all sub-tasks (fetch them via `task.v2.task.list` with `parent_task_guid`), then delete the parent:
```
# For each sub-task:
tool: task.v2.task.delete
args:
  task_guid: "[subtask.guid]"

# Then delete parent:
tool: task.v2.task.delete
args:
  task_guid: "[task.guid]"
```

---

## Step 4 — Confirm Result

After the change:
```
✅ Updated: "Write landing page copy"
   [Changed field]: [old value] → [new value]
   Link: lark://applink.feishu.cn/client/todo/detail?taskId=xxx
```

---

## Error Reference

| Error | Action |
|-------|--------|
| Task not found | Ask user to check task name or provide the task ID |
| 401 | Ask user to re-run `npx @larksuiteoapi/lark-mcp login` |
| Patch fails | Report the specific field that failed |
| Delete sub-task fails | Report it, still attempt to delete parent |
```

- [ ] **Step 2: Commit**
```bash
git add skills/lark-task-creator/sub-skills/edit.md
git commit -m "feat(lark): add edit sub-skill for task CRUD operations"
```

---

## Task 5: Write assign.md Sub-Skill

**Files:**
- Create: `skills/lark-task-creator/sub-skills/assign.md`

- [ ] **Step 1: Write `skills/lark-task-creator/sub-skills/assign.md`**

```markdown
# Sub-skill: Assign Tasks

Resolves a person's name or email to a Lark user ID.
Called from create.md or edit.md when assigning to someone other than self.

> Self-assignment (the default) does NOT use this sub-skill — OAuth token = self implicitly.

---

## Step 1 — Try Name Search

```
tool: contact.v3.user.list
args:
  query: "[name the user provided]"
  page_size: 5
```

If one clear match is found:
```
Resolved "John" → John Nguyen (john.nguyen@greennode.ai)
Assigning to John Nguyen. Confirm? (yes / no)
```

If multiple matches are found, list them and ask:
```
Found multiple people named "John":
1. John Nguyen — john.nguyen@greennode.ai
2. John Smith — john.smith@greennode.ai
Which one? (reply 1 or 2)
```

If no match is found → go to Step 2.

---

## Step 2 — Email Fallback

Ask:
> "Couldn't find '[name]' in Lark contacts. What's their email address?"

Then:
```
tool: contact.v3.user.batchGetId
args:
  emails: ["[email]"]
  mobile_phones: []
```

> Note: `contact.v3.user.batchGetId` may require org admin approval if the app hasn't been published. If it returns 403, ask the user to check with their org admin, or manually provide the Lark user ID.

---

## Step 3 — Return User ID

Return the resolved `user_id` (open_id format) to the calling sub-skill (create.md or edit.md).
The calling sub-skill uses it in `task.v2.task.addMembers` or the `members` field of `task.v2.task.create`.

---

## Error Reference

| Error | Action |
|-------|--------|
| Name search returns 0 results | Fall back to email lookup |
| Email lookup returns 403 | Inform user: contact API needs org admin approval; ask for manual user ID |
| Email not found | Ask user to verify the email address |
```

- [ ] **Step 2: Commit**
```bash
git add skills/lark-task-creator/sub-skills/assign.md
git commit -m "feat(lark): add assign sub-skill for teammate user ID resolution"
```

---

## Task 6: Write reminders.md Sub-Skill

**Files:**
- Create: `skills/lark-task-creator/sub-skills/reminders.md`

- [ ] **Step 1: Write `skills/lark-task-creator/sub-skills/reminders.md`**

```markdown
# Sub-skill: Add Reminders

Adds reminders to tasks that have due dates.
Called from create.md after tasks are created, or directly when user says "add reminder to task X".

---

## When Reminders Are Added

- Automatically after bulk/pipeline task creation if any tasks have due dates
- Manually when user says "add reminder to [task name]" or "remind me about [task] on [date/time]"

---

## Default Reminder Rules

If the user doesn't specify a reminder time, apply these defaults:

| Due date type | Default reminder |
|--------------|-----------------|
| Same day | 2 hours before due time (or 9:00 AM if no time specified) |
| Future date | 1 day before at 9:00 AM |
| Within 2 days | 4 hours before (or morning of due date) |

---

## Step 1 — Identify Tasks Needing Reminders

Collect all task GUIDs that have a due date from the create.md or edit.md context.
If called directly (user said "add reminder"), find the task first via `task.v2.task.list`.

---

## Step 2 — Calculate Reminder Timestamp

Given a due date, calculate the reminder timestamp using the default rules above (or use the time the user specified).

Example: due Apr 18 2026 → reminder Apr 17 2026 09:00 UTC+7 → ISO8601: `2026-04-17T02:00:00Z`

Always use the user's timezone (Asia/Bangkok, UTC+7) when calculating.

---

## Step 3 — Add the Reminder

```
tool: task.v2.task.addReminders
args:
  task_guid: "[task.guid]"
  reminders: [
    { relative_fire_minute: -1440 }   # -1440 = 1 day before due date
    # OR use absolute time:
    # { absolute_fire_minute: "[unix timestamp in minutes]" }
  ]
```

`relative_fire_minute` values:
- `-1440` = 1 day before
- `-120` = 2 hours before
- `-60` = 1 hour before
- `-30` = 30 minutes before
- `0` = at due time

---

## Step 4 — Report

After all reminders are set, include in the parent skill's summary:
```
🔔 Reminders set:
   - "Write landing page copy" → reminder Apr 17 at 9:00 AM
   - "Create onboarding email" → reminder Apr 19 at 9:00 AM
```

---

## Error Reference

| Error | Action |
|-------|--------|
| addReminders fails | Log it, do not block task creation report — task was still created |
| Task has no due date | Skip reminder silently (do not add a reminder with no anchor) |
```

- [ ] **Step 2: Commit**
```bash
git add skills/lark-task-creator/sub-skills/reminders.md
git commit -m "feat(lark): add reminders sub-skill for due-date based notifications"
```

---

## Task 7: Smoke Test — First-Run Bootstrap

**No files to create — this is a verification task.**

- [ ] **Step 1: Open a new Claude Code conversation**

- [ ] **Step 2: Trigger the skill**

Say: `create Lark task: test task for bootstrap verification`

Expected: skill detects blank Group IDs in config, calls `task.v2.tasklist.list`, displays a numbered table of your Lark Tasklists.

- [ ] **Step 3: Complete the bootstrap**

Reply with the correct numbers mapping each Group to a Tasklist. Verify the config block is updated with real IDs.

- [ ] **Step 4: Verify task creation proceeds**

After bootstrap, the skill should continue with the quick-mode task creation flow, show a preview, and on confirm, create the task in Lark.

Expected: task appears in Lark under the correct Group, deep-link is provided.

---

## Task 8: Smoke Test — Bulk + Edit Modes

**No files to create — this is a verification task.**

- [ ] **Step 1: Test bulk mode**

Paste a short plan into Claude:
```
Campaign: AgentBase Q2 Launch

AI AgentBase:
- Write product page copy (due Apr 25)
  - Draft hero section
  - Review with team
- Set up demo environment (due Apr 22)

Others:
- Schedule kickoff meeting (due Apr 15)
```

Say: `create tasks in Lark from this plan`

Expected: skill builds 3-task structure across 2 Groups, shows preview, creates on confirm.

- [ ] **Step 2: Test edit mode**

Say: `mark "Write product page copy" as done in Lark`

Expected: skill finds the task, shows current state, confirms, patches `completed_at`.

- [ ] **Step 3: Test delete mode**

Say: `delete "Schedule kickoff meeting" from Lark`

Expected: skill shows task + sub-task count, confirms, deletes sub-tasks then parent.
