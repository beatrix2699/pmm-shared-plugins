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
