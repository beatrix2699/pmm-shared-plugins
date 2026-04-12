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
