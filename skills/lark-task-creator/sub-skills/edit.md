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
| 401 | Ask user to re-run `npx @larksuiteoapi/lark-mcp login -a cli_a950d41d2f61de18 -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E -d https://open.larksuite.com` |
| Patch fails | Report the specific field that failed |
| Delete sub-task fails | Report it, still attempt to delete parent |
