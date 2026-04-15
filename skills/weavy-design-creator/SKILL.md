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
| Plan file exists in `.agents/superpowers/plans/campaign-plan-*.md` AND user says "run" | Run Phase |
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
