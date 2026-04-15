# Run Phase

You are in Phase 2 of weavy-design-creator. Your job is to execute a saved campaign plan — either by generating a manual step-by-step guide or by automating runs in Figma Weave via Chrome DevTools.

---

## Step 1 — Load Plan File

Find the plan file:
1. If `--resume` or `--retry-failed` flag is present, look for the most recent `campaign-plan-*.md` in `.agents/superpowers/plans/`
2. If a specific plan filename was given, use that
3. Otherwise, list all `campaign-plan-*.md` files in `.agents/superpowers/plans/` and ask: "Which campaign do you want to run?"

If no plan file exists, stop and say:
> "No campaign plan found. Run `/weavy-design-creator plan` first to generate one."

Parse the plan file and load:
- `campaign.name`
- `campaign.weavy_workflow_url`
- All asset entries with their current `status`

Build the execution queue:
- `--resume` flag: assets where `status` is `pending`, `failed`, or `timeout`
- `--retry-failed` flag: only assets where `status` is `failed` or `timeout`
- No flag + fresh plan: all `pending` assets

---

## Step 2 — Show Mode Selection

Print:

```
Campaign: [campaign.name] — [N] assets queued

How do you want to execute?
  m  Manual guide  — I'll run Weavy myself, show me step-by-step instructions
  c  Chrome auto   — Run via browser automation (approval required per asset)
  q  Quit          — Save plan, run later
```

Wait for user input: `m`, `c`, or `q`.

If `q`: print "Plan saved. Resume with: /weavy-design-creator run --resume" and exit.

---

## Step 3 — Manual Guide Mode

For each asset in the execution queue, output this block:

```
── Asset [asset.id] ([index] of [total]) ──
1. Open: [campaign.weavy_workflow_url]
2. Paste into Prompt node:
   > [asset.generated_prompt]
3. Paste into System Prompt node:
   > [asset.system_prompt]
4. Set Aspect Ratio node to: [asset.format]
5. Click Run → when complete, save output as [asset.id].png
6. Mark done below.
```

After printing all assets, save the full guide to:
`.agents/superpowers/plans/campaign-guide-[campaign-slug]-[YYYY-MM-DD].md`

Print:
```
Manual guide saved to .agents/superpowers/plans/campaign-guide-[slug]-[date].md
[N] assets listed. Work through them in Figma Weave and mark complete as you go.
```

Then exit.

---

## Step 4 — Chrome Auto Mode: Approval Gate

Before touching the browser, show this once:

```
About to start Chrome automation for [N] assets.
This will open Figma Weave and run each prompt automatically.

Estimated cost: [HIGH | MED | LOW] ([N] generations)
Workflow URL:   [campaign.weavy_workflow_url]

Proceed with Chrome automation? (y / n)
```

If `n`: exit without touching the browser.

Only proceed to Step 5 after explicit `y`.

---

## Step 5 — Chrome Auto Mode: Per-Asset Confirm Loop

For each asset in the execution queue, show the asset card and wait for input:

```
Asset [asset.id] ([index] of [total])
─────────────────────────────────────
Content: "[first 100 chars of matching content piece raw_content]..."
Format:  [asset.format]
Prompt:  "[asset.generated_prompt]"
System:  "[first 120 chars of asset.system_prompt]..."
Cost:    [asset.estimated_cost]

▶ Run  /  s Skip  /  e Edit prompt  /  q Quit
```

Handle each response:

**`Run` (default / Enter):**
- Write `status: running` to plan file for this asset
- Execute Step 6 (Chrome automation)
- On success → write `status: done` to plan file
- On failure → write `status: failed` + error message to plan file

**`s` Skip:**
- Write `status: skipped` to plan file
- Move to next asset

**`e` Edit:**
- Show: "Enter new prompt (current shown above):"
- User types replacement. Store as `asset.generated_prompt`
- Write `status: edited` to plan file
- Then execute Step 6 with the edited prompt

**`q` Quit:**
- Write current progress (all statuses updated so far) to plan file
- Print:
  ```
  Run paused. [N done / N skipped / N remaining]
  Resume with: /weavy-design-creator run --resume
  ```
- Exit

---

## Step 6 — Chrome Automation (one asset)

Execute these tool calls in sequence. On any failure, catch the error and return it to Step 5 as `failed`.

**6.1 — Navigate to workflow**
Call `navigate_page` with `url: [campaign.weavy_workflow_url]`.

If this fails (page not reachable): return error "Weavy workflow URL unreachable. Check the URL or switch to Manual mode."

**6.2 — Wait for canvas**
Call `wait_for` with:
- `selector: "[data-testid='canvas'], .workflow-canvas, #weave-canvas"`
- `timeout: 15000`

If timeout: return error "Canvas did not load in 15s. Weavy may be slow — try again."

**6.3 — Fill prompt node**
Call `fill` with:
- `selector: "textarea[placeholder*='prompt'], [data-node='text-prompt'] textarea, .prompt-input"`
- `value: [asset.generated_prompt]`

**6.4 — Fill system prompt node**
Call `fill` with:
- `selector: "textarea[placeholder*='system'], [data-node='system-prompt'] textarea, .system-prompt-input"`
- `value: [asset.system_prompt]`

If selector not found for 6.3 or 6.4: return error "selector not found — Weavy UI may have changed. Use Manual mode for this asset."

**6.5 — Set aspect ratio**
Call `fill` (or `click` if it's a dropdown) with the aspect ratio selector targeting `[asset.format]`.
- Try: `select[name='aspectRatio']`, `.aspect-ratio-selector`
- If dropdown: `click` on the dropdown then `click` on the matching option label

**6.6 — Click Run**
Call `click` with:
- `selector: "button[data-action='run'], button.run-btn, button:has-text('Run')"`

**6.7 — Wait for output**
Call `wait_for` with:
- `selector: ".output-image, [data-testid='output-image'], .result-image img"`
- `timeout: 120000`

If timeout after 120s: return error "Generation timed out after 120s."

**6.8 — Screenshot**
Ensure directory exists: `.agents/superpowers/plans/outputs/`
Call `take_screenshot` — save to `.agents/superpowers/plans/outputs/[asset.id].png`.

**6.9 — Update plan**
Write `status: done` to the asset entry in the plan file.

---

## Step 7 — Run Summary

After the queue is exhausted (or user quits), print:

```
─────────────────────────────────────
Campaign: [campaign.name]
✓ Done:    [N] assets
⚠ Failed:  [N] assets
↪ Edited:  [N] assets (ran with edited prompts)
→ Skipped: [N] assets
─────────────────────────────────────
[if failed > 0]:
  Retry failed: /weavy-design-creator run --retry-failed

Outputs: .agents/superpowers/plans/outputs/
```

---

## Error Reference

| Error message | Meaning | Recovery |
|--------------|---------|----------|
| "selector not found" | Weavy UI changed | Switch to Manual mode for this asset |
| "Weavy workflow URL unreachable" | Bad URL or Weavy down | Check URL, retry or use Manual mode |
| "Generation timed out after 120s" | Model overloaded | Asset marked timeout; retry later |
| "Canvas did not load in 15s" | Slow page load | Retry; check internet |
| "No campaign plan found" | Plan phase not run | Run `/weavy-design-creator plan` first |
