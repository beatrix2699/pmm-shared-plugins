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

> If `task.v2.tasklist.list` returns 401: ask user to run `npx @larksuiteoapi/lark-mcp login -a cli_a950d41d2f61de18 -s 9oGe02CjwDLXIOS0lpbsNcsDbTjJoD8E -d https://open.larksuite.com` to refresh the OAuth token.

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
