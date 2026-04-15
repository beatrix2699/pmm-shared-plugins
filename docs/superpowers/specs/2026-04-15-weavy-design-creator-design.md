# Design Spec: weavy-design-creator Skill
**Date:** 2026-04-15
**Status:** Approved

---

## Overview

A skill in `pmm-shared-plugins` that automates the full pipeline from content input to Figma Weave design generation. Takes content from upstream skills (`content-strategy`, `social-content`, `email-sequence`) or free text, generates structured prompts per asset, and executes via either a manual step-by-step guide or Chrome DevTools browser automation.

---

## Pipeline Position

```
content-strategy  ──┐
social-content    ──┤
email-sequence    ──┼──▶  weavy-design-creator  ──▶  Figma Weave (Chrome or Manual)
free text input   ──┘
```

---

## File Layout

```
skills/weavy-design-creator/
├── SKILL.md                    ← orchestrator, mode detection, phase routing
├── sub-skills/plan.md          ← Phase 1: brief collection + prompt generation
├── sub-skills/run.md           ← Phase 2: manual guide + Chrome automation
└── references/weavy-nodes.md  ← Weavy node types, prompt patterns, system prompt templates

.agents/superpowers/plans/
├── campaign-plan-{name}-{date}.md     ← generated plan file
├── campaign-guide-{name}-{date}.md    ← manual execution guide
└── outputs/
    └── {asset_id}.png                 ← Chrome automation screenshots
```

---

## Two-Phase Architecture

### Phase 1 — Plan

1. Collect campaign brief (free text + locked params)
2. Collect content pieces (from upstream skill output or pasted)
3. LLM generates one asset entry per `content_piece × aspect_ratio`
4. Show total asset count + cost estimate
5. User confirms before saving
6. Save plan to `.agents/superpowers/plans/campaign-plan-{name}-{date}.md`

### Phase 2 — Execute

1. User chooses: **Manual guide** or **Chrome automation**
2. Manual → output step-by-step checklist saved as `campaign-guide-{name}-{date}.md`
3. Chrome → approval gate → per-asset confirm loop → browser automation → screenshots → update plan status
4. Run summary with retry commands

---

## Data Structures

### Campaign Brief

```yaml
campaign:
  name: "string"
  brief: "free text"                         # mood, style, story — LLM parses
  locked_params:
    primary_colors: ["#hex"]
    logo_placement: "bottom-right | none | ..."
    aspect_ratios: ["1:1", "16:9", "9:16"]
  negative_prompts: "string"
  reference_image_url: "optional"
  weavy_workflow_url: "string"               # pre-built Weavy workflow URL
```

### Content Piece

```yaml
content_pieces:
  - id: "cp-01"
    source: "social-content | email | free-text"
    raw_content: "full text of the post/email/message"
    intent: "awareness | engagement | conversion"   # LLM infers if not given
```

### Asset Entry (generated)

```yaml
assets:
  - id: "cp-01-1x1"
    content_piece_id: "cp-01"
    format: "1:1"
    generated_prompt: "..."
    system_prompt: "..."
    estimated_cost: "low | med | high"
    status: "pending | running | done | failed | timeout | skipped | edited"
```

---

## Phase 1 — Plan Detail

### Input Collection

**Check for upstream context first.** If a previous skill's output is in the conversation, extract content pieces automatically. Only ask for what's missing.

Collect in order:
1. Campaign name
2. Campaign brief (free text: mood, style, story)
3. Locked params: primary colors, logo placement, aspect ratios
4. Negative prompts
5. Reference image URL (optional)
6. Weavy workflow URL
7. Content pieces (if not already provided by upstream skill)

### Prompt Generation

For each `content_piece × aspect_ratio`:

- `generated_prompt`: LLM combines `campaign.brief` + `content_piece.raw_content` + `format` → concise visual generation prompt
- `system_prompt`: Fixed template combining `campaign_name`, `brief`, `primary_colors`, `negative_prompts`

System prompt template:
```
You are generating visuals for [campaign_name].
Style: [brief]. Colors: [hex list]. Avoid: [negative_prompts].
Maintain visual consistency across all assets in this campaign.
```

### Pre-Save Confirmation

Show summary before saving:
```
Campaign: GreenNode April Launch
Content pieces: 10
Formats per piece: 3 (1:1, 16:9, 9:16)
Total assets: 30
Estimated cost: HIGH

Save plan? (y/n)
```

### Output

Saved to: `.agents/superpowers/plans/campaign-plan-{name}-{date}.md`

---

## Phase 2 — Execute Detail

### Mode Selection

After loading the plan, show:
```
Campaign: GreenNode April Launch — 30 assets queued

How do you want to execute?
  m  Manual guide  — I'll run Weavy myself, show me step-by-step instructions
  c  Chrome auto   — Run via browser automation (approval required per asset)
  q  Quit          — Save plan, run later
```

### Manual Guide Mode

Outputs numbered checklist per asset:
```
── Asset cp-01-1x1 (1 of 30) ──
1. Open: https://app.weavy.ai/your-workflow
2. Paste into Prompt node:
   > "[generated_prompt]"
3. Paste into System Prompt node:
   > "[system_prompt]"
4. Set aspect ratio: 1:1
5. Click Run → save output as cp-01-1x1.png
```

Full guide saved to: `.agents/superpowers/plans/campaign-guide-{name}-{date}.md`

### Chrome Auto Mode

#### Approval Gate (once, before any automation)

```
About to start Chrome automation for 30 assets.
This will open Figma Weave and run each prompt automatically.

Estimated cost: HIGH (30 generations)
Workflow URL:   https://app.weavy.ai/...

Proceed with Chrome automation? (y/n)
```

Only after `y` enters the per-asset loop.

#### Per-Asset Confirm Loop

For each `pending` asset:
```
Asset cp-01-1x1 (1 of 30)
─────────────────────────
Content: "GreenNode GPU clusters now available in SEA..."
Format:  1:1
Prompt:  "Dark techy background, purple gradient, bold sans-serif..."
System:  "Campaign: April Launch | Colors: #6B2FFA, #1A1A2E | No logos..."
Cost:    medium

▶ Run  /  s Skip  /  e Edit prompt  /  q Quit
```

- `e Edit` → user edits prompt inline → status written as `edited` before running
- Decision written back to `campaign-plan.md` before execution

#### Chrome Automation Steps (per asset)

```
1. navigate_page    → weavy_workflow_url
2. wait_for         → workflow canvas loaded
3. fill             → prompt input node with generated_prompt
4. fill             → system prompt node with system_prompt
5. fill             → aspect ratio selector with format
6. click            → Run button
7. wait_for         → output image appears (timeout: 120s)
8. take_screenshot  → .agents/superpowers/plans/outputs/{asset_id}.png
9. Update plan      → status: "done"
```

#### Run Summary

```
Campaign: GreenNode April Launch
✓ Done:    24 assets
⚠ Failed:   3 assets  → re-run: /weavy-design-creator run --retry-failed
→ Skipped:  3 assets

Outputs: .agents/superpowers/plans/outputs/
```

---

## Error Handling

| Situation | Behaviour |
|-----------|-----------|
| Chrome can't find prompt input node | Log `failed: selector not found`, skip asset, continue |
| Weavy workflow URL unreachable | Abort run, suggest switching to Manual mode |
| Generation takes >120s | Mark `status: timeout`, continue next asset |
| User hits `q` mid-run | Save progress to plan file, print resume instruction |
| Plan file missing on `/run` | Prompt user to run Plan phase first |
| Content piece has no clear visual intent | LLM flags it, asks user to clarify before adding to plan |

### Resume Commands

```
/weavy-design-creator run --resume          # first non-done asset
/weavy-design-creator run --retry-failed    # only failed/timeout assets
```

---

## SKILL.md — Mode Detection Logic

| Signal | Mode |
|--------|------|
| "plan campaign" / first invocation / no plan file exists | Plan Phase → `sub-skills/plan.md` |
| "run campaign" / plan file exists | Execute Phase → `sub-skills/run.md` |
| Upstream skill output in conversation + "create designs" | Auto-enter Plan Phase with content pre-filled |
| `--retry-failed` or `--resume` flag | Execute Phase, filtered asset list |

---

## `references/weavy-nodes.md` Content

Node types to reference when building prompts:
- **Text Prompt** — main image generation instruction
- **System Prompt** — persistent campaign style instruction
- **Image Input** — reference image for style anchoring
- **Style Reference** — ControlNet-style consistency node
- **Aspect Ratio** — output dimensions
- **Negative Prompt** — exclusions
- **Seed** — reproducibility
- **Model Selector** — Flux, Stable Diffusion, Recraft, etc.

Prompt patterns by campaign type:
- **Product launch**: "Clean studio, [brand color] accent, product hero shot, minimal background"
- **Thought leadership**: "Abstract minimal, muted palette, typographic focus, white space"
- **Community/event**: "Warm energetic, people implied, bold CTA area, vibrant accent"
- **GPU/tech product**: "Dark techy, neon accent, data visualization elements, cinematic lighting"

---

## Out of Scope

- Weavy REST API integration (no public API as of 2026-04-15 — stub when available)
- Uploading final assets to social platforms
- A/B testing or performance tracking of generated assets
- Multi-user campaign collaboration
