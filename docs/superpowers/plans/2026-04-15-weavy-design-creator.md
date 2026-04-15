# weavy-design-creator Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a two-phase skill (`weavy-design-creator`) that takes content input, generates structured Figma Weave prompts per asset, and executes design generation via manual guide or Chrome DevTools automation — with asset-level confirmation before every run.

**Architecture:** Four markdown skill files. `SKILL.md` detects mode and routes to either `sub-skills/plan.md` (Phase 1: prompt generation + plan file) or `sub-skills/run.md` (Phase 2: manual guide or Chrome automation). `references/weavy-nodes.md` is a reference both sub-skills consult for prompt patterns and node types.

**Tech Stack:** Markdown skill files, YAML data structures, Chrome DevTools MCP (`mcp__plugin_chrome-devtools-mcp_chrome-devtools__*`), Figma Weave UI at `app.weavy.ai`

---

## File Map

| File | Action | Responsibility |
|------|--------|----------------|
| `skills/weavy-design-creator/references/weavy-nodes.md` | Create | Node type reference, prompt patterns, system prompt template |
| `skills/weavy-design-creator/sub-skills/plan.md` | Create | Phase 1: brief collection, prompt generation, plan file output |
| `skills/weavy-design-creator/sub-skills/run.md` | Create | Phase 2: mode selection, manual guide, Chrome automation loop, error handling |
| `skills/weavy-design-creator/SKILL.md` | Create | Orchestrator: frontmatter, pipeline position, mode detection, routing |

Plan files written at runtime (not created here):
- `docs/superpowers/plans/campaign-plan-{name}-{date}.md`
- `docs/superpowers/plans/campaign-guide-{name}-{date}.md`
- `docs/superpowers/plans/outputs/{asset_id}.png`

---

## Task 1: Create `references/weavy-nodes.md`

**Files:**
- Create: `skills/weavy-design-creator/references/weavy-nodes.md`

This file is read by both `plan.md` and `run.md`. It must be written first so later tasks can reference it accurately.

- [ ] **Step 1: Create the directory structure**

```bash
mkdir -p skills/weavy-design-creator/references
mkdir -p skills/weavy-design-creator/sub-skills
```

Expected: directories created, no output.

- [ ] **Step 2: Write `references/weavy-nodes.md`**

Create `skills/weavy-design-creator/references/weavy-nodes.md` with this exact content:

```markdown
# Weavy Nodes & Prompt Reference

## Node Types

| Node | Purpose | Notes |
|------|---------|-------|
| Text Prompt | Main image generation instruction | Keep under 120 tokens |
| System Prompt | Persistent campaign style instruction | Shared across all assets in a campaign |
| Image Input | Reference image for style anchoring | URL or uploaded file |
| Style Reference | ControlNet-style visual consistency | Use campaign reference_image_url if provided |
| Aspect Ratio | Output dimensions | "1:1" \| "16:9" \| "9:16" \| "4:5" |
| Negative Prompt | Exclusions from generation | Always set; see defaults below |
| Seed | Reproducibility across assets | Optional; set for consistency across variants |
| Model Selector | AI model choice | "flux" \| "stable-diffusion" \| "recraft" |

## System Prompt Template

Fill this template for each campaign. Keep the final string under 200 tokens.

```
You are generating visuals for [campaign_name].
Style: [brief]. Colors: [hex list]. Avoid: [negative_prompts].
Maintain visual consistency across all assets in this campaign.
```

Example (GreenNode GPU launch):
```
You are generating visuals for GreenNode April Launch.
Style: Dark cinematic, techy, futuristic. Colors: #6B2FFA, #1A1A2E. Avoid: logos, text, stock photo aesthetic.
Maintain visual consistency across all assets in this campaign.
```

## Text Prompt Construction Rules

Build prompts in this order:
1. **Environment/Setting** — where or what space
2. **Lighting/Color** — dominant palette and light source
3. **Composition** — how the frame is organized
4. **Style label** — aesthetic shorthand (e.g., "editorial", "cinematic", "flat vector")

Keep under 120 tokens. Longer prompts reduce model coherence.

## Prompt Patterns by Campaign Type

### Product Launch
```
Clean studio environment, [primary_color] accent lighting, product hero shot centered,
minimal gradient background, professional product photography, [format] composition
```

### Thought Leadership
```
Abstract minimal composition, muted [primary_color] palette, generous white space,
typographic hierarchy suggestion, editorial design aesthetic, [format] layout
```

### Community / Event
```
Warm energetic atmosphere, people-implied silhouettes at mid-ground,
bold [primary_color] accent band at lower third, vibrant celebratory mood,
[format] composition for social
```

### GPU / Tech Product (GreenNode default)
```
Dark cinematic environment, [primary_color] neon data streams and geometric nodes,
floating server rack abstraction, dramatic side lighting, futuristic tech aesthetic,
[format] hero composition
```

### Social Media Engagement
```
Bold graphic design, high contrast, [primary_color] dominant color block,
clean typographic space reserved at top, scroll-stopping composition,
mobile-optimized [format] framing
```

## Negative Prompt Defaults

Always append to campaign negative_prompts unless user overrides:
```
blurry, low quality, watermark, text overlay, cluttered background, oversaturated,
cartoon, anime, stock photo, generic, amateur
```

## Format → Composition Notes

| Format | Composition Guidance |
|--------|---------------------|
| 1:1 | Square center-weighted, safe zone 80% of frame |
| 16:9 | Wide cinematic, rule of thirds, landscape |
| 9:16 | Vertical mobile-first, top 30% is headline space |
| 4:5 | Instagram portrait, subject upper-center |
```

- [ ] **Step 3: Verify the file reads correctly**

Open `skills/weavy-design-creator/references/weavy-nodes.md` and confirm:
- All 8 node types present in the table
- System prompt template has the correct placeholder tokens: `[campaign_name]`, `[brief]`, `[hex list]`, `[negative_prompts]`
- All 5 campaign types have prompt patterns
- Format table covers all 4 formats from the spec (1:1, 16:9, 9:16, 4:5)

- [ ] **Step 4: Commit**

```bash
git add skills/weavy-design-creator/references/weavy-nodes.md
git commit -m "feat(weavy-design-creator): add weavy nodes and prompt reference"
```

---

## Task 2: Create `sub-skills/plan.md`

**Files:**
- Create: `skills/weavy-design-creator/sub-skills/plan.md`
- Reference: `skills/weavy-design-creator/references/weavy-nodes.md` (must exist — Task 1)

Phase 1 logic: collects campaign brief + content pieces, generates asset entries (one per content_piece × aspect_ratio), gets user confirmation, saves plan file.

- [ ] **Step 1: Write `sub-skills/plan.md`**

Create `skills/weavy-design-creator/sub-skills/plan.md` with this exact content:

```markdown
# Plan Phase

You are in Phase 1 of weavy-design-creator. Your job is to collect a campaign brief and content pieces, generate one asset entry per content piece × format, and save a campaign plan file.

Read `references/weavy-nodes.md` before generating any prompts.

---

## Step 1 — Check for Upstream Context

Before asking any questions, scan the current conversation for output from upstream skills:
- `social-content` output → extract each post as a content piece
- `content-strategy` output → extract each recommended article/topic as a content piece
- `email-sequence` output → extract each email as a content piece

If upstream content is found, pre-fill the content_pieces list and skip Step 4. Tell the user: "I found [N] content pieces from [skill name]. Using those — please confirm or edit."

---

## Step 2 — Collect Campaign Brief

Ask for the following in order. One question at a time. Skip any field the user has already provided.

1. **Campaign name** — "What should we call this campaign? (e.g., 'GreenNode April Launch')"

2. **Campaign brief** — "Describe the visual mood and style in free text. Include: tone, colors you're thinking of, any references, overall feel. (e.g., 'Dark techy, purple neon, cinematic, premium GPU product')"

3. **Primary colors** — "What are the primary brand colors for this campaign? (provide hex codes, e.g., #6B2FFA, #1A1A2E)"

4. **Logo placement** — "Where should the logo be placed? Options: bottom-right / bottom-left / none / top-right / top-left"

5. **Aspect ratios** — "Which formats do you need? Select all that apply: 1:1 / 16:9 / 9:16 / 4:5"

6. **Negative prompts** — "Anything to avoid in all generated images? I'll add the standard quality exclusions automatically."
   - Append defaults from `references/weavy-nodes.md` § Negative Prompt Defaults to whatever the user provides.

7. **Reference image URL** — "Do you have a reference image for visual style? (optional — paste URL or press Enter to skip)"

8. **Weavy workflow URL** — "Paste your Figma Weave workflow URL. (e.g., https://app.weavy.ai/workflows/abc123)"

---

## Step 3 — Build System Prompt

Using the collected brief and locked params, generate the campaign system_prompt using the template from `references/weavy-nodes.md` § System Prompt Template:

```
You are generating visuals for [campaign.name].
Style: [campaign.brief]. Colors: [campaign.locked_params.primary_colors joined by comma]. Avoid: [campaign.negative_prompts].
Maintain visual consistency across all assets in this campaign.
```

Show the generated system_prompt to the user and ask: "Does this system prompt look right? (y / edit)"

If "edit" — let the user modify it inline. Use their version as system_prompt for all assets.

---

## Step 4 — Collect Content Pieces

If not pre-filled from upstream context, ask:

"Paste your content pieces below. Each piece on a new line, or as a numbered list. I'll assign them IDs automatically."

Format each as:
```yaml
- id: "cp-{N:02d}"
  source: "free-text"
  raw_content: "[full text as provided]"
  intent: "[inferred: awareness | engagement | conversion]"
```

Infer `intent` from the text:
- Promotional, offer, CTA-heavy → conversion
- Question, poll, discussion → engagement
- Educational, announcement, news → awareness

If intent is ambiguous, ask: "Is cp-{N} meant for awareness, engagement, or conversion?"

---

## Step 5 — Generate Asset Entries

For each `content_piece × aspect_ratio` combination:

1. Read the matching prompt pattern from `references/weavy-nodes.md` § Prompt Patterns by Campaign Type — choose the pattern that best fits `campaign.brief` and `content_piece.intent`
2. Substitute `[primary_color]` with `campaign.locked_params.primary_colors[0]`
3. Substitute `[format]` with the current aspect_ratio
4. Add 1-2 content-specific phrases extracted from `content_piece.raw_content` (key nouns or visual concepts only — no text/copy)

Build each asset entry:
```yaml
- id: "cp-{N:02d}-{format_slug}"   # format_slug: 1x1 | 16x9 | 9x16 | 4x5
  content_piece_id: "cp-{N:02d}"
  format: "{aspect_ratio}"
  generated_prompt: "{constructed prompt}"
  system_prompt: "{campaign system_prompt}"
  estimated_cost: "{low | med | high}"   # low=<10s model, med=10-30s, high=>30s or video
  status: "pending"
```

Default `estimated_cost` to "med" unless:
- Model Selector is set to a video model → high
- Simple flat/vector style → low

---

## Step 6 — Pre-Save Confirmation

Show this summary before saving:

```
─────────────────────────────────────
Campaign:       [campaign.name]
Content pieces: [N]
Formats:        [list] ([N] per piece)
Total assets:   [N × formats]
Est. cost:      [LOW | MED | HIGH — based on majority of assets]
Workflow URL:   [weavy_workflow_url]
─────────────────────────────────────
Save plan? (y / n / show-prompts)
```

If `show-prompts`: print all generated_prompt values with their asset IDs so the user can review before saving.

If `n`: ask "What would you like to change?" and loop back to the relevant step.

---

## Step 7 — Save Plan File

On `y`, write the plan file to:
`docs/superpowers/plans/campaign-plan-{campaign.name slug}-{YYYY-MM-DD}.md`

Where `{campaign.name slug}` = lowercase, spaces replaced with `-`, special chars removed.

File format:

```markdown
# Campaign Plan: [campaign.name]
**Created:** [YYYY-MM-DD]
**Workflow URL:** [weavy_workflow_url]

## Campaign Brief
[campaign.brief]

## System Prompt
[system_prompt]

## Locked Params
- Primary colors: [hex list]
- Logo placement: [value]
- Aspect ratios: [list]
- Negative prompts: [value]

## Assets

| ID | Content Piece | Format | Est. Cost | Status |
|----|--------------|--------|-----------|--------|
[one row per asset]

## Asset Details

### [asset.id]
**Content piece:** [cp id] — [first 80 chars of raw_content]...
**Format:** [format]
**Prompt:**
> [generated_prompt]

**System prompt:**
> [system_prompt]

**Status:** pending
```

After saving, print:

```
Plan saved to docs/superpowers/plans/campaign-plan-[slug]-[date].md
Run with: /weavy-design-creator run
```

Then exit Phase 1. Do not start Phase 2 automatically.
```

- [ ] **Step 2: Verify plan.md content**

Read through `sub-skills/plan.md` and confirm:
- Step 1 checks for all 3 upstream skill sources (social-content, content-strategy, email-sequence)
- Steps 2–8 numbered fields in order match spec (campaign name, brief, colors, logo, ratios, negative, ref image, workflow URL)
- System prompt template uses `references/weavy-nodes.md` § System Prompt Template — same placeholders as defined in Task 1
- Asset ID format is `cp-{N:02d}-{format_slug}` — consistent (no later conflicts)
- Plan file path is exactly `docs/superpowers/plans/campaign-plan-{slug}-{YYYY-MM-DD}.md`
- `show-prompts` option present in pre-save confirmation

- [ ] **Step 3: Commit**

```bash
git add skills/weavy-design-creator/sub-skills/plan.md
git commit -m "feat(weavy-design-creator): add Phase 1 plan sub-skill"
```

---

## Task 3: Create `sub-skills/run.md`

**Files:**
- Create: `skills/weavy-design-creator/sub-skills/run.md`
- Reference: `skills/weavy-design-creator/references/weavy-nodes.md`
- Reads at runtime: `docs/superpowers/plans/campaign-plan-{slug}-{date}.md`

Phase 2 logic: loads the plan file, shows mode selection, executes either manual guide or Chrome automation with per-asset confirmation. Handles all error cases and writes status back to the plan file after each asset.

- [ ] **Step 1: Write `sub-skills/run.md`**

Create `skills/weavy-design-creator/sub-skills/run.md` with this exact content:

```markdown
# Run Phase

You are in Phase 2 of weavy-design-creator. Your job is to execute a saved campaign plan — either by generating a manual step-by-step guide or by automating runs in Figma Weave via Chrome DevTools.

---

## Step 1 — Load Plan File

Find the plan file:
1. If `--resume` or `--retry-failed` flag is present, look for the most recent `campaign-plan-*.md` in `docs/superpowers/plans/`
2. If a specific plan filename was given, use that
3. Otherwise, list all `campaign-plan-*.md` files in `docs/superpowers/plans/` and ask: "Which campaign do you want to run?"

If no plan file exists, stop and say:
> "No campaign plan found. Run `/weavy-design-creator plan` first to generate one."

Parse the plan file and load:
- `campaign.name`
- `campaign.weavy_workflow_url`
- All asset entries with their current `status`

Build the execution queue:
- Default (`--resume`): assets where `status` is `pending`, `failed`, or `timeout`
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
`docs/superpowers/plans/campaign-guide-[campaign-slug]-[YYYY-MM-DD].md`

Print:
```
Manual guide saved to docs/superpowers/plans/campaign-guide-[slug]-[date].md
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
Ensure directory exists: `docs/superpowers/plans/outputs/`
Call `take_screenshot` — save to `docs/superpowers/plans/outputs/[asset.id].png`.

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

Outputs: docs/superpowers/plans/outputs/
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
```

- [ ] **Step 2: Verify run.md content**

Read through `sub-skills/run.md` and confirm:
- Asset card display matches spec exactly (Content / Format / Prompt / System / Cost / actions)
- `e Edit` writes `status: edited` before running — not after
- Chrome steps 6.1–6.9 cover all 9 automation steps from the spec
- `wait_for` timeout for canvas is 15s, for output is 120s (matches spec)
- Screenshot path is `docs/superpowers/plans/outputs/{asset_id}.png`
- Error table covers all 5 error situations from the spec
- `--retry-failed` filters to `failed | timeout` only (not `skipped`)
- `--resume` filters to `pending | failed | timeout`

- [ ] **Step 3: Commit**

```bash
git add skills/weavy-design-creator/sub-skills/run.md
git commit -m "feat(weavy-design-creator): add Phase 2 run sub-skill with Chrome automation"
```

---

## Task 4: Create `SKILL.md`

**Files:**
- Create: `skills/weavy-design-creator/SKILL.md`
- References: all sub-skills and references created in Tasks 1–3

The orchestrator. Handles mode detection, pipeline position, routing, and resume/retry flag handling.

- [ ] **Step 1: Write `SKILL.md`**

Create `skills/weavy-design-creator/SKILL.md` with this exact content:

```markdown
---
name: weavy-design-creator
description: |
  Use when creating visual design assets from content using Figma Weave (weavy.ai / weave.figma.com).
  Triggers on: "create designs", "generate visuals", "design campaign assets",
  "weavy design", "create design batch", "generate images for posts",
  "run design campaign", "plan design campaign", "generate visuals for campaign",
  "bulk design", "create campaign visuals".
  Also triggers implicitly when an upstream skill (content-strategy, social-content,
  email-sequence) finishes and the user says "create designs", "generate visuals",
  or "make images for this".
---

# Weavy Design Creator

Generate visual design assets from content using Figma Weave, with LLM-generated prompts
and optional Chrome browser automation. All runs require explicit per-asset confirmation.

## Pipeline Position

```
content-strategy  ──┐
social-content    ──┤
email-sequence    ──┼──▶  weavy-design-creator  ──▶  Figma Weave (Chrome or Manual)
free text input   ──┘
```

When an upstream skill finishes, offer to create designs immediately:
> "Want to generate visual assets for these [N] pieces? I can plan a design campaign now."

## Two Phases

| Phase | What it does | Output |
|-------|-------------|--------|
| **Plan** | Collects campaign brief + content, generates all prompts | `campaign-plan-{slug}-{date}.md` |
| **Run** | Executes assets — manual guide or Chrome automation | Screenshots + updated plan file |

## Mode Detection

Determine which phase to enter based on these signals (in priority order):

| Signal | Action |
|--------|--------|
| `--retry-failed` flag in invocation | Load most recent plan → Run Phase → retry-failed queue |
| `--resume` flag in invocation | Load most recent plan → Run Phase → resume queue |
| "run campaign" or "run designs" or "execute plan" | Load plan file → Run Phase |
| Plan file exists in `docs/superpowers/plans/campaign-plan-*.md` AND user says "run" | Run Phase |
| "plan campaign" or "plan designs" or first invocation with no plan file | Plan Phase |
| Upstream skill output in conversation + "create designs" / "make images" | Plan Phase (content pre-filled from upstream) |
| Ambiguous — can't determine phase | Ask: "Do you want to plan a new campaign or run an existing one?" |

## Routing

- **Plan Phase** → read and follow `sub-skills/plan.md` completely
- **Run Phase** → read and follow `sub-skills/run.md` completely

Read `references/weavy-nodes.md` before generating any prompts (in Plan Phase) or building manual guide blocks (in Run Phase manual mode).

## Important Constraints

- **Never run Chrome automation without explicit per-asset confirmation.** The approval gate (Step 4 of run.md) and per-asset confirm loop (Step 5 of run.md) are mandatory. Do not skip them.
- **Never start Phase 2 automatically after Phase 1.** Phase 1 ends with "Run with: /weavy-design-creator run". Stop there.
- **Never modify a plan file's `status` field except during active execution.** Only run.md writes status values.
- **Do not guess Weavy UI selectors.** Use only the selectors defined in run.md Step 6. If they fail, report the error and suggest Manual mode.

## Resume Commands

```
/weavy-design-creator run              # enter mode selection with full pending queue
/weavy-design-creator run --resume     # skip done/skipped, continue from first non-done asset
/weavy-design-creator run --retry-failed  # only failed and timeout assets
```
```

- [ ] **Step 2: Verify SKILL.md**

Read through `SKILL.md` and confirm:
- Frontmatter `description` includes all 10 trigger phrases
- Mode detection table covers all 6 cases from the spec (including upstream skill + "create designs")
- The "Important Constraints" block includes the 4 safety rules
- Resume commands match the flag names used in `run.md` Step 1 (`--resume`, `--retry-failed`)
- Pipeline diagram shows all 4 upstream sources

- [ ] **Step 3: Commit**

```bash
git add skills/weavy-design-creator/SKILL.md
git commit -m "feat(weavy-design-creator): add orchestrator SKILL.md — weavy design creator skill complete"
```

---

## Task 5: Register Skill in marketplace.json

**Files:**
- Modify: `marketplace.json` (if it exists at repo root)

The skill won't be discoverable until it's registered in the plugin manifest.

- [ ] **Step 1: Check if marketplace.json exists and inspect its format**

```bash
cat marketplace.json 2>/dev/null | head -60
```

If the file doesn't exist, skip this task entirely.

- [ ] **Step 2: Add the skill entry**

Following the existing format in `marketplace.json`, add an entry for `weavy-design-creator`:

```json
{
  "name": "weavy-design-creator",
  "description": "Generate visual design assets from content using Figma Weave, with LLM-generated prompts and Chrome automation.",
  "path": "skills/weavy-design-creator/SKILL.md",
  "tags": ["design", "automation", "figma", "weavy", "content", "campaign"]
}
```

Match the exact JSON structure (array entry format, field names) used by existing entries.

- [ ] **Step 3: Commit**

```bash
git add marketplace.json
git commit -m "feat(weavy-design-creator): register skill in marketplace.json"
```

---

## Self-Review

### Spec Coverage Check

| Spec requirement | Task that implements it |
|-----------------|------------------------|
| SKILL.md orchestrator with mode detection | Task 4 |
| sub-skills/plan.md Phase 1 | Task 2 |
| sub-skills/run.md Phase 2 | Task 3 |
| references/weavy-nodes.md | Task 1 |
| Campaign brief: 7 fields (name, brief, colors, logo, ratios, negative, ref image, workflow URL) | Task 2 Step 1 |
| System prompt template | Task 1 + Task 2 Step 3 |
| Content pieces from upstream skill context | Task 2 Step 1 |
| Asset entries: content_piece × aspect_ratio | Task 2 Step 5 |
| Pre-save confirmation with show-prompts option | Task 2 Step 6 |
| Plan file saved to docs/superpowers/plans/ | Task 2 Step 7 |
| Mode selection (m/c/q) | Task 3 Step 2 |
| Manual guide output + saved file | Task 3 Step 3 |
| Chrome approval gate (one-time, explicit y/n) | Task 3 Step 4 |
| Per-asset confirm loop (Run/s/e/q) | Task 3 Step 5 |
| Chrome automation 9 steps | Task 3 Step 6 |
| Error handling — 5 situations | Task 3 Step 6 + Error Reference table |
| Run summary with retry commands | Task 3 Step 7 |
| --resume and --retry-failed flags | Task 3 Step 1 + Task 4 mode detection |
| Never auto-start Phase 2 after Phase 1 | Task 4 Important Constraints |
| Never run Chrome without confirmation | Task 4 Important Constraints |
| marketplace.json registration | Task 5 |

All spec requirements covered.

### Placeholder Scan

No TBDs, TODOs, or "implement later" present. All code blocks, selectors, file paths, and YAML structures are fully specified.

### Type / Name Consistency

- Asset ID format: `cp-{N:02d}-{format_slug}` — defined in Task 2, referenced in Task 3 (screenshot filename uses `asset.id` directly)
- Plan file path: `docs/superpowers/plans/campaign-plan-{slug}-{date}.md` — consistent across Task 2 Step 7, Task 3 Step 1, Task 4 resume commands
- Status values: `pending | running | done | failed | timeout | skipped | edited` — defined in spec, used consistently in Task 3 (Step 5 writes edited/skipped, Step 6 writes running/done/failed, run summary counts all 4)
- Flag names: `--resume`, `--retry-failed` — consistent between Task 3 Step 1 and Task 4 resume commands block
