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
| 401 on any call | Ask user to re-run `npx @larksuiteoapi/lark-mcp login -a cli_a950d41d2f61de18 -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E -d https://open.larksuite.com` |
| Tasklist creation fails | Report error, skip tasks for that Group, continue with others |
| Task creation fails | Log task name + error, continue with remaining tasks |
| Sub-task creation fails | Log sub-task name + error, parent task still counts as created |
